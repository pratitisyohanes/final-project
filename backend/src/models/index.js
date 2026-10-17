const { Sequelize, DataTypes } = require('sequelize');
const env = require('../config/env');

// Single shared database connection for the whole application
const sequelize = new Sequelize(env.DATABASE_URL, {
  dialect: 'postgres',
  logging: false,
  dialectOptions: env.DB_SSL ? { ssl: { require: true, rejectUnauthorized: false } } : {},
});

const models = {
  User: require('./user')(sequelize, DataTypes),
  RefreshToken: require('./refreshToken')(sequelize, DataTypes),
  Category: require('./category')(sequelize, DataTypes),
  Service: require('./service')(sequelize, DataTypes),
  Schedule: require('./schedule')(sequelize, DataTypes),
  Booking: require('./booking')(sequelize, DataTypes),
  Payment: require('./payment')(sequelize, DataTypes),
  BookingStatusLog: require('./bookingStatusLog')(sequelize, DataTypes),
};

Object.values(models).forEach((model) => model.associate?.(models));

module.exports = { sequelize, Sequelize, ...models };
