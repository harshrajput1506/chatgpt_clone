import prisma from '../prisma.js';

import {
    generateChatResponse,
    generateStreamingResponse,
    isOpenAIConfigured
} from '../config/openai.js';
import { getSmartContext, formatMessageForOpenAI } from '../utils/conversationUtils.js';

// Generate AI response for a chat
export const generateAIResponse = async (req, res) => {
    try {
        if (!isOpenAIConfigured()) {
            return res.status(503).json({
                error: 'OpenAI API is not configured',
                details: 'Please set OPENAI_API_KEY in environment variables'
            });
        }

        const { chatId } = req.params;
        const {
            model = 'gpt-4o-mini',
            max_tokens = 1000,
            temperature = 0.7,
            includeSystemMessage = true
        } = req.body;

        // Check if chat exists
        const chat = await prisma.chat.findUnique({
            where: { id: chatId }
        });

        if (!chat) {
            return res.status(404).json({ error: 'Chat not found' });
        }

        // Get smart conversation context
        const context = await getSmartContext(chatId, {
            maxMessages: 25,
            maxTokens: 3000,
            includeSystemMessage
        });

        if (context.messages.length === 0) {
            return res.status(400).json({
                error: 'No messages found in chat',
                details: 'Add messages to the chat before generating AI response'
            });
        }

        // Check if the last message is from user
        const lastMessage = context.messages[context.messages.length - 1];
        if (lastMessage.sender !== 'user') {
            return res.status(400).json({
                error: 'Last message must be from user',
                details: 'AI can only respond to user messages'
            });
        }

        // Format messages for the specified model
        const formattedMessages = formatMessageForOpenAI(context);



        const completion = await generateChatResponse(formattedMessages, {
            model,
            max_tokens,
            temperature
        });;

        const aiResponse = completion.choices[0]?.message?.content;

        if (!aiResponse) {
            return res.status(500).json({ error: 'No response generated from OpenAI' });
        }

        // Save AI response to database
        const aiMessage = await prisma.message.create({
            data: {
                chatId,
                content: aiResponse,
                sender: 'assistant'
            },
            include: {
                image: true
            }
        });

        res.json({
            success: true,
            message: aiMessage,
            usage: completion.usage,
            model: completion.model,
            context: {
                messagesUsed: context.messages.length,
                truncated: context.truncated,
                hasContextSummary: context.hasContextSummary,
                estimatedTokens: context.estimatedTokens
            },
        });

    } catch (error) {
        console.error('AI Response Error:', error);
        res.status(500).json({
            error: 'Failed to generate AI response',
            details: error.message
        });
    }
};

// Stream AI response
export const streamAIResponse = async (req, res) => {
    try {
        if (!isOpenAIConfigured()) {
            return res.status(503).json({
                error: 'OpenAI API is not configured'
            });
        }

        const { chatId } = req.params;
        const {
            model = 'gpt-4o-mini',
            max_tokens = 1000,
            temperature = 0.7
        } = req.body;

        // Set headers for Server-Sent Events
        res.setHeader('Content-Type', 'text/event-stream');
        res.setHeader('Cache-Control', 'no-cache');
        res.setHeader('Connection', 'keep-alive');
        res.setHeader('Access-Control-Allow-Origin', '*');

        // Check if chat exists
        const chat = await prisma.chat.findUnique({
            where: { id: chatId }
        });

        if (!chat) {
            res.write(`data: ${JSON.stringify({ error: 'Chat not found' })}\n\n`);
            res.end();
            return;
        }

        // Get smart conversation context
        const context = await getSmartContext(chatId, {
            maxMessages: 20,
            maxTokens: 3000
        });

        if (context.messages.length === 0) {
            res.write(`data: ${JSON.stringify({ error: 'No messages found in chat' })}\n\n`);
            res.end();
            return;
        }

        // Format messages for the model
        const formattedMessages = formatMessageForOpenAI(context);

        const stream = await generateStreamingResponse(formattedMessages, {
            model,
            max_tokens,
            temperature
        });

        let fullResponse = '';

        // Stream the response
        for await (const chunk of stream) {
            const content = chunk.choices[0]?.delta?.content || '';
            if (content) {
                fullResponse += content;
                res.write(`data: ${JSON.stringify({
                    content,
                    type: 'chunk',
                    model: chunk.model
                })}\n\n`);
            }
        }

        // Save complete response to database
        const aiMessage = await prisma.message.create({
            data: {
                chatId,
                content: fullResponse,
                sender: 'assistant'
            }
        });

        // Send completion signal
        res.write(`data: ${JSON.stringify({
            type: 'complete',
            messageId: aiMessage.id,
            fullContent: fullResponse,
            context: {
                messagesUsed: context.messages.length,
                truncated: context.truncated
            }
        })}\n\n`);

        res.end();

    } catch (error) {
        console.error('Streaming Error:', error);
        res.write(`data: ${JSON.stringify({
            error: 'Failed to generate streaming response',
            details: error.message
        })}\n\n`);
        res.end();
    }
};

// Get available OpenAI models
export const getAvailableModels = async (req, res) => {
    try {
        if (!isOpenAIConfigured()) {
            return res.status(503).json({
                error: 'OpenAI API is not configured'
            });
        }

        // Return predefined list of commonly used models
        const models = [
            {
                id: 'gpt-4.1',
                name: 'GPT-4.1',
                supports_images: true,
                max_tokens: 4096
            },
            {
                id: 'gpt-4.1-mini',
                name: 'GPT-4.1 Mini',
                supports_images: true,
                max_tokens: 8192
            },

            {
                id: 'gpt-4o',
                name: 'GPT-4o',
                supports_images: true,
                max_tokens: 4096
            },

            {
                id: 'gpt-4o-mini',
                name: 'GPT-4o Mini',
                supports_images: true,
                max_tokens: 8192
            },
        ];

        res.json({
            models,
            configured: true
        });

    } catch (error) {
        console.error('Get Models Error:', error);
        res.status(500).json({
            error: 'Failed to get available models',
            details: error.message
        });
    }
};

// Regenerate response for a specific message
export const regenerateResponse = async (req, res) => {
    try {
        if (!isOpenAIConfigured()) {
            return res.status(503).json({
                error: 'OpenAI API is not configured',
                details: 'Please set OPENAI_API_KEY in environment variables'
            });
        }

        const { chatId, messageId } = req.params;
        const {
            model = 'gpt-4o-mini',
            max_tokens = 1000,
            temperature = 0.7,
            includeSystemMessage = true
        } = req.body;

        // Check if chat exists
        const chat = await prisma.chat.findUnique({
            where: { id: chatId }
        });

        if (!chat) {
            return res.status(404).json({ error: 'Chat not found' });
        }

        // Find the message to regenerate from
        const targetMessage = await prisma.message.findUnique({
            where: { id: messageId }
        });

        if (!targetMessage) {
            return res.status(404).json({ error: 'Message not found' });
        }

        if (targetMessage.chatId !== chatId) {
            return res.status(400).json({ error: 'Message does not belong to this chat' });
        }

        if (targetMessage.sender !== 'assistant') {
            return res.status(400).json({ error: 'Can only regenerate response for assistant messages' });
        }

        // Delete the target message and all messages after it
        await prisma.message.deleteMany({
            where: {
                chatId: chatId,
                createdAt: {
                    gte: targetMessage.createdAt
                }
            }
        });

        // Get conversation context up to (but not including) the target message
        const messages = await prisma.message.findMany({
            where: {
                chatId,
                createdAt: {
                    lt: targetMessage.createdAt
                }
            },
            orderBy: { createdAt: 'asc' },
            include: { image: true }
        });

        if (messages.length === 0) {
            return res.status(400).json({
                error: 'No messages found in chat',
                details: 'Add messages to the chat before regenerating response'
            });
        }

        // Ensure the last message is from user (so we can regenerate assistant response)
        const lastMessage = messages[messages.length - 1];
        if (lastMessage.sender !== 'user') {
            return res.status(400).json({
                error: 'Cannot regenerate response',
                details: 'The conversation must end with a user message to regenerate assistant response'
            });
        }

        // Build context for OpenAI
        const context = {
            messages: messages,
            truncated: false,
            hasContextSummary: false,
            estimatedTokens: messages.length * 50 // Rough estimate
        };

        // Format messages for the specified model
        const formattedMessages = formatMessageForOpenAI(context);

        const completion = await generateChatResponse(formattedMessages, {
            model,
            max_tokens,
            temperature
        });

        const aiResponse = completion.choices[0]?.message?.content;

        if (!aiResponse) {
            return res.status(500).json({ error: 'No response generated from OpenAI' });
        }

        // Save new AI response to database
        const aiMessage = await prisma.message.create({
            data: {
                chatId,
                content: aiResponse,
                sender: 'assistant'
            },
            include: {
                image: true
            }
        });

        // Get updated chat with all messages
        const updatedChat = await prisma.chat.findUnique({
            where: { id: chatId },
            include: {
                messages: {
                    orderBy: { createdAt: 'asc' },
                    include: { image: true }
                }
            }
        });

        res.json({
            success: true,
            chat: updatedChat,
            message: aiMessage,
            usage: completion.usage,
            model: completion.model,
            regenerated: true,
            context: {
                messagesUsed: context.messages.length,
                truncated: context.truncated,
                hasContextSummary: context.hasContextSummary,
                estimatedTokens: context.estimatedTokens
            }
        });

    } catch (error) {
        console.error('Regenerate Response Error:', error);
        res.status(500).json({
            error: 'Failed to regenerate AI response',
            details: error.message
        });
    }
};

// Test OpenAI connection
export const testOpenAIConnection = async (req, res) => {
    try {
        if (!isOpenAIConfigured()) {
            return res.status(503).json({
                error: 'OpenAI API is not configured',
                configured: false
            });
        }

        // Simple test with minimal tokens
        const completion = await generateChatResponse([
            { role: 'user', content: 'Say "Hello, API test successful!"' }
        ], {
            model: 'gpt-4o-mini',
            max_tokens: 20
        });

        res.json({
            success: true,
            configured: true,
            response: completion.choices[0]?.message?.content,
            model: completion.model
        });

    } catch (error) {
        console.error('OpenAI Test Error:', error);
        res.status(500).json({
            error: 'OpenAI connection test failed',
            configured: false,
            details: error.message
        });
    }
};
