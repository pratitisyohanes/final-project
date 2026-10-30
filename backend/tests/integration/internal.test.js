const request = require('supertest');
const app = require('../../src/app');
const { signAccessToken } = require('../../src/utils/jwt');

const KEY = process.env.INTERNAL_API_KEY;

// These requests stop in middleware, so no database is needed
describe('internal API for pos-api', () => {
  test('rejects calls without the service key', async () => {
    const res = await request(app).get('/api/v1/internal/bookings/BK-SEED-0001');
    expect(res.status).toBe(401);
  });

  test('rejects a wrong service key', async () => {
    const res = await request(app).get('/api/v1/internal/bookings/BK-SEED-0001').set('X-Internal-Key', 'x'.repeat(KEY.length));
    expect(res.status).toBe(401);
  });

  test('does not accept a user JWT instead of the service key', async () => {
    const token = signAccessToken({ id: '0a000000-0000-4000-8000-000000000001', role: 'ADMIN', name: 'Admin' });
    const res = await request(app).get('/api/v1/internal/bookings/BK-SEED-0001').set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(401);
  });

  test('validates the booking code before touching the database', async () => {
    const res = await request(app).get('/api/v1/internal/bookings/not-a-code').set('X-Internal-Key', KEY);
    expect(res.status).toBe(422);
  });

  test('validates the settle body', async () => {
    const res = await request(app)
      .post('/api/v1/internal/bookings/BK-SEED-0001/settle')
      .set('X-Internal-Key', KEY)
      .send({ method: 'BITCOIN', amount: -5 });
    expect(res.status).toBe(422);
    expect(res.body.errors.map((e) => e.field)).toEqual(expect.arrayContaining(['method', 'amount', 'externalRef']));
  });
});
