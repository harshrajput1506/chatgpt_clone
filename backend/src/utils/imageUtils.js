import { getOptimizedUrl } from '../config/cloudinary.js';

// Generate different image sizes for Flutter app
export const generateImageVariants = (publicId) => {
    return {
        thumbnail: getOptimizedUrl(publicId, {
            transformation: [
                { width: 150, height: 150, crop: 'fill' },
                { quality: 'auto:low' },
                { format: 'auto' }
            ]
        }),
        small: getOptimizedUrl(publicId, {
            transformation: [
                { width: 300, height: 300, crop: 'limit' },
                { quality: 'auto:good' },
                { format: 'auto' }
            ]
        }),
        medium: getOptimizedUrl(publicId, {
            transformation: [
                { width: 600, height: 600, crop: 'limit' },
                { quality: 'auto:good' },
                { format: 'auto' }
            ]
        }),
        large: getOptimizedUrl(publicId, {
            transformation: [
                { width: 1200, height: 1200, crop: 'limit' },
                { quality: 'auto:good' },
                { format: 'auto' }
            ]
        }),
        original: getOptimizedUrl(publicId, {
            transformation: [
                { quality: 'auto:best' },
                { format: 'auto' }
            ]
        })
    };
};

// Format image response for Flutter
export const formatImageResponse = (image) => {
    return {
        id: image.id,
        publicId: image.publicId,
        originalName: image.originalName,
        size: image.size,
        format: image.format,
        dimensions: {
            width: image.width,
            height: image.height
        },
        urls: generateImageVariants(image.publicId),
        createdAt: image.createdAt
    };
};

// Validate image for Flutter requirements
export const validateImageForFlutter = (file) => {
    const errors = [];

    // Check file type
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (!allowedTypes.includes(file.mimetype)) {
        errors.push('Invalid file type. Only JPEG, PNG, GIF, and WebP are supported.');
    }

    // Check file size (5MB for mobile optimization)
    if (file.size > 5 * 1024 * 1024) {
        errors.push('File size too large. Maximum 5MB allowed for optimal mobile performance.');
    }

    // Check if file has content
    if (file.size === 0) {
        errors.push('File is empty.');
    }

    return {
        isValid: errors.length === 0,
        errors
    };
};
