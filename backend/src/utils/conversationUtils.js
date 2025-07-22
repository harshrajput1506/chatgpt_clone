import prisma from '../prisma.js';

// Get conversation context with smart truncation
export const getConversationContext = async (chatId, options = {}) => {
    const {
        maxMessages = 20,
        maxTokens = 3000,
        includeSystemMessage = true
    } = options;

    try {
        // Get recent messages from the chat
        const messages = await prisma.message.findMany({
            where: { chatId },
            include: {
                image: true
            },
            orderBy: {
                createdAt: 'desc'
            },
            take: maxMessages
        });

        // Reverse to get chronological order
        const chronologicalMessages = messages.reverse();

        // Estimate token count (rough estimation: 1 token ≈ 4 characters)
        let totalTokens = 0;
        const contextMessages = [];

        for (const message of chronologicalMessages) {
            const messageTokens = Math.ceil(message.content.length / 4);

            if (totalTokens + messageTokens > maxTokens && contextMessages.length > 0) {
                break;
            }

            contextMessages.push(message);
            totalTokens += messageTokens;
        }

        return {
            messages: contextMessages,
            estimatedTokens: totalTokens,
            truncated: contextMessages.length < messages.length
        };

    } catch (error) {
        console.error('Error getting conversation context:', error);
        return {
            messages: [],
            estimatedTokens: 0,
            truncated: false
        };
    }
};

// Create a summary of older messages for context
export const createConversationSummary = async (messages) => {
    if (messages.length <= 5) {
        return null; // No need for summary with few messages
    }

    // Take first few messages to summarize
    const messagesToSummarize = messages.slice(0, Math.floor(messages.length / 2));

    const summary = messagesToSummarize
        .map(msg => `${msg.sender}: ${msg.content.substring(0, 100)}${msg.content.length > 100 ? '...' : ''}`)
        .join('\n');

    return `Previous conversation summary:\n${summary}\n\n---\n\nContinuing conversation:`;
};

// Smart context management for long conversations
export const getSmartContext = async (chatId, options = {}) => {
    const context = await getConversationContext(chatId, options);

    if (context.truncated && context.messages.length > 10) {
        // Get more messages for summary
        const allMessages = await prisma.message.findMany({
            where: { chatId },
            orderBy: { createdAt: 'asc' }
        });

        const summary = await createConversationSummary(allMessages);

        return {
            ...context,
            summary,
            hasContextSummary: !!summary
        };
    }

    return context;
};

// Format conversation for different AI models
export const formatMessageForOpenAI = (context) => {
    const { messages, summary } = context;

    const formattedMessages = messages.map(msg => ({
        role: msg.sender === 'user' ? 'user' : 'assistant',
        content: msg.content,
        ...(msg.image && msg.sender === 'user' ? {
            content: [
                {
                    type: 'text',
                    text: msg.content,
                },
                {
                    type: 'image_url',
                    image_url: {
                        url: msg.image.url,
                        detail: 'auto',
                    },
                },
            ],
        } : {})
    }));

    // Add system message with summary if available
    const systemMessages = [];

    if (summary) {
        systemMessages.push({
            role: 'system',
            content: summary
        });
    }

    systemMessages.push({
        role: 'system',
        content: 'You are a helpful AI assistant. Provide clear, accurate, and helpful responses. If the user shares an image, analyze it and respond appropriately.'
    });

    return [...systemMessages, ...formattedMessages];
};
