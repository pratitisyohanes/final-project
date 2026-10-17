module.exports = (sequelize, DataTypes) => {
  const Category = sequelize.define(
    'Category',
    {
      id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
      name: { type: DataTypes.STRING(100), allowNull: false, unique: true },
      slug: { type: DataTypes.STRING(120), allowNull: false, unique: true },
    },
    { tableName: 'categories', underscored: true },
  );

  Category.associate = (models) => {
    Category.hasMany(models.Service, { foreignKey: 'categoryId', as: 'services' });
  };

  return Category;
};
