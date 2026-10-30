const env = require('../../../config/env');

// Both providers expose the same functions, so auth.service never checks which one is active
module.exports = env.AUTH_PROVIDER === 'sso' ? require('./sso.provider') : require('./local.provider');
