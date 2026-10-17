const STATUSES = ['PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED'];

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('booking_status_logs', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true, allowNull: false },
      booking_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: 'bookings', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      from_status: { type: Sequelize.ENUM(...STATUSES) },
      to_status: { type: Sequelize.ENUM(...STATUSES), allowNull: false },
      changed_by: {
        type: Sequelize.UUID,
        references: { model: 'users', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      note: { type: Sequelize.STRING(255) },
      created_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.fn('NOW') },
    });
    await queryInterface.addIndex('booking_status_logs', ['booking_id']);
  },

  async down(queryInterface) {
    await queryInterface.dropTable('booking_status_logs');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_booking_status_logs_from_status";');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_booking_status_logs_to_status";');
  },
};
