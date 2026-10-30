const { User } = require('../../../models');
const ApiError = require('../../../utils/ApiError');
const authClient = require('../../../clients/authClient');

const profileOf = (account) => ({ name: account.name, email: account.email, phone: account.phone, role: account.role });

// Local row = profile cache keyed by the LDAP uid, like ERM users filled by HR Sync; bookings.user_id keeps its FK
const upsertProfile = async (account) => {
  const user = await User.scope('withPassword').findByPk(account.id);
  if (user) return user.update(profileOf(account));

  const sameEmail = await User.findOne({ where: { email: account.email } });
  if (sameEmail) throw ApiError.conflict('This email belongs to another local account; ask the admin to link it');

  return User.create({ id: account.id, ...profileOf(account), passwordHash: null });
};

// AUTH_PROVIDER=sso: the password is checked by auth-service against LDAP, never here
const authenticate = async ({ email, password }, { ip } = {}) => {
  const result = await authClient.validate(email, password, ip);
  if (!result.login) {
    if (result.reason === 'DISABLED') throw ApiError.forbidden('Your account has been deactivated');
    throw ApiError.unauthorized('Invalid email or password');
  }
  return upsertProfile(result.user);
};

// The directory entry is created first; the local profile reuses its uid
const register = async (data, { ip } = {}) => {
  const existing = await User.findOne({ where: { email: data.email } });
  if (existing) throw ApiError.conflict('Email is already registered');

  const account = await authClient.createUser(data, ip);
  return User.create({ id: account.id, ...profileOf(account), passwordHash: null });
};

// Name, phone and password live in LDAP; the local copy follows what auth-service returns
const updateProfile = async (user, data, { ip } = {}) => {
  const account = await authClient.updateUser(user.id, data, ip);
  if (!account) throw ApiError.notFound('Your account was not found in the directory');
  return user.update({ name: account.name, phone: account.phone });
};

// Every refresh re-reads the directory, so a role change or cn=disabled applies within one token lifetime
const syncOnRefresh = async (user) => {
  const account = await authClient.getUser(user.id);
  if (!account || account.disabled) throw ApiError.forbidden('Your account has been deactivated');
  return user.update(profileOf(account));
};

module.exports = { authenticate, register, updateProfile, syncOnRefresh, upsertProfile };
