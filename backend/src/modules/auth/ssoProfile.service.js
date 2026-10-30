const { User } = require('../../models');
const ApiError = require('../../utils/ApiError');

// Checked at most once a minute per user, so a busy page does not write to users on every request
const CHECK_EVERY_MS = 60 * 1000;
const checked = new Map();

const profileOf = (claims) => ({ name: claims.name, email: claims.email, role: claims.role });

const changed = (user, profile) => Object.entries(profile).some(([key, value]) => value !== undefined && user[key] !== value);

// A KandangID user may never have used Booking before: create the local row bookings.user_id points to,
// and keep name, email and role in step with the token. Returns false when the admin deactivated the user here.
const ensureLocalUser = async (claims) => {
  const cached = checked.get(claims.sub);
  if (cached && Date.now() - cached.at < CHECK_EVERY_MS) return cached.isActive;

  const profile = profileOf(claims);
  let user = await User.findByPk(claims.sub);
  if (!user) {
    const sameEmail = await User.findOne({ where: { email: profile.email } });
    if (sameEmail) throw ApiError.conflict('This email belongs to another local account; ask the admin to link it');
    user = await User.create({ id: claims.sub, ...profile, passwordHash: null });
  } else if (changed(user, profile)) {
    await user.update(profile);
  }

  checked.set(claims.sub, { at: Date.now(), isActive: user.isActive });
  return user.isActive;
};

// Called when an admin changes a customer here, so the next request sees it at once
const forgetProfile = (userId) => checked.delete(userId);

module.exports = { ensureLocalUser, forgetProfile };
