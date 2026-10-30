const { encrypt, decrypt } = require('../../src/utils/secretBox');

describe('secret box (TOTP secrets at rest)', () => {
  test('round-trips and never stores the plain secret', () => {
    const stored = encrypt('JBSWY3DPEHPK3PXP');
    expect(stored).not.toContain('JBSWY3DPEHPK3PXP');
    expect(decrypt(stored)).toBe('JBSWY3DPEHPK3PXP');
  });

  test('same secret encrypts differently each time', () => {
    expect(encrypt('JBSWY3DPEHPK3PXP')).not.toBe(encrypt('JBSWY3DPEHPK3PXP'));
  });

  test('a modified value is rejected', () => {
    const [iv, tag, data] = encrypt('JBSWY3DPEHPK3PXP').split('.');
    const tampered = [iv, tag, `${data.slice(0, -2)}AA`].join('.');
    expect(() => decrypt(tampered)).toThrow();
  });
});
