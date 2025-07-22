import express from 'express';
import {
    uploadImage,
    uploadMultipleImages,
    deleteImage,
    getImages,
    getImageById
} from '../controllers/imageController.js';
import { uploadSingle, uploadMultiple, handleMulterError } from '../middleware/upload.js';
import { validateObjectId } from '../middleware/validation.js';

const router = express.Router();

// Image upload routes
router.post('/upload', uploadSingle, handleMulterError, uploadImage);
router.post('/upload/multiple', uploadMultiple, handleMulterError, uploadMultipleImages);

// Image management routes
router.get('/', getImages);
router.get('/:id', validateObjectId, getImageById);
router.delete('/:id', validateObjectId, deleteImage);

export default router;
