import { v2 as cloudinary } from 'cloudinary';
import dotenv from 'dotenv';

dotenv.config();

// Configure Cloudinary
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Upload image to Cloudinary
export const uploadToCloudinary = async (fileBuffer, options = {}) => {
    try {
        return new Promise((resolve, reject) => {
            cloudinary.uploader.upload_stream(
                {
                    resource_type: 'image',
                    folder: 'chatgpt-clone',
                    transformation: [
                        { width: 1024, height: 1024, crop: 'limit' },
                        { quality: 'auto:good' }
                    ],
                    ...options
                },
                (error, result) => {
                    if (error) {
                        reject(error);
                    } else {
                        resolve(result);
                    }
                }
            ).end(fileBuffer);
        });
    } catch (error) {
        throw new Error('Failed to upload image to Cloudinary');
    }
};

// Delete image from Cloudinary
export const deleteFromCloudinary = async (publicId) => {
    try {
        const result = await cloudinary.uploader.destroy(publicId);
        return result;
    } catch (error) {
        throw new Error('Failed to delete image from Cloudinary');
    }
};

// Generate optimized URL
export const getOptimizedUrl = (publicId, options = {}) => {
    return cloudinary.url(publicId, {
        transformation: [
            { width: 400, height: 400, crop: 'fill' },
            { quality: 'auto:good' },
            { format: 'auto' }
        ],
        ...options
    });
};

export default cloudinary;
