import { uploadToCloudinary, deleteFromCloudinary } from '../config/cloudinary.js';
import { formatImageResponse, validateImageForFlutter } from '../utils/imageUtils.js';
import prisma from '../prisma.js';

// Upload single image
export const uploadImage = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No image file provided' });
        }

        // Validate file for Flutter requirements
        const validation = validateImageForFlutter(req.file);
        if (!validation.isValid) {
            return res.status(400).json({
                error: 'Invalid file',
                details: validation.errors
            });
        }

        // Upload to Cloudinary
        const result = await uploadToCloudinary(req.file.buffer, {
            public_id: `chatgpt_clone_${Date.now()}`,
        });

        // Save image info to database
        const imageRecord = await prisma.image.create({
            data: {
                publicId: result.public_id,
                url: result.secure_url,
                originalName: req.file.originalname,
                size: req.file.size,
                format: result.format,
                width: result.width,
                height: result.height,
            }
        });

        res.status(201).json({
            success: true,
            image: formatImageResponse(imageRecord)
        });
    } catch (error) {
        console.error('Upload error:', error);
        res.status(500).json({
            error: 'Failed to upload image',
            details: error.message
        });
    }
};

// Upload multiple images
export const uploadMultipleImages = async (req, res) => {
    try {
        if (!req.files || req.files.length === 0) {
            return res.status(400).json({ error: 'No image files provided' });
        }

        // Validate file count (max 5 images)
        if (req.files.length > 5) {
            return res.status(400).json({
                error: 'Too many files. Maximum 5 images allowed'
            });
        }

        const uploadPromises = req.files.map(async (file, index) => {
            // Validate file type
            const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
            if (!allowedTypes.includes(file.mimetype)) {
                throw new Error(`Invalid file type for ${file.originalname}`);
            }

            // Validate file size
            if (file.size > 5 * 1024 * 1024) {
                throw new Error(`File ${file.originalname} is too large`);
            }

            // Upload to Cloudinary
            const result = await uploadToCloudinary(file.buffer, {
                public_id: `image_${Date.now()}_${index}`,
            });

            // Save to database
            const imageRecord = await prisma.image.create({
                data: {
                    publicId: result.public_id,
                    url: result.secure_url,
                    originalName: file.originalname,
                    size: file.size,
                    format: result.format,
                    width: result.width,
                    height: result.height,
                }
            });

            return {
                id: imageRecord.id,
                url: result.secure_url,
                publicId: result.public_id,
                originalName: file.originalname,
                size: file.size,
                dimensions: {
                    width: result.width,
                    height: result.height
                }
            };
        });

        const uploadedImages = await Promise.all(uploadPromises);

        res.status(201).json({
            success: true,
            images: uploadedImages,
            count: uploadedImages.length
        });
    } catch (error) {
        console.error('Multiple upload error:', error);
        res.status(500).json({
            error: 'Failed to upload images',
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

        // Delete from Cloudinary
        await deleteFromCloudinary(image.publicId);

        // Delete from database
        await prisma.image.delete({
            where: { id }
        });

        res.status(200).json({
            success: true,
            message: 'Image deleted successfully'
        });
    } catch (error) {
        console.error('Delete error:', error);
        res.status(500).json({
            error: 'Failed to delete image',
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
