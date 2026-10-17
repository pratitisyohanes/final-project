const ApiError = require('../utils/ApiError');
const { verifyAccessToken } = require('../utils/jwt');

const extractToken = (req) => {
  const header = req.headers.authorization || '';
  return header.startsWith('Bearer ') ? header.slice(7) : null;
};

// Require a valid access token and attach { id, role } to req.user
const authenticate = (req, res, next) => {
  const token = extractToken(req);
  if (!token) return next(ApiError.unauthorized('Access token is missing'));

  try {
    const payload = verifyAccessToken(token);
    req.user = { id: payload.sub, role: payload.role };
    return next();
  } catch {
    return next(ApiError.unauthorized('Access token is invalid or expired'));
  }
};

// Attach req.user when a valid token exists, otherwise continue as a guest
const optionalAuthenticate = (req, res, next) => {
  const token = extractToken(req);
  if (!token) return next();

  try {
    const payload = verifyAccessToken(token);
    req.user = { id: payload.sub, role: payload.role };
  } catch {
    req.user = undefined;
  }
  return next();
};

module.exports = { authenticate, optionalAuthenticate };
