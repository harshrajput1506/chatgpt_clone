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
        originalUrl: image.url,
        urls: generateImageVariants(image.publicId),
        createdAt: image.createdAt
    };
};