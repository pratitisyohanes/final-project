const env = require('../config/env');
const ApiError = require('../utils/ApiError');

// Service token from POST /oauth/token, reused until one minute before it expires
let cachedToken = null;

const fetchServiceToken = async () => {
  if (cachedToken && cachedToken.expiresAt - 60 * 1000 > Date.now()) return cachedToken.value;

  let response;
  try {
    response = await fetch(`${env.AUTH_SERVICE_URL}/oauth/token`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({ grant_type: 'client_credentials', client_id: env.AUTH_CLIENT_ID, client_secret: env.AUTH_CLIENT_SECRET }),
      signal: AbortSignal.timeout(env.AUTH_TIMEOUT_MS),
    });
  } catch {
    throw new ApiError(503, 'Login service is not responding, please try again');
  }

  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    // Logged for the operator; the browser only gets a generic message (never the client secret)
    console.error(`auth-service refused client "${env.AUTH_CLIENT_ID}": ${body.error || response.status}`);
    throw new ApiError(503, 'Login service is not available, please contact the administrator');
  }

  cachedToken = { value: body.access_token, expiresAt: Date.now() + body.expires_in * 1000 };
  return cachedToken.value;
};

// Call an auth-service API route; a 401 means the cached token expired early, so retry once with a new one
const request = async (path, { method = 'GET', body, userIp } = {}, isRetry = false) => {
  const token = await fetchServiceToken();

  let response;
  try {
    response = await fetch(`${env.AUTH_SERVICE_URL}/api/v1${path}`, {
      method,
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
        ...(userIp && { 'X-Forwarded-For': userIp }),
      },
      body: body ? JSON.stringify(body) : undefined,
      signal: AbortSignal.timeout(env.AUTH_TIMEOUT_MS),
    });
  } catch {
    throw new ApiError(503, 'Login service is not responding, please try again');
  }

  const payload = await response.json().catch(() => ({}));
  if (response.ok) return payload.data;

  if (response.status === 401 && !isRetry) {
    cachedToken = null;
    return request(path, { method, body, userIp }, true);
  }
  if (response.status === 404) return null;
  // Business errors from auth-service (duplicate email, wrong current password, validation) are passed on
  if ([400, 409, 422].includes(response.status)) throw new ApiError(response.status, payload.message, payload.errors);
  if (response.status === 429) throw new ApiError(429, payload.message);
  console.error(`auth-service ${method} ${path} failed with ${response.status}: ${payload.message}`);
  throw new ApiError(503, 'Login service is not available, please try again');
};

// Same contract as the office telkom-auth/authValidate: { login, reason?, user? }
const validate = (email, password, userIp) =>
  request('/auth/validate', { method: 'POST', body: { username: email, password }, userIp });

const getUser = (id) => request(`/users/${id}`);

const createUser = (data, userIp) => request('/users', { method: 'POST', body: data, userIp });

const updateUser = (id, data, userIp) => request(`/users/${id}`, { method: 'PATCH', body: data, userIp });

// For tests: forget the cached service token
const resetTokenCache = () => {
  cachedToken = null;
};

module.exports = { validate, getUser, createUser, updateUser, resetTokenCache };
