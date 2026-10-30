const { authenticator } = require('otplib');

jest.mock('../../src/models', () => ({ User: { scope: () => ({ findByPk: jest.fn() }) } }));

const { User } = require('../../src/models');
const jwtUtils = require('../../src/utils/jwt');
const { encrypt } = require('../../src/utils/secretBox');
const mfaService = require('../../src/modules/auth/mfa.service');

const SECRET = authenticator.generateSecret();

// Minimal stand-in for a Sequelize instance loaded with the withPassword scope
const makeUser = (values) => {
  const user = { id: '0a000000-0000-4000-8000-000000000001', email: 'admin@booking.com', role: 'ADMIN', isActive: true, mfaLastStep: null, ...values };
  user.update = jest.fn(async (changes) => Object.assign(user, changes));
  return user;
};

const mockFind = (user) => {
  const finder = { findByPk: jest.fn().mockResolvedValue(user) };
  jest.spyOn(User, 'scope').mockReturnValue(finder);
};

afterEach(() => jest.restoreAllMocks());

describe('MFA ticket', () => {
  test('cannot be used as an access token', () => {
    const ticket = jwtUtils.signMfaTicket({ id: 'u1' }, 'verify');
    expect(() => jwtUtils.verifyAccessToken(ticket)).toThrow();
  });

  test('a setup ticket is not accepted for verify', () => {
    const ticket = jwtUtils.signMfaTicket({ id: 'u1' }, 'setup');
    expect(() => jwtUtils.verifyMfaTicket(ticket, 'verify')).toThrow();
  });
});

describe('MFA login', () => {
  test('password step answers with a ticket when MFA is on', () => {
    const challenge = mfaService.challengeFor(makeUser({ mfaEnabled: true }));
    expect(challenge).toEqual({ requiresMfa: true, mfaToken: expect.any(String) });
  });

  test('no challenge for a user without MFA when not enforced', () => {
    expect(mfaService.challengeFor(makeUser({ mfaEnabled: false, role: 'USER' }))).toBeNull();
  });

  test('valid code completes the login and stores the time step', async () => {
    const user = makeUser({ mfaEnabled: true, mfaSecret: encrypt(SECRET) });
    mockFind(user);
    const ticket = jwtUtils.signMfaTicket(user, 'verify');

    await expect(mfaService.verifyLogin(ticket, authenticator.generate(SECRET))).resolves.toBe(user);
    expect(user.mfaLastStep).toEqual(expect.any(Number));
  });

  test('the same code cannot be used twice', async () => {
    const user = makeUser({ mfaEnabled: true, mfaSecret: encrypt(SECRET) });
    mockFind(user);
    const code = authenticator.generate(SECRET);

    await mfaService.verifyLogin(jwtUtils.signMfaTicket(user, 'verify'), code);
    await expect(mfaService.verifyLogin(jwtUtils.signMfaTicket(user, 'verify'), code)).rejects.toMatchObject({ statusCode: 400 });
  });

  test('wrong codes are limited per ticket', async () => {
    const user = makeUser({ mfaEnabled: true, mfaSecret: encrypt(SECRET) });
    mockFind(user);
    const ticket = jwtUtils.signMfaTicket(user, 'verify');

    for (let i = 0; i < 5; i += 1) {
      await expect(mfaService.verifyLogin(ticket, '000000')).rejects.toMatchObject({ statusCode: 400 });
    }
    await expect(mfaService.verifyLogin(ticket, authenticator.generate(SECRET))).rejects.toMatchObject({ statusCode: 429 });
  });

  test('a forged ticket is refused before any code check', async () => {
    await expect(mfaService.verifyLogin('not-a-ticket', '123456')).rejects.toMatchObject({ statusCode: 401 });
  });
});

describe('MFA setup', () => {
  test('setup returns a QR code and enable switches MFA on', async () => {
    const user = makeUser({ mfaEnabled: false, mfaSecret: null });
    mockFind(user);
    const ticket = jwtUtils.signMfaTicket(user, 'setup');

    const setup = await mfaService.startSetup(ticket);
    expect(setup.qrCode).toMatch(/^data:image\/png;base64,/);
    expect(setup.otpauthUrl).toContain('otpauth://totp/');
    expect(user.mfaSecret).not.toContain(setup.secret);

    await mfaService.finishSetup(ticket, authenticator.generate(setup.secret));
    expect(user.mfaEnabled).toBe(true);
  });
});
