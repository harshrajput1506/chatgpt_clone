// Rate limiting middleware for OpenAI requests
const requestCounts = new Map();
const RATE_LIMIT_WINDOW = 60 * 1000; // 1 minute
const RATE_LIMIT_MAX_REQUESTS = 20; // Max 20 requests per minute per IP

export const rateLimitOpenAI = (req, res, next) => {
    const clientIP = req.ip || req.connection.remoteAddress;
    const now = Date.now();

    // Clean up old entries
    for (const [ip, data] of requestCounts.entries()) {
        if (now - data.firstRequest > RATE_LIMIT_WINDOW) {
            requestCounts.delete(ip);
        }
    }

    // Check current IP
    if (!requestCounts.has(clientIP)) {
        requestCounts.set(clientIP, {
            count: 1,
            firstRequest: now
        });
        return next();
    }

    const ipData = requestCounts.get(clientIP);

    if (now - ipData.firstRequest > RATE_LIMIT_WINDOW) {
        // Reset window
        requestCounts.set(clientIP, {
            count: 1,
            firstRequest: now
        });
        return next();
    }

    if (ipData.count >= RATE_LIMIT_MAX_REQUESTS) {
        return res.status(429).json({
            error: 'Rate limit exceeded',
            details: `Maximum ${RATE_LIMIT_MAX_REQUESTS} requests per minute`,
            retryAfter: Math.ceil((RATE_LIMIT_WINDOW - (now - ipData.firstRequest)) / 1000)
        });
    }

    ipData.count++;
    next();
};

// Validate AI request parameters
export const validateAIRequest = (req, res, next) => {
    const { model, max_tokens, temperature } = req.body;

    // Validate model
    if (model && typeof model !== 'string') {
        return res.status(400).json({ error: 'Model must be a string' });
    }

    // Validate max_tokens
    if (max_tokens !== undefined) {
        if (!Number.isInteger(max_tokens) || max_tokens < 1 || max_tokens > 4000) {
            return res.status(400).json({
                error: 'max_tokens must be an integer between 1 and 4000'
            });
        }
    }

    // Validate temperature
    if (temperature !== undefined) {
        if (typeof temperature !== 'number' || temperature < 0 || temperature > 2) {
            return res.status(400).json({
                error: 'temperature must be a number between 0 and 2'
            });
        }
    }

    next();
};

// Check if chat has recent messages (to prevent spam)
export const validateChatActivity = async (req, res, next) => {
    try {
        const { chatId } = req.params;

        // Check if there are any user messages in the chat
        const userMessages = await req.prisma?.message?.count?.({
            where: {
                chatId,
                sender: 'user'
            }
        });

        if (!userMessages || userMessages === 0) {
            return res.status(400).json({
                error: 'No user messages found in chat',
                details: 'Add a user message before requesting AI response'
            });
        }

        next();
    } catch (error) {
        // If prisma is not available, skip validation
        next();
    }
};
