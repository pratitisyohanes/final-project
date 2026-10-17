const { Op } = require('sequelize');
const { sequelize, User, Booking, Service, Schedule, RefreshToken } = require('../../models');
const ApiError = require('../../utils/ApiError');
const compact = require('../../utils/compact');
const { getPagination, buildMeta, getSort } = require('../../utils/pagination');

// Booking count as a subquery so pagination stays a simple single-table query
const bookingCount = [
  sequelize.literal('(SELECT COUNT(*)::int FROM bookings b WHERE b.user_id = "User"."id")'),
  'bookingCount',
];

// Admin view of customers (role USER) with their booking count
const listCustomers = async (query) => {
  const pagination = getPagination(query);
  const where = compact({ role: 'USER', isActive: query.isActive });

  if (query.search) {
    where[Op.or] = ['name', 'email', 'phone'].map((field) => ({ [field]: { [Op.iLike]: `%${query.search}%` } }));
  }

  const { rows, count } = await User.findAndCountAll({
    where,
    attributes: { include: [bookingCount] },
    offset: pagination.offset,
    limit: pagination.limit,
    order: getSort(query.sort, ['name', 'email', 'createdAt']),
  });

  return { items: rows, meta: buildMeta(pagination, count) };
};

const getCustomerById = async (id) => {
  const user = await User.findOne({
    where: { id, role: 'USER' },
    attributes: { include: [bookingCount] },
    include: [
      {
        model: Booking,
        as: 'bookings',
        separate: true,
        limit: 10,
        order: [['createdAt', 'DESC']],
        include: [
          { model: Service, as: 'service', attributes: ['id', 'name'], paranoid: false },
          { model: Schedule, as: 'schedule', attributes: ['date', 'startTime', 'endTime'] },
        ],
      },
    ],
  });
  if (!user) throw ApiError.notFound('Customer not found');
  return user;
};

const updateCustomer = async (id, data) => {
  const user = await User.findOne({ where: { id, role: 'USER' } });
  if (!user) throw ApiError.notFound('Customer not found');
  await user.update(data);

  // Deactivated users lose every active session
  if (data.isActive === false) await RefreshToken.destroy({ where: { userId: id } });

  return user;
};

module.exports = { listCustomers, getCustomerById, updateCustomer };
