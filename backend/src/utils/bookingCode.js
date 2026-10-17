const crypto = require('crypto');
const { todayWib } = require('./time');

// Readable unique code, e.g. BK-20261011-7F3A9C
const generateBookingCode = () => {
  const datePart = todayWib().replace(/-/g, '');
  const randomPart = crypto.randomBytes(3).toString('hex').toUpperCase();
  return `BK-${datePart}-${randomPart}`;
};

module.exports = generateBookingCode;
