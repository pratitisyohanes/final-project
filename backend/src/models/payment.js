module.exports = (sequelize, DataTypes) => {
  const Payment = sequelize.define(
    'Payment',
    {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      bookingId: { type: DataTypes.UUID, allowNull: false, unique: true },
      amount: { type: DataTypes.DECIMAL(12, 2), allowNull: false },
      method: { type: DataTypes.ENUM('CASH', 'TRANSFER', 'EWALLET') },
      status: { type: DataTypes.ENUM('UNPAID', 'PAID', 'REFUNDED'), allowNull: false, defaultValue: 'UNPAID' },
      paidAt: { type: DataTypes.DATE },
      // Invoice number of the POS sale that settled this booking
      externalRef: { type: DataTypes.STRING(40), unique: true },
    },
    { tableName: 'payments', underscored: true },
  );

  Payment.associate = (models) => {
    Payment.belongsTo(models.Booking, { foreignKey: 'bookingId', as: 'booking' });
  };

  return Payment;
};
