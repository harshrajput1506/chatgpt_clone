import { generateChatResponse, isOpenAIConfigured } from '../config/openai.js';

// Generate a short, concise title for a chat based on the first user message
export const generateChatTitle = async (firstMessage, options = {}) => {
    try {
        if (!isOpenAIConfigured()) {
            // Fallback to a simple title generation if OpenAI is not configured
            return generateFallbackTitle(firstMessage);
        }

        const { maxLength = 50 } = options;

        const titlePrompt = [
            {
                role: 'system',
                content: `You are a helpful assistant that generates short, descriptive titles for chat conversations. 
        Based on the user's first message, create a concise title that captures the main topic or intent. 
        The title should be:
        - Maximum ${maxLength} characters
        - Clear and descriptive
        - Without quotes or special formatting
        - Professional and appropriate
        - In title case (capitalize first letter of each major word)
        
        Just return the title, nothing else.`
            },
            {
                role: 'user',
                content: `Generate a title for this message: "${firstMessage}"`
            }
        ];

        const completion = await generateChatResponse(titlePrompt, {
            model: 'gpt-4o-mini',
            max_tokens: 20,
            temperature: 0.3 // Lower temperature for more focused titles
        });

        let title = completion.choices[0]?.message?.content?.trim();

        if (!title) {
            return generateFallbackTitle(firstMessage);
        }

        // Clean up the title
        title = title.replace(/^["']|["']$/g, ''); // Remove quotes
        title = title.replace(/\.$/, ''); // Remove trailing period

        // Truncate if too long
        if (title.length > maxLength) {
            title = title.substring(0, maxLength - 3) + '...';
        }

        return title || generateFallbackTitle(firstMessage);

    } catch (error) {
        console.error('Error generating chat title:', error);
        return generateFallbackTitle(firstMessage);
    }
};

// Fallback title generation when AI is not available
export const generateFallbackTitle = (message) => {
    if (!message || typeof message !== 'string') {
        return 'New Chat';
    }

    // Clean the message
    let title = message.trim();

    // Remove common prefixes
    title = title.replace(/^(hi|hello|hey|can you|could you|please|i need|help me|how to|what is|what are|tell me|explain)\s+/i, '');

    // Take first meaningful words
    const words = title.split(/\s+/).slice(0, 6);
    title = words.join(' ');

    // Truncate if too long
    if (title.length > 50) {
        title = title.substring(0, 47) + '...';
    }

    // Capitalize first letter
    title = title.charAt(0).toUpperCase() + title.slice(1);

    return title || 'New Chat';
};