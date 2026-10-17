module.exports = (sequelize, DataTypes) => {
  const Schedule = sequelize.define(
    'Schedule',
    {
      id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
      serviceId: { type: DataTypes.INTEGER, allowNull: false },
      date: { type: DataTypes.DATEONLY, allowNull: false },
      startTime: { type: DataTypes.STRING(5), allowNull: false },
      endTime: { type: DataTypes.STRING(5), allowNull: false },
      capacity: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 1 },
      bookedCount: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
      status: { type: DataTypes.ENUM('AVAILABLE', 'FULL', 'CLOSED'), allowNull: false, defaultValue: 'AVAILABLE' },
    },
    { tableName: 'schedules', underscored: true },
  );

  Schedule.associate = (models) => {
    Schedule.belongsTo(models.Service, { foreignKey: 'serviceId', as: 'service' });
    Schedule.hasMany(models.Booking, { foreignKey: 'scheduleId', as: 'bookings' });
  };

  return Schedule;
};
