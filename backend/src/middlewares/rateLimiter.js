const rateLimit = require('express-rate-limit');
const env = require('../config/env');
const ApiError = require('../utils/ApiError');

const createLimiter = (windowMinutes, limit, message) =>
  rateLimit({
    windowMs: windowMinutes * 60 * 1000,
    limit,
    standardHeaders: 'draft-7',
    legacyHeaders: false,
    skip: () => env.NODE_ENV === 'test',
    handler: (req, res, next) => next(new ApiError(429, message)),
  });

// Strict limiter against brute force on login and register
const authLimiter = createLimiter(15, 10, 'Too many attempts, please try again in 15 minutes');

const apiLimiter = createLimiter(15, 500, 'Too many requests, please slow down');

module.exports = { authLimiter, apiLimiter };
