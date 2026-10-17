module.exports = (sequelize, DataTypes) => {
  const Service = sequelize.define(
    'Service',
    {
      id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
      categoryId: { type: DataTypes.INTEGER, allowNull: false },
      name: { type: DataTypes.STRING(150), allowNull: false },
      description: { type: DataTypes.TEXT },
      price: { type: DataTypes.DECIMAL(12, 2), allowNull: false },
      durationMinutes: { type: DataTypes.INTEGER, allowNull: false },
      status: { type: DataTypes.ENUM('ACTIVE', 'INACTIVE'), allowNull: false, defaultValue: 'ACTIVE' },
      imageUrl: { type: DataTypes.TEXT },
    },
    // paranoid turns destroy() into a soft delete that fills deleted_at
    { tableName: 'services', underscored: true, paranoid: true },
  );

  Service.associate = (models) => {
    Service.belongsTo(models.Category, { foreignKey: 'categoryId', as: 'category' });
    Service.hasMany(models.Schedule, { foreignKey: 'serviceId', as: 'schedules' });
    Service.hasMany(models.Booking, { foreignKey: 'serviceId', as: 'bookings' });
  };

  return Service;
};
