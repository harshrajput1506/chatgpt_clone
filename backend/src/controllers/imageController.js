import { formatImageResponse } from '../utils/imageUtils.js';
import prisma from '../prisma.js';

// Create single image record
export const createImage = async (req, res) => {
    try {
        const { publicId, url, originalName } = req.body;

        // Validate required fields
        if (!publicId || !url || !originalName) {
            return res.status(400).json({
                error: 'Missing required fields: publicId, url, originalName'
            });
        }

        // Check if an image with this publicId already exists
        const existingImage = await prisma.image.findUnique({
            where: { publicId }
        });

        if (existingImage) {
            return res.status(409).json({
                error: 'Image with this public ID already exists',
                image: formatImageResponse(existingImage)
            });
        }

        console.log(`Creating image record: ${originalName}, publicId: ${publicId}`);

        // Prepare data object with required fields
        const imageData = {
            publicId,
            url,
            originalName,
        };

        // Save image info to database
        const imageRecord = await prisma.image.create({
            data: imageData
        });

        console.log(`Image record created successfully for: ${originalName}`);

        res.status(201).json({
            success: true,
            image: formatImageResponse(imageRecord)
        });
    } catch (error) {
        console.error('Create image error:', error);

        // Handle unique constraint violation
        if (error.code === 'P2002' && error.meta?.target?.includes('publicId')) {
            return res.status(409).json({
                error: 'Image with this public ID already exists'
            });
        }

        res.status(500).json({
            error: 'Failed to create image record',
            details: error.message
        });
    }
};


// Delete image
export const deleteImage = async (req, res) => {
    try {
        const { id } = req.params;

        // Find image in database
        const image = await prisma.image.findUnique({
            where: { id }
        });

        if (!image) {
            return res.status(404).json({ error: 'Image not found' });
        }

        // Delete from database
        await prisma.image.delete({
            where: { id }
        });

        res.status(200).json({
            success: true,
            message: 'Image record deleted successfully',
            deletedImage: {
                id: image.id,
                publicId: image.publicId,
                originalName: image.originalName
            }
        });
    } catch (error) {
        console.error('Delete error:', error);
        res.status(500).json({
            error: 'Failed to delete image record',
            details: error.message
        });
    }
};

// Get all images
export const getImages = async (req, res) => {
    try {
        const { page = 1, limit = 20 } = req.query;

        const images = await prisma.image.findMany({
            orderBy: {
                createdAt: 'desc'
            },
            skip: (page - 1) * limit,
            take: parseInt(limit)
        });

        const totalImages = await prisma.image.count();

        res.json({
            images: images.map(formatImageResponse),
            pagination: {
                page: parseInt(page),
                limit: parseInt(limit),
                total: totalImages,
                totalPages: Math.ceil(totalImages / limit)
            }
        });
    } catch (error) {
        console.error('Get images error:', error);
        res.status(500).json({
            error: 'Failed to fetch images',
            details: error.message
        });
    }
};

// Get single image
export const getImageById = async (req, res) => {
    try {
        const { id } = req.params;

        const image = await prisma.image.findUnique({
            where: { id }
        });

        if (!image) {
            return res.status(404).json({ error: 'Image not found' });
        }

        res.json(formatImageResponse(image));
    } catch (error) {
        console.error('Get image error:', error);
        res.status(500).json({
            error: 'Failed to fetch image',
            details: error.message
        });
    }
};
