import OpenAI from 'openai';
import dotenv from 'dotenv';

dotenv.config();

// Initialize OpenAI client
const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
});

// Chat completion with text
export const generateChatResponse = async (messages, options = {}) => {
    try {
        const completion = await openai.chat.completions.create({
            model: options.model || 'gpt-4.1-mini',
            messages: messages,
            max_tokens: options.max_tokens || 1000,
            temperature: options.temperature || 0.7,
            top_p: options.top_p || 1,
            frequency_penalty: options.frequency_penalty || 0,
            presence_penalty: options.presence_penalty || 0,
            stream: options.stream || false,
        });

        return completion;
    } catch (error) {
        console.error('OpenAI API Error:', error);
        throw new Error(`OpenAI API Error: ${error.message}`);
    }
};

// Stream chat completion
export const generateStreamingResponse = async (messages, options = {}) => {
    try {
        const stream = await openai.chat.completions.create({
            model: options.model || 'gpt-3.5-turbo',
            messages: messages,
            max_tokens: options.max_tokens || 1000,
            temperature: options.temperature || 0.7,
            stream: true,
        });

        return stream;
    } catch (error) {
        console.error('OpenAI Streaming API Error:', error);
        throw new Error(`OpenAI Streaming API Error: ${error.message}`);
    }
};

// Check if OpenAI API key is configured
export const isOpenAIConfigured = () => {
    return !!process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY !== 'sk-xxxxx';
};

export default openai;
