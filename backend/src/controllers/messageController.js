import prisma from '../prisma.js';
import { generateChatTitle } from '../utils/titleGenerator.js';

export const getMessages = async (req, res) => {
    try {
        const { chatId } = req.params;
        const { page = 1, limit = 50 } = req.query;

        // Check if chat exists
        const chat = await prisma.chat.findUnique({
            where: { id: chatId }
        });

        if (!chat) {
            return res.status(404).json({ error: 'Chat not found' });
        }

        const messages = await prisma.message.findMany({
            where: { chatId },
            include: {
                image: true
            },
            orderBy: {
                createdAt: 'asc'
            },
            skip: (page - 1) * limit,
            take: parseInt(limit)
        }); const totalMessages = await prisma.message.count({
            where: { chatId }
        });

        res.json({
            messages,
            pagination: {
                page: parseInt(page),
                limit: parseInt(limit),
                total: totalMessages,
                totalPages: Math.ceil(totalMessages / limit)
            }
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const createMessage = async (req, res) => {
    try {
        const { chatId } = req.params;
        const { content, sender, imageId } = req.body;

        if (!content || !sender) {
            return res.status(400).json({ error: 'Content and sender are required' });
        }

        // Check if chat exists and get message count
        const chat = await prisma.chat.findUnique({
            where: { id: chatId },
            include: {
                _count: {
                    select: {
                        messages: {
                            where: { sender: 'user' }
                        }
                    }
                }
            }
        });

        if (!chat) {
            return res.status(404).json({ error: 'Chat not found' });
        }

        // If imageId is provided, verify it exists
        if (imageId) {
            const image = await prisma.image.findUnique({
                where: { id: imageId }
            });

            if (!image) {
                return res.status(404).json({ error: 'Image not found' });
            }
        }

        const message = await prisma.message.create({
            data: {
                chatId,
                content,
                sender,
                imageId: imageId || null
            },
            include: {
                image: true
            }
        });

        // Auto-generate title if this is the first user message and chat has default title
        let titleGenerated = false;
        if (sender === 'user' &&
            chat._count.messages === 0 &&
            (chat.title === 'New Chat' || chat.title.startsWith('New Chat'))) {

            try {
                const newTitle = await generateChatTitle(content);
                await prisma.chat.update({
                    where: { id: chatId },
                    data: { title: newTitle }
                });
                titleGenerated = true;
                message.generatedTitle = newTitle;
            } catch (titleError) {
                console.error('Error generating chat title:', titleError);
                // Don't fail the message creation if title generation fails
            }
        }

        res.status(201).json({
            success: true,
            message,
            titleGenerated,
            ...(titleGenerated && { newChatTitle: message.generatedTitle })
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}; export const deleteMessage = async (req, res) => {
    try {
        const { messageId } = req.params;

        await prisma.message.delete({
            where: { id: messageId }
        });

        res.status(204).send();
    } catch (error) {
        if (error.code === 'P2025') {
            return res.status(404).json({ error: 'Message not found' });
        }
        res.status(500).json({ error: error.message });
    }
};
