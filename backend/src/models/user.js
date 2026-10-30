// Fields that must never leave the server: password hash and the TOTP secret
const PRIVATE_FIELDS = ['passwordHash', 'mfaSecret', 'mfaLastStep'];

module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define(
    'User',
    {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      name: { type: DataTypes.STRING(100), allowNull: false },
      email: { type: DataTypes.STRING(150), allowNull: false, unique: true },
      phone: { type: DataTypes.STRING(20) },
      // Null for accounts whose password lives in LDAP (AUTH_PROVIDER=sso)
      passwordHash: { type: DataTypes.TEXT },
      role: { type: DataTypes.ENUM('ADMIN', 'USER'), allowNull: false, defaultValue: 'USER' },
      isActive: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
      mfaEnabled: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: false },
      // AES-256-GCM ciphertext of the TOTP secret; also holds a pending secret during setup
      mfaSecret: { type: DataTypes.TEXT },
      // Last accepted 30-second step, so one code cannot be used twice
      mfaLastStep: { type: DataTypes.BIGINT },
      mfaSetupAt: { type: DataTypes.DATE },
      lastLoginAt: { type: DataTypes.DATE },
    },
    {
      tableName: 'users',
      underscored: true,
      defaultScope: { attributes: { exclude: PRIVATE_FIELDS } },
      // Loads every column, including the private ones above
      scopes: { withPassword: {} },
    },
  );

  // Never expose private fields in API responses
  User.prototype.toJSON = function toJSON() {
    const values = { ...this.get() };
    PRIVATE_FIELDS.forEach((field) => delete values[field]);
    return values;
  };

  User.associate = (models) => {
    User.hasMany(models.Booking, { foreignKey: 'userId', as: 'bookings' });
    User.hasMany(models.RefreshToken, { foreignKey: 'userId', as: 'refreshTokens' });
    User.hasMany(models.BookingStatusLog, { foreignKey: 'changedById', as: 'statusLogs' });
  };

  return User;
};
