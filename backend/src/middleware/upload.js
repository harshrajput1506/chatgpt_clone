import multer from 'multer';

// Configure multer for memory storage (we'll upload directly to Cloudinary)
const storage = multer.memoryStorage();

// File filter function
const fileFilter = (req, file, cb) => {
    // Check if file is an image
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    } else {
        cb(new Error('Only image files are allowed'), false);
    }
};

// Create multer instance
const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB limit
        files: 5 // Maximum 5 files
    }
});

// Middleware for single file upload
export const uploadSingle = (req, res, next) => {
    const multerSingle = upload.single('image');

    multerSingle(req, res, (error) => {
        if (error) {
            return handleMulterError(error, req, res, next);
        }
        next();
    });
};

// Middleware for multiple file upload
export const uploadMultiple = (req, res, next) => {
    const multerMultiple = upload.array('images', 5);

    multerMultiple(req, res, (error) => {
        if (error) {
            return handleMulterError(error, req, res, next);
        }
        next();
    });
};

// Middleware to check for multipart content
export const requireMultipart = (req, res, next) => {
    const contentType = req.get('content-type');

    if (!contentType || !contentType.includes('multipart/form-data')) {
        return res.status(400).json({
            error: 'Invalid Content-Type',
            details: 'This endpoint requires multipart/form-data content type for file uploads',
            expected: 'multipart/form-data',
            received: contentType || 'none'
        });
    }

    next();
};

// Error handling middleware for multer
export const handleMulterError = (error, req, res, next) => {
    if (error instanceof multer.MulterError) {
        if (error.code === 'LIMIT_FILE_SIZE') {
            return res.status(400).json({
                error: 'File too large',
                details: 'Maximum file size is 5MB'
            });
        }
        if (error.code === 'LIMIT_FILE_COUNT') {
            return res.status(400).json({
                error: 'Too many files',
                details: 'Maximum 5 files allowed'
            });
        }
        if (error.code === 'LIMIT_UNEXPECTED_FILE') {
            return res.status(400).json({
                error: 'Unexpected field',
                details: 'Use "image" for single upload or "images" for multiple uploads'
            });
        }
    }

    // Handle boundary not found error
    if (error.message && error.message.includes('Boundary not found')) {
        return res.status(400).json({
            error: 'Multipart boundary not found',
            details: 'Please ensure your request uses multipart/form-data content type with proper boundary headers',
            hint: 'Make sure your client is sending a proper multipart request'
        });
    }

    if (error.message === 'Only image files are allowed') {
        return res.status(400).json({
            error: 'Invalid file type',
            details: 'Only image files are allowed'
        });
    }

    // Handle other multer/busboy errors
    if (error.message && error.message.includes('Multipart')) {
        return res.status(400).json({
            error: 'Multipart parsing error',
            details: error.message,
            hint: 'Ensure your request is properly formatted as multipart/form-data'
        });
    }

    // Pass other errors to the default error handler
    next(error);
};
