import express from 'express';
import {
    generateAIResponse,
    streamAIResponse,
    getAvailableModels,
    testOpenAIConnection
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

// OpenAI utility routes
router.get('/models', getAvailableModels);
router.get('/test', testOpenAIConnection);

export default router;
