const request = require('supertest');
const app = require('../../src/app');
const { signAccessToken } = require('../../src/utils/jwt');

const userToken = signAccessToken({ id: '00000000-0000-4000-8000-000000000001', role: 'USER' });
const adminToken = signAccessToken({ id: '00000000-0000-4000-8000-000000000002', role: 'ADMIN' });

// These requests are rejected by middleware before any database query runs
describe('request pipeline', () => {
  test('GET /health returns OK', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });

  test('unknown route returns 404 envelope', async () => {
    const res = await request(app).get('/api/v1/unknown');
    expect(res.status).toBe(404);
    expect(res.body).toMatchObject({ success: false });
  });

  test('register with invalid body returns 422 with field errors', async () => {
    const res = await request(app).post('/api/v1/auth/register').send({ name: 'A', email: 'not-an-email', password: 'short' });
    expect(res.status).toBe(422);
    expect(res.body.errors.map((e) => e.field)).toEqual(expect.arrayContaining(['name', 'email', 'password']));
  });

  test('malformed JSON returns 400', async () => {
    const res = await request(app).post('/api/v1/auth/login').set('Content-Type', 'application/json').send('{bad json');
    expect(res.status).toBe(400);
  });

  test('protected route without token returns 401', async () => {
    const res = await request(app).get('/api/v1/bookings/me');
    expect(res.status).toBe(401);
  });

  test('protected route with a forged token returns 401', async () => {
    const res = await request(app).get('/api/v1/bookings/me').set('Authorization', 'Bearer forged.token.value');
    expect(res.status).toBe(401);
  });

  test('customer cannot access admin routes', async () => {
    const res = await request(app).get('/api/v1/reports/summary').set('Authorization', `Bearer ${userToken}`);
    expect(res.status).toBe(403);
  });

  test('admin cannot create a booking', async () => {
    const res = await request(app).post('/api/v1/bookings').set('Authorization', `Bearer ${adminToken}`).send({ scheduleId: 1 });
    expect(res.status).toBe(403);
  });

  test('admin request with invalid body is rejected before the database', async () => {
    const res = await request(app)
      .post('/api/v1/schedules/bulk')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ serviceId: 1, startDate: '2026-10-20', endDate: '2026-10-10', openTime: '17:00', closeTime: '09:00' });
    expect(res.status).toBe(422);
    expect(res.body.errors.map((e) => e.field)).toEqual(expect.arrayContaining(['closeTime', 'endDate']));
  });

  test('swagger spec is served', async () => {
    const res = await request(app).get('/api/docs.json');
    expect(res.status).toBe(200);
    expect(res.body.openapi).toBe('3.0.3');
  });
});
