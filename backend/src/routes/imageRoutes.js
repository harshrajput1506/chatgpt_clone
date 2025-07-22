import express from 'express';
import {
    uploadImage,
    uploadMultipleImages,
    deleteImage,
    getImages,
    getImageById
} from '../controllers/imageController.js';
import { uploadSingle, uploadMultiple, handleMulterError, requireMultipart } from '../middleware/upload.js';
import { validateObjectId } from '../middleware/validation.js';

const router = express.Router();

// Test endpoint
router.get('/test', (req, res) => {
    res.json({
        success: true,
        message: 'Image API is working',
        endpoints: {
            upload: 'POST /api/images/upload (requires multipart/form-data with "image" field)',
            uploadMultiple: 'POST /api/images/upload/multiple (requires multipart/form-data with "images" field)',
            getAll: 'GET /api/images/',
            getById: 'GET /api/images/:id',
            delete: 'DELETE /api/images/:id'
        }
    });
});

// Image upload routes
router.post('/upload', requireMultipart, uploadSingle, uploadImage);
//router.post('/upload/multiple', requireMultipart, uploadMultiple, uploadMultipleImages);

// Image management routes
router.get('/', getImages);
router.get('/:id', validateObjectId, getImageById);
router.delete('/:id', validateObjectId, deleteImage);

export default router;
