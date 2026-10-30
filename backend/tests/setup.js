// Test environment values; integration tests below never touch the database
process.env.NODE_ENV = 'test';
process.env.DATABASE_URL = process.env.DATABASE_URL || 'postgresql://test:test@localhost:5432/test_db';
process.env.JWT_ACCESS_SECRET = 'test-access-secret-1234567890';
process.env.JWT_REFRESH_SECRET = 'test-refresh-secret-1234567890';
process.env.INTERNAL_API_KEY = 'test-internal-key-0123456789abcdef0123';
// auth-service is never called for real: fetch is mocked in authClient tests
process.env.AUTH_SERVICE_URL = 'http://127.0.0.1:5998';
process.env.AUTH_CLIENT_ID = 'booking-api';
process.env.AUTH_CLIENT_SECRET = 'test-client-secret';
process.env.MFA_ENCRYPTION_KEY = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
// Single sign-on: tests/integration/sso.test.js serves a JWKS on this port with its own test key
process.env.AUTH_PROVIDER = 'sso';
process.env.SSO_JWKS_URL = 'http://127.0.0.1:5995/.well-known/jwks.json';
process.env.SSO_ISSUER = 'http://localhost:5002';
