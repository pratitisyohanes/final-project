jest.mock('../../src/clients/authClient', () => ({ validate: jest.fn(), getUser: jest.fn(), createUser: jest.fn(), updateUser: jest.fn() }));
jest.mock('../../src/models', () => {
  const scoped = { findByPk: jest.fn() };
  return { User: { scope: () => scoped, findOne: jest.fn(), create: jest.fn(), scoped } };
});

const authClient = require('../../src/clients/authClient');
const { User } = require('../../src/models');
const provider = require('../../src/modules/auth/providers/sso.provider');

const account = { id: '0a000000-0000-4000-8000-000000000002', name: 'Budi Santoso', email: 'budi@example.com', phone: null, role: 'USER' };

beforeEach(() => jest.clearAllMocks());

describe('sso provider', () => {
  test('wrong password from LDAP becomes 401 with the usual message', async () => {
    authClient.validate.mockResolvedValue({ login: false, reason: 'INVALID_CREDENTIALS' });
    await expect(provider.authenticate({ email: 'budi@example.com', password: 'x' })).rejects.toMatchObject({
      statusCode: 401,
      message: 'Invalid email or password',
    });
  });

  test('cn=disabled becomes 403', async () => {
    authClient.validate.mockResolvedValue({ login: false, reason: 'DISABLED' });
    await expect(provider.authenticate({ email: 'budi@example.com', password: 'x' })).rejects.toMatchObject({ statusCode: 403 });
  });

  test('first login creates the local profile with the LDAP uid and no password', async () => {
    authClient.validate.mockResolvedValue({ login: true, user: account });
    User.scoped.findByPk.mockResolvedValue(null);
    User.findOne.mockResolvedValue(null);
    User.create.mockImplementation(async (data) => data);

    const user = await provider.authenticate({ email: 'budi@example.com', password: 'User12345' });
    expect(user).toEqual({ ...account, passwordHash: null });
  });

  test('later logins copy name and role from LDAP onto the local row', async () => {
    const local = { update: jest.fn(async (data) => data) };
    authClient.validate.mockResolvedValue({ login: true, user: { ...account, role: 'ADMIN' } });
    User.scoped.findByPk.mockResolvedValue(local);

    await provider.authenticate({ email: 'budi@example.com', password: 'User12345' });
    expect(local.update).toHaveBeenCalledWith({ name: 'Budi Santoso', email: 'budi@example.com', phone: null, role: 'ADMIN' });
  });

  test('refresh refuses a user moved to cn=disabled', async () => {
    authClient.getUser.mockResolvedValue({ ...account, disabled: true });
    await expect(provider.syncOnRefresh({ id: account.id, update: jest.fn() })).rejects.toMatchObject({ statusCode: 403 });
  });
});
