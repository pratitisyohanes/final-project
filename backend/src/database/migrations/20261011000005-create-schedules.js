module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('schedules', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true, allowNull: false },
      service_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'services', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT',
      },
      date: { type: Sequelize.DATEONLY, allowNull: false },
      start_time: { type: Sequelize.STRING(5), allowNull: false },
      end_time: { type: Sequelize.STRING(5), allowNull: false },
      capacity: { type: Sequelize.INTEGER, allowNull: false, defaultValue: 1 },
      booked_count: { type: Sequelize.INTEGER, allowNull: false, defaultValue: 0 },
      status: { type: Sequelize.ENUM('AVAILABLE', 'FULL', 'CLOSED'), allowNull: false, defaultValue: 'AVAILABLE' },
      created_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.fn('NOW') },
      updated_at: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.fn('NOW') },
    });
    await queryInterface.addIndex('schedules', ['service_id', 'date', 'start_time'], { unique: true });
    await queryInterface.addIndex('schedules', ['date', 'status']);
  },

  async down(queryInterface) {
    await queryInterface.dropTable('schedules');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_schedules_status";');
  },
};
