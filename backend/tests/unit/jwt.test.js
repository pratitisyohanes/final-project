const jwt = require('jsonwebtoken');
const { signAccessToken } = require('../../src/utils/jwt');

describe('access token', () => {
  test('carries id, role and name for other services', () => {
    const token = signAccessToken({ id: '0a000000-0000-4000-8000-000000000002', role: 'USER', name: 'Budi Santoso' });
    const payload = jwt.verify(token, process.env.JWT_ACCESS_SECRET);
    expect(payload).toMatchObject({ sub: '0a000000-0000-4000-8000-000000000002', role: 'USER', name: 'Budi Santoso' });
  });
});
