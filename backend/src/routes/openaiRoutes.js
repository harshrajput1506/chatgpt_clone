import express from 'express';
import {
    generateAIResponse,
    streamAIResponse,
    getAvailableModels,
    testOpenAIConnection,
    regenerateResponse,
    regenerateStreamResponse
} from '../controllers/openaiController.js';
import { validateObjectId } from '../middleware/validation.js';
import { rateLimitOpenAI, validateAIRequest } from '../middleware/aiValidation.js';

const router = express.Router();

// OpenAI chat routes (with rate limiting and validation)
router.post('/chats/:chatId/generate',
    validateObjectId,
    rateLimitOpenAI,
    validateAIRequest,
    generateAIResponse
);

router.post('/chats/:chatId/stream',
    validateObjectId,
    rateLimitOpenAI,
    validateAIRequest,
    streamAIResponse
);

// Regenerate response for a specific message
router.post('/chats/:chatId/messages/:messageId/regenerate',
    validateObjectId,
    rateLimitOpenAI,
    validateAIRequest,
    regenerateResponse
);

// Regenerate streaming response for a specific message
router.post('/chats/:chatId/messages/:messageId/regenerate-stream',
    validateObjectId,
    rateLimitOpenAI,
    validateAIRequest,
    regenerateStreamResponse
);

// OpenAI utility routes
router.get('/models', getAvailableModels);
router.get('/test', testOpenAIConnection);

export default router;
