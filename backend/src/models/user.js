module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define(
    'User',
    {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      name: { type: DataTypes.STRING(100), allowNull: false },
      email: { type: DataTypes.STRING(150), allowNull: false, unique: true },
      phone: { type: DataTypes.STRING(20) },
      passwordHash: { type: DataTypes.TEXT, allowNull: false },
      role: { type: DataTypes.ENUM('ADMIN', 'USER'), allowNull: false, defaultValue: 'USER' },
      isActive: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
    },
    {
      tableName: 'users',
      underscored: true,
      defaultScope: { attributes: { exclude: ['passwordHash'] } },
      scopes: { withPassword: {} },
    },
  );

  // Never expose the password hash in API responses
  User.prototype.toJSON = function toJSON() {
    const { passwordHash, ...values } = this.get();
    return values;
  };

  User.associate = (models) => {
    User.hasMany(models.Booking, { foreignKey: 'userId', as: 'bookings' });
    User.hasMany(models.RefreshToken, { foreignKey: 'userId', as: 'refreshTokens' });
    User.hasMany(models.BookingStatusLog, { foreignKey: 'changedById', as: 'statusLogs' });
  };

  return User;
};
