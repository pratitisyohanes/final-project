module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('payments', 'external_ref', { type: Sequelize.STRING(40) });
    // NULLs never collide in a unique index, so unpaid rows are fine
    await queryInterface.addIndex('payments', ['external_ref'], { unique: true, name: 'payments_external_ref_key' });
  },

  async down(queryInterface) {
    await queryInterface.removeIndex('payments', 'payments_external_ref_key');
    await queryInterface.removeColumn('payments', 'external_ref');
  },
};
