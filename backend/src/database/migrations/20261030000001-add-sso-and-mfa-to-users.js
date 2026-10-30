// Prepares users for LDAP accounts (no local password) and TOTP for admins
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.changeColumn('users', 'password_hash', { type: Sequelize.TEXT, allowNull: true });
    await queryInterface.addColumn('users', 'mfa_enabled', { type: Sequelize.BOOLEAN, allowNull: false, defaultValue: false });
    await queryInterface.addColumn('users', 'mfa_secret', { type: Sequelize.TEXT });
    await queryInterface.addColumn('users', 'mfa_last_step', { type: Sequelize.BIGINT });
    await queryInterface.addColumn('users', 'mfa_setup_at', { type: Sequelize.DATE });
    await queryInterface.addColumn('users', 'last_login_at', { type: Sequelize.DATE });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.removeColumn('users', 'last_login_at');
    await queryInterface.removeColumn('users', 'mfa_setup_at');
    await queryInterface.removeColumn('users', 'mfa_last_step');
    await queryInterface.removeColumn('users', 'mfa_secret');
    await queryInterface.removeColumn('users', 'mfa_enabled');
    // Fails if LDAP-only users exist; give them a password or delete them before rolling back
    await queryInterface.changeColumn('users', 'password_hash', { type: Sequelize.TEXT, allowNull: false });
  },
};
