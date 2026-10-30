// Turn off two-factor authentication for one account, e.g. when an admin lost the phone
// Usage: node scripts/reset-mfa.js admin@booking.com
const { sequelize, User, RefreshToken } = require('../src/models');

const run = async () => {
  const email = process.argv[2];
  if (!email) {
    console.error('Usage: node scripts/reset-mfa.js <email>');
    process.exit(1);
  }

  const user = await User.findOne({ where: { email: email.trim().toLowerCase() } });
  if (!user) {
    console.error(`No user with email ${email}`);
    process.exitCode = 1;
    return;
  }

  await user.update({ mfaEnabled: false, mfaSecret: null, mfaLastStep: null, mfaSetupAt: null });
  // Old sessions end too, so the next login goes through MFA setup again when it is enforced
  await RefreshToken.destroy({ where: { userId: user.id } });
  console.log(`Two-factor authentication reset for ${user.email}`);
};

run()
  .catch((error) => {
    console.error('Failed to reset MFA:', error.message);
    process.exitCode = 1;
  })
  .finally(() => sequelize.close());
