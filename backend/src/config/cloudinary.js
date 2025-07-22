import { v2 as cloudinary } from 'cloudinary';
import dotenv from 'dotenv';

dotenv.config();

// Configure Cloudinary
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
    secure: true,
});

// Upload image to Cloudinary with timeout and retry logic
export const uploadToCloudinary = async (fileBuffer, options = {}, retryCount = 0) => {
    const maxRetries = 2;

    // Log file details for debugging
    if (options && options.fileName) {
        console.log(`Starting upload for file: ${options.fileName}, size: ${fileBuffer?.length || 0} bytes, attempt: ${retryCount + 1}`);
    } else {
        console.log(`Starting upload, size: ${fileBuffer?.length || 0} bytes, attempt: ${retryCount + 1}`);
    }
    if (options) {
        console.log('Upload options:', options);
    }

    try {
        return await new Promise((resolve, reject) => {
            const timeoutMs = 120000; // 2 minutes
            cloudinary.uploader.upload_stream(
                {
                    resource_type: 'image',
                    folder: 'chatgpt-clone',
                    timeout: timeoutMs,
                    ...options
                },
                (error, result) => {
                    if (error) {
                        console.error(`Cloudinary upload error (attempt ${retryCount + 1}):`, error);
                        return reject(error);
                    } else {
                        console.log(`Cloudinary upload successful:`, result.public_id);
                        return resolve(result);
                    }
                }
            ).end(fileBuffer);
        });
    } catch (error) {
        console.error(`Upload failed (attempt ${retryCount + 1}):`, error.message);

        // Retry on timeout errors
        if ((error.message.includes('timeout') || error.message.includes('Timeout') || error.http_code === 499)
            && retryCount < maxRetries) {
            console.log(`Retrying upload... (${retryCount + 1}/${maxRetries})`);
            await new Promise(resolve => setTimeout(resolve, 1000 * (retryCount + 1))); // Exponential backoff
            return uploadToCloudinary(fileBuffer, options, retryCount + 1);
        }

        throw error; // Re-throw the error so it can be handled by the caller
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
