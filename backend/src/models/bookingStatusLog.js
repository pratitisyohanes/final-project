const STATUSES = ['PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED'];

module.exports = (sequelize, DataTypes) => {
  const BookingStatusLog = sequelize.define(
    'BookingStatusLog',
    {
      id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
      bookingId: { type: DataTypes.UUID, allowNull: false },
      fromStatus: { type: DataTypes.ENUM(...STATUSES) },
      toStatus: { type: DataTypes.ENUM(...STATUSES), allowNull: false },
      changedById: { type: DataTypes.UUID, field: 'changed_by' },
      note: { type: DataTypes.STRING(255) },
    },
    { tableName: 'booking_status_logs', underscored: true, updatedAt: false },
  );

  BookingStatusLog.associate = (models) => {
    BookingStatusLog.belongsTo(models.Booking, { foreignKey: 'bookingId', as: 'booking' });
    BookingStatusLog.belongsTo(models.User, { foreignKey: 'changedById', as: 'changedBy' });
  };

  return BookingStatusLog;
};
