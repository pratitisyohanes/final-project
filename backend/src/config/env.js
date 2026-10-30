require('dotenv').config();
const { z } = require('zod');
const applyDatabaseUrl = require('./databaseUrl');

applyDatabaseUrl();

// "KEY=" in .env means "not set", so an empty line never breaks startup in local mode
const optional = (schema) => z.preprocess((value) => (value === '' ? undefined : value), schema.optional());

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(5000),
  DATABASE_URL: z.string().min(1, 'Set DATABASE_URL or DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD'),
  DB_SSL: z.enum(['true', 'false']).default('false').transform((value) => value === 'true'),
  JWT_ACCESS_SECRET: z.string().min(16, 'JWT_ACCESS_SECRET must be at least 16 characters'),
  JWT_ACCESS_EXPIRES: z.string().default('15m'),
  JWT_REFRESH_SECRET: z.string().min(16, 'JWT_REFRESH_SECRET must be at least 16 characters'),
  JWT_REFRESH_EXPIRES: z.string().default('7d'),
  CORS_ORIGIN: z.string().default('http://localhost:5173'),
  BCRYPT_ROUNDS: z.coerce.number().int().min(4).max(15).default(10),
  // Optional: without it the /api/v1/internal routes answer 503
  INTERNAL_API_KEY: z.string().min(32, 'INTERNAL_API_KEY must be at least 32 characters').optional(),

  // local = bcrypt passwords in booking_db (old behaviour) · sso = passwords checked by sso-pro auth-service (LDAP)
  AUTH_PROVIDER: z.enum(['local', 'sso']).default('local'),
  AUTH_SERVICE_URL: optional(z.string().url('AUTH_SERVICE_URL must be a URL like http://127.0.0.1:5002')),
  AUTH_CLIENT_ID: optional(z.string().min(1)),
  AUTH_CLIENT_SECRET: optional(z.string().min(1)),
  AUTH_TIMEOUT_MS: z.coerce.number().int().min(500).max(30000).default(3000),

  // TOTP second factor; when enforced, every ADMIN must set it up before the first login completes
  MFA_ENFORCE_ADMIN: z.enum(['true', 'false']).default('false').transform((value) => value === 'true'),
  // 64 hex chars (32 bytes) used to encrypt TOTP secrets at rest
  MFA_ENCRYPTION_KEY: optional(z.string().regex(/^[0-9a-f]{64}$/i, 'MFA_ENCRYPTION_KEY must be 64 hex characters')),
  MFA_ISSUER: z.string().min(1).default('ELEFEZ FARM'),

  // Single sign-on (KandangID OIDC): RS256 user tokens are checked with the public keys at this URL
  SSO_JWKS_URL: optional(z.string().url('SSO_JWKS_URL must be a URL like http://127.0.0.1:5002/.well-known/jwks.json')),
  SSO_ISSUER: optional(z.string().url('SSO_ISSUER must equal PUBLIC_URL of sso-pro')),
  // This API's name in the token "aud" claim
  SSO_AUDIENCE: z.string().default('booking-api'),
});

// Settings that only make sense together are checked after the basic parse
const requireTogether = (data, ctx) => {
  if (data.AUTH_PROVIDER === 'sso') {
    ['AUTH_SERVICE_URL', 'AUTH_CLIENT_ID', 'AUTH_CLIENT_SECRET'].forEach((key) => {
      if (!data[key]) ctx.addIssue({ code: 'custom', path: [key], message: `${key} is required when AUTH_PROVIDER=sso` });
    });
  }
  if (data.MFA_ENFORCE_ADMIN && !data.MFA_ENCRYPTION_KEY) {
    ctx.addIssue({ code: 'custom', path: ['MFA_ENCRYPTION_KEY'], message: 'MFA_ENCRYPTION_KEY is required when MFA_ENFORCE_ADMIN=true' });
  }
  if (data.SSO_JWKS_URL && !data.SSO_ISSUER) {
    ctx.addIssue({ code: 'custom', path: ['SSO_ISSUER'], message: 'SSO_ISSUER is required when SSO_JWKS_URL is set' });
  }
  // SSO users have no local password, so profile and password changes must go to auth-service
  if (data.SSO_JWKS_URL && data.AUTH_PROVIDER !== 'sso') {
    ctx.addIssue({ code: 'custom', path: ['AUTH_PROVIDER'], message: 'AUTH_PROVIDER must be sso when SSO_JWKS_URL is set' });
  }
};

// Fail fast on startup when required environment variables are missing
const parsed = envSchema.superRefine(requireTogether).safeParse(process.env);
if (!parsed.success) {
  console.error('Invalid environment variables:', parsed.error.flatten().fieldErrors);
  process.exit(1);
}

module.exports = {
  ...parsed.data,
  CORS_ORIGINS: parsed.data.CORS_ORIGIN.split(',').map((origin) => origin.trim()),
  AUTH_SERVICE_URL: parsed.data.AUTH_SERVICE_URL?.replace(/\/+$/, ''),
};
