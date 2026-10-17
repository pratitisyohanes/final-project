const { Op } = require('sequelize');
const { sequelize, Service, Category, Schedule, Booking } = require('../../models');
const ApiError = require('../../utils/ApiError');
const compact = require('../../utils/compact');
const { getPagination, buildMeta, getSort } = require('../../utils/pagination');
const { todayWib } = require('../../utils/time');
const { ACTIVE_STATUSES } = require('../bookings/bookings.rules');

const categoryInclude = { model: Category, as: 'category', attributes: ['id', 'name', 'slug'] };

const isAdmin = (user) => user?.role === 'ADMIN';

// Guests and customers only see active services; soft-deleted rows are hidden by paranoid mode
const listServices = async (query, user) => {
  const pagination = getPagination(query);
  const where = compact({
    categoryId: query.categoryId,
    status: isAdmin(user) ? query.status : 'ACTIVE',
  });

  if (query.search) {
    const pattern = { [Op.iLike]: `%${query.search}%` };
    where[Op.or] = [{ name: pattern }, { description: pattern }, { '$category.name$': pattern }];
  }

  if (query.minPrice !== undefined || query.maxPrice !== undefined) {
    where.price = {};
    if (query.minPrice !== undefined) where.price[Op.gte] = query.minPrice;
    if (query.maxPrice !== undefined) where.price[Op.lte] = query.maxPrice;
  }

  const { rows, count } = await Service.findAndCountAll({
    where,
    include: [categoryInclude],
    offset: pagination.offset,
    limit: pagination.limit,
    order: getSort(query.sort, ['name', 'price', 'durationMinutes', 'createdAt']),
  });

  return { items: rows, meta: buildMeta(pagination, count) };
};

const getServiceById = async (id, user) => {
  const service = await Service.findOne({
    where: compact({ id, status: isAdmin(user) ? undefined : 'ACTIVE' }),
    include: [categoryInclude],
  });
  if (!service) throw ApiError.notFound('Service not found');
  return service;
};

const ensureCategoryExists = async (categoryId) => {
  if (categoryId === undefined) return;
  const category = await Category.findByPk(categoryId);
  if (!category) throw ApiError.notFound('Category not found');
};

const createService = async (data) => {
  await ensureCategoryExists(data.categoryId);
  const service = await Service.create(data);
  return getServiceById(service.id, { role: 'ADMIN' });
};

const updateService = async (id, data) => {
  const service = await getServiceById(id, { role: 'ADMIN' });
  await ensureCategoryExists(data.categoryId);
  await service.update(data);
  return getServiceById(id, { role: 'ADMIN' });
};

// Soft delete keeps booking history intact and closes future slots
const deleteService = async (id) => {
  const service = await getServiceById(id, { role: 'ADMIN' });
  const today = todayWib();

  const activeBookings = await Booking.count({
    where: { serviceId: id, status: { [Op.in]: ACTIVE_STATUSES } },
    include: [{ model: Schedule, as: 'schedule', attributes: [], where: { date: { [Op.gte]: today } } }],
  });
  if (activeBookings > 0) {
    throw ApiError.conflict(`Service still has ${activeBookings} upcoming booking(s); cancel them first`);
  }

  await sequelize.transaction(async (transaction) => {
    await service.update({ status: 'INACTIVE' }, { transaction });
    await service.destroy({ transaction });
    await Schedule.update({ status: 'CLOSED' }, { where: { serviceId: id, date: { [Op.gte]: today } }, transaction });
  });
};

module.exports = { listServices, getServiceById, createService, updateService, deleteService };
