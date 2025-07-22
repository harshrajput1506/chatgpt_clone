import prisma from '../prisma.js';
import { generateChatTitle } from '../utils/titleGenerator.js';

export const getChats = async (req, res) => {
    try {
        const { uid } = req.query;

        const whereClause = uid ? { uid } : {};

        const chats = await prisma.chat.findMany({
            where: whereClause,
            include: {
                messages: {
                    take: 1,
                    orderBy: {
                        createdAt: 'desc'
                    }
                }
            },
            orderBy: {
                createdAt: 'desc'
            }
        });

        res.json({
            chats,
            count: chats.length,
            userId: uid || null
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getChatById = async (req, res) => {
    try {
        const { id } = req.params;
        const { uid } = req.query; // Optional: verify user owns this chat

        const whereClause = { id };
        if (uid) {
            whereClause.uid = uid;
        }

        const chat = await prisma.chat.findUnique({
            where: whereClause,
            include: {
                messages: {
                    include: {
                        image: true
                    },
                    orderBy: {
                        createdAt: 'asc'
                    }
                }
            }
        });

        if (!chat) {
            return res.status(404).json({
                error: uid ? 'Chat not found or access denied' : 'Chat not found'
            });
        }

        res.json(chat);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const createChat = async (req, res) => {
    try {
        const { title, uid } = req.body;

        if (!uid) {
            return res.status(400).json({ error: 'User ID (uid) is required' });
        }

        // Create chat with default title (will be updated when first message is added)
        const chat = await prisma.chat.create({
            data: {
                title: title || 'New Chat',
                uid
            },
            include: {
                messages: true
            }
        });

        res.status(201).json({
            success: true,
            chat,
            message: 'Chat created successfully. Title will be auto-generated when first message is added.'
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const updateChat = async (req, res) => {
    try {
        const { id } = req.params;
        const { title, uid } = req.body;

        if (!title) {
            return res.status(400).json({ error: 'Title is required' });
        }

        // Build where clause - include uid if provided for access control
        const whereClause = { id };
        if (uid) {
            whereClause.uid = uid;
        }

        const chat = await prisma.chat.update({
            where: whereClause,
            data: { title },
            include: {
                messages: {
                    include: {
                        image: true
                    },
                    orderBy: {
                        createdAt: 'asc'
                    }
                }
            }
        });

        res.json({
            success: true,
            chat
        });
    } catch (error) {
        if (error.code === 'P2025') {
            return res.status(404).json({
                error: 'Chat not found or access denied'
            });
        }
        res.status(500).json({ error: error.message });
    }
};

export const deleteChat = async (req, res) => {
    try {
        const { id } = req.params;
        const { uid } = req.query; // Optional: verify user owns this chat

        // Build where clause - include uid if provided for access control
        const whereClause = { id };
        if (uid) {
            whereClause.uid = uid;
        }

        // Check if chat exists and user has access
        const existingChat = await prisma.chat.findUnique({
            where: whereClause
        });

        if (!existingChat) {
            return res.status(404).json({
                error: uid ? 'Chat not found or access denied' : 'Chat not found'
            });
        }

        // Delete all messages first (cascade delete)
        await prisma.message.deleteMany({
            where: { chatId: id }
        });

        // Then delete the chat
        await prisma.chat.delete({
            where: { id }
        });

        res.status(204).send();
    } catch (error) {
        if (error.code === 'P2025') {
            return res.status(404).json({ error: 'Chat not found' });
        }
        res.status(500).json({ error: error.message });
    }
};

// New function to generate title for existing chat
export const generateTitleForChat = async (req, res) => {
    try {
        const { id } = req.params;
        const { uid } = req.query;

        // Build where clause
        const whereClause = { id };
        if (uid) {
            whereClause.uid = uid;
        }

        // Get chat with messages
        const chat = await prisma.chat.findUnique({
            where: whereClause,
            include: {
                messages: {
                    where: { sender: 'user' },
                    orderBy: { createdAt: 'asc' },
                    take: 1
                }
            }
        });

        if (!chat) {
            return res.status(404).json({
                error: uid ? 'Chat not found or access denied' : 'Chat not found'
            });
        }

        if (chat.messages.length === 0) {
            return res.status(400).json({
                error: 'No user messages found to generate title from'
            });
        }

        // Generate new title based on first user message
        const firstMessage = chat.messages[0];
        const newTitle = await generateChatTitle(firstMessage.content);

        // Update chat with new title
        const updatedChat = await prisma.chat.update({
            where: { id },
            data: { title: newTitle }
        });

        res.json({
            success: true,
            chat: updatedChat,
            oldTitle: chat.title,
            newTitle: newTitle,
            basedOnMessage: firstMessage.content.substring(0, 100) + '...'
        });

    } catch (error) {
        console.error('Error generating title:', error);
        res.status(500).json({
            error: 'Failed to generate title',
            details: error.message
        });
    }
};
