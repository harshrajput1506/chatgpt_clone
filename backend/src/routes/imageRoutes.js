import express from 'express';
import {
    createImage,
    deleteImage,
    getImages,
    getImageById
} from '../controllers/imageController.js';
import { validateObjectId, validateImageCreation } from '../middleware/validation.js';

const router = express.Router();

// Test endpoint
router.get('/test', (req, res) => {
    res.json({
        success: true,
        message: 'Image API is working',
        endpoints: {
            create: 'POST /api/images (requires JSON with publicId, url, originalName)',
            createMultiple: 'POST /api/images/create/multiple (requires JSON with array of image objects)',
            getAll: 'GET /api/images/',
            getById: 'GET /api/images/:id',
            delete: 'DELETE /api/images/:id'
        }
    });
});

// Image creation routes
router.post('/', validateImageCreation, createImage);

// Image management routes
//router.get('/', getImages);
router.get('/:id', validateObjectId, getImageById);
router.delete('/:id', validateObjectId, deleteImage);

export default router;
