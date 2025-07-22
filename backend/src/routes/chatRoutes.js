import express from 'express';
import { getChats, getChatById, createChat, updateChat, deleteChat } from '../controllers/chatController.js';
import { getMessages, createMessage, deleteMessage } from '../controllers/messageController.js';
import { validateChatCreation, validateMessageCreation, validateObjectId } from '../middleware/validation.js';
import imageRoutes from './imageRoutes.js';

const router = express.Router();

// Chat routes
router.get('/chats', getChats);
router.get('/chats/:id', validateObjectId, getChatById);
router.post('/chats', validateChatCreation, createChat);
router.put('/chats/:id', validateObjectId, validateChatCreation, updateChat);
router.delete('/chats/:id', validateObjectId, deleteChat);

// Message routes
router.get('/chats/:chatId/messages', validateObjectId, getMessages);
router.post('/chats/:chatId/messages', validateObjectId, validateMessageCreation, createMessage);
router.delete('/messages/:messageId', validateObjectId, deleteMessage);

// Image routes
router.use('/images', imageRoutes);

export default router;
