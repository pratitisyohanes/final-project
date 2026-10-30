const crypto = require('crypto');
const env = require('../config/env');
const ApiError = require('../utils/ApiError');

// Allow server-to-server calls that send the shared X-Internal-Key header
const authenticateService = (req, res, next) => {
  if (!env.INTERNAL_API_KEY) return next(new ApiError(503, 'Internal API is not configured'));

  const given = Buffer.from(req.get('X-Internal-Key') || '');
  const expected = Buffer.from(env.INTERNAL_API_KEY);
  // timingSafeEqual needs equal lengths and avoids leaking the key through response timing
  if (given.length !== expected.length || !crypto.timingSafeEqual(given, expected)) {
    return next(ApiError.unauthorized('Invalid service key'));
  }
  return next();
};

module.exports = authenticateService;
