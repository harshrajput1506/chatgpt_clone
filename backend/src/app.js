import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import routes from './routes/routes.js';
import imageRoutes from './routes/imageRoutes.js';
import openaiRoutes from './routes/openaiRoutes.js';

const app = express();

// Configure CORS for file uploads
app.use(cors({
    origin: true, // Allow all origins for development
    credentials: true,
    optionsSuccessStatus: 200,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(morgan('dev'));

app.get('/', (req, res) => {
    res.send('Welcome to the ChatGPT Clone Backend!');
});

// Image routes
app.use('/api/images', imageRoutes);

// OpenAI routes
app.use('/api/ai', openaiRoutes);

app.use('/api', routes);

export default app;
