const authClient = require('../../src/clients/authClient');

const json = (status, body) => ({ ok: status < 400, status, json: async () => body });
const tokenResponse = json(200, { access_token: 'service-token', token_type: 'Bearer', expires_in: 900 });

beforeEach(() => authClient.resetTokenCache());
afterEach(() => jest.restoreAllMocks());

describe('auth client', () => {
  test('gets a client_credentials token, then validates with it', async () => {
    const fetchMock = jest
      .spyOn(global, 'fetch')
      .mockResolvedValueOnce(tokenResponse)
      .mockResolvedValueOnce(json(200, { data: { login: false, reason: 'INVALID_CREDENTIALS' } }));

    await expect(authClient.validate('budi@example.com', 'wrong', '10.0.0.5')).resolves.toEqual({ login: false, reason: 'INVALID_CREDENTIALS' });

    const [tokenUrl, tokenOptions] = fetchMock.mock.calls[0];
    expect(tokenUrl).toBe('http://127.0.0.1:5998/oauth/token');
    expect(String(tokenOptions.body)).toContain('grant_type=client_credentials');

    const [validateUrl, validateOptions] = fetchMock.mock.calls[1];
    expect(validateUrl).toBe('http://127.0.0.1:5998/api/v1/auth/validate');
    expect(validateOptions.headers.Authorization).toBe('Bearer service-token');
    expect(validateOptions.headers['X-Forwarded-For']).toBe('10.0.0.5');
    expect(JSON.parse(validateOptions.body)).toEqual({ username: 'budi@example.com', password: 'wrong' });
  });

  test('reuses the cached token for the next call', async () => {
    const fetchMock = jest
      .spyOn(global, 'fetch')
      .mockResolvedValueOnce(tokenResponse)
      .mockResolvedValue(json(200, { data: { id: 'u1' } }));

    await authClient.getUser('u1');
    await authClient.getUser('u1');
    const tokenCalls = fetchMock.mock.calls.filter(([url]) => url.endsWith('/oauth/token'));
    expect(tokenCalls).toHaveLength(1);
  });

  test('asks for a new token once when the old one is rejected', async () => {
    const fetchMock = jest
      .spyOn(global, 'fetch')
      .mockResolvedValueOnce(tokenResponse)
      .mockResolvedValueOnce(json(401, { message: 'Service token is invalid or expired' }))
      .mockResolvedValueOnce(tokenResponse)
      .mockResolvedValueOnce(json(200, { data: { id: 'u1' } }));

    await expect(authClient.getUser('u1')).resolves.toEqual({ id: 'u1' });
    expect(fetchMock).toHaveBeenCalledTimes(4);
  });

  test('a refused client secret becomes 503 without exposing the secret', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValueOnce(json(401, { error: 'invalid_client' }));
    const log = jest.spyOn(console, 'error').mockImplementation(() => {});

    const error = await authClient.validate('budi@example.com', 'x').catch((e) => e);
    expect(error).toMatchObject({ statusCode: 503 });
    expect(JSON.stringify(error)).not.toContain('test-client-secret');
    expect(log.mock.calls.join(' ')).not.toContain('test-client-secret');
  });

  test('service down becomes 503', async () => {
    jest.spyOn(global, 'fetch').mockRejectedValue(new Error('ECONNREFUSED'));
    await expect(authClient.validate('budi@example.com', 'x')).rejects.toMatchObject({ statusCode: 503 });
  });

  test('404 from auth-service returns null', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValueOnce(tokenResponse).mockResolvedValueOnce(json(404, { message: 'User not found' }));
    await expect(authClient.getUser('missing')).resolves.toBeNull();
  });

  test('business errors keep their status and message', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValueOnce(tokenResponse).mockResolvedValueOnce(json(409, { message: 'Email is already registered' }));
    await expect(authClient.createUser({ email: 'budi@example.com' })).rejects.toMatchObject({ statusCode: 409, message: 'Email is already registered' });
  });
});
