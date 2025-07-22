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
export const uploadSingle = upload.single('image');

// Middleware for multiple file upload
export const uploadMultiple = upload.array('images', 5);

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

    if (error.message === 'Only image files are allowed') {
        return res.status(400).json({
            error: 'Invalid file type',
            details: 'Only image files are allowed'
        });
    }

    // Pass other errors to the default error handler
    next(error);
};
