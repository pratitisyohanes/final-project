module.exports = (sequelize, DataTypes) => {
  const Booking = sequelize.define(
    'Booking',
    {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      bookingCode: { type: DataTypes.STRING(30), allowNull: false, unique: true },
      userId: { type: DataTypes.UUID, allowNull: false },
      serviceId: { type: DataTypes.INTEGER, allowNull: false },
      scheduleId: { type: DataTypes.INTEGER, allowNull: false },
      totalPrice: { type: DataTypes.DECIMAL(12, 2), allowNull: false },
      status: {
        type: DataTypes.ENUM('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED'),
        allowNull: false,
        defaultValue: 'PENDING',
      },
      notes: { type: DataTypes.STRING(500) },
    },
    { tableName: 'bookings', underscored: true },
  );

  Booking.associate = (models) => {
    Booking.belongsTo(models.User, { foreignKey: 'userId', as: 'user' });
    Booking.belongsTo(models.Service, { foreignKey: 'serviceId', as: 'service' });
    Booking.belongsTo(models.Schedule, { foreignKey: 'scheduleId', as: 'schedule' });
    Booking.hasOne(models.Payment, { foreignKey: 'bookingId', as: 'payment' });
    Booking.hasMany(models.BookingStatusLog, { foreignKey: 'bookingId', as: 'logs' });
  };

  return Booking;
};
