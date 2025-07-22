import app from './app.js';
import dotenv from 'dotenv';

dotenv.config();

const PORT = process.env.PORT || 5000;

// error handling middleware
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(err.status || 500).json({  
        error: 'Internal Server Error',
        details: err.message || 'An unexpected error occurred'
    });
}); 

// 404 handler for undefined routes
app.use((req, res) => {
    res.status(404).json({
        error: 'Not Found',
        details: 'The requested resource could not be found'
    });
});

// Listen the server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
