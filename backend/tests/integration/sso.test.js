const http = require('http');
const crypto = require('crypto');
const request = require('supertest');
const { SignJWT, exportJWK } = require('jose');

// Real models, but the three User calls used by provisioning are replaced so no database is needed
jest.mock('../../src/models', () => {
  const actual = jest.requireActual('../../src/models');
  actual.User.findByPk = jest.fn();
  actual.User.findOne = jest.fn();
  actual.User.create = jest.fn();
  return actual;
});

const { User } = require('../../src/models');
const { forgetProfile } = require('../../src/modules/auth/ssoProfile.service');
const app = require('../../src/app');

// A stand-in KandangID: its own key pair and a JWKS endpoint on the port from tests/setup.js
const { privateKey, publicKey } = crypto.generateKeyPairSync('rsa', { modulusLength: 2048 });
let server;

beforeAll(async () => {
  const jwks = { keys: [{ ...(await exportJWK(publicKey)), kid: 'test-kid', alg: 'RS256', use: 'sig' }] };
  server = http.createServer((req, res) => {
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify(jwks));
  });
  await new Promise((resolve) => server.listen(5995, '127.0.0.1', resolve));
});

afterAll(() => new Promise((resolve) => server.close(resolve)));

const SUB = '0a000000-0000-4000-8000-0000000000aa';

beforeEach(() => {
  jest.clearAllMocks();
  forgetProfile(SUB);
  User.findByPk.mockResolvedValue(null);
  User.findOne.mockResolvedValue(null);
  User.create.mockImplementation(async (data) => ({ ...data, isActive: true }));
});

const ssoToken = ({ role = 'USER', audience = ['booking-api', 'pos-api'] } = {}) =>
  new SignJWT({ role, name: 'Rina Wulandari', email: 'rina@example.com' })
    .setProtectedHeader({ alg: 'RS256', kid: 'test-kid' })
    .setIssuer('http://localhost:5002')
    .setSubject(SUB)
    .setAudience(audience)
    .setIssuedAt()
    .setExpirationTime('5m')
    .sign(privateKey);

describe('KandangID tokens in booking-api', () => {
  test('first request of a new SSO user creates the local profile row', async () => {
    const res = await request(app).get('/api/v1/reports/summary').set('Authorization', `Bearer ${await ssoToken()}`);
    expect(res.status).toBe(403);
    expect(User.create).toHaveBeenCalledWith({ id: SUB, name: 'Rina Wulandari', email: 'rina@example.com', role: 'USER', passwordHash: null });
  });

  test('the profile is checked at most once a minute', async () => {
    const token = await ssoToken();
    await request(app).get('/api/v1/reports/summary').set('Authorization', `Bearer ${token}`);
    await request(app).get('/api/v1/reports/summary').set('Authorization', `Bearer ${token}`);
    expect(User.findByPk).toHaveBeenCalledTimes(1);
  });

  test('role changes in LDAP reach the local row', async () => {
    const local = { id: SUB, name: 'Rina Wulandari', email: 'rina@example.com', role: 'USER', isActive: true, update: jest.fn() };
    User.findByPk.mockResolvedValue(local);
    await request(app).get('/api/v1/reports/summary').set('Authorization', `Bearer ${await ssoToken({ role: 'ADMIN' })}`);
    expect(local.update).toHaveBeenCalledWith({ name: 'Rina Wulandari', email: 'rina@example.com', role: 'ADMIN' });
  });

  test('a user deactivated by the booking admin is refused', async () => {
    User.findByPk.mockResolvedValue({ id: SUB, name: 'Rina Wulandari', email: 'rina@example.com', role: 'USER', isActive: false });
    const res = await request(app).get('/api/v1/bookings/me').set('Authorization', `Bearer ${await ssoToken()}`);
    expect(res.status).toBe(403);
    expect(res.body.message).toBe('Your account has been deactivated');
  });

  test('an email already used by another local account is a conflict, not a silent merge', async () => {
    User.findOne.mockResolvedValue({ id: 'someone-else' });
    const res = await request(app).get('/api/v1/bookings/me').set('Authorization', `Bearer ${await ssoToken()}`);
    expect(res.status).toBe(409);
    expect(User.create).not.toHaveBeenCalled();
  });

  test('a token for pos-api only is refused here', async () => {
    const res = await request(app).get('/api/v1/bookings/me').set('Authorization', `Bearer ${await ssoToken({ audience: 'pos-api' })}`);
    expect(res.status).toBe(401);
  });
});
