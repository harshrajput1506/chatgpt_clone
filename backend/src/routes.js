import express from 'express';
import { getChats, getChatById, createChat, updateChat, deleteChat, generateTitleForChat } from './controllers/chatController.js';
import { getMessages, createMessage, deleteMessage } from './controllers/messageController.js';
import { validateChatCreation, validateChatUpdate, validateMessageCreation, validateObjectId, validateUserAccess } from './middleware/validation.js';
import imageRoutes from './routes/imageRoutes.js';
import openaiRoutes from './routes/openaiRoutes.js';

const router = express.Router();

// Chat routes
router.get('/chats', validateUserAccess, getChats);
router.get('/chats/:id', validateObjectId, getChatById);
router.post('/chats', validateChatCreation, createChat);
router.put('/chats/:id', validateObjectId, validateChatUpdate, updateChat);
router.delete('/chats/:id', validateObjectId, deleteChat);
router.post('/chats/:id/generate-title', validateObjectId, generateTitleForChat);

// Message routes
router.get('/chats/:chatId/messages', validateObjectId, getMessages);
router.post('/chats/:chatId/messages', validateObjectId, validateMessageCreation, createMessage);
router.delete('/messages/:messageId', validateObjectId, deleteMessage);

// Image routes
router.use('/images', imageRoutes);

// OpenAI routes
router.use('/ai', openaiRoutes);

export default router;
