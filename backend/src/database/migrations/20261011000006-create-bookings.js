module.exports = {
  async up(queryInterface, Sequelize) {
    const restrict = { onUpdate: 'CASCADE', onDelete: 'RESTRICT' };

    await queryInterface.createTable('bookings', {
      id: { type: Sequelize.UUID, primaryKey: true, allowNull: false },
      booking_code: { type: Sequelize.STRING(30), allowNull: false, unique: true },
      user_id: { type: Sequelize.UUID, allowNull: false, references: { model: 'users', key: 'id' }, ...restrict },
      service_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'services', key: 'id' }, ...restrict },
      schedule_id: { type: Sequelize.INTEGER, allowNull: false, references: { model: 'schedules', key: 'id' }, ...restrict },
      total_price: { type: Sequelize.DECIMAL(12, 2), allowNull: false },
      status: {
        type: Sequelize.ENUM('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED'),
        allowNull: false,
        defaultValue: 'PENDING',
      },
      notes: { type: Sequelize.STRING(500) },
      created_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.fn('NOW') },
      updated_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.fn('NOW') },
    });
    await queryInterface.addIndex('bookings', ['user_id', 'status']);
    await queryInterface.addIndex('bookings', ['schedule_id']);
    await queryInterface.addIndex('bookings', ['status']);
    await queryInterface.addIndex('bookings', ['created_at']);
  },

  async down(queryInterface) {
    await queryInterface.dropTable('bookings');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_bookings_status";');
  },
};
