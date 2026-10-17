const { Op } = require('sequelize');
const { sequelize, Schedule, Service, Booking, User } = require('../../models');
const ApiError = require('../../utils/ApiError');
const compact = require('../../utils/compact');
const { getPagination, buildMeta } = require('../../utils/pagination');
const { resolveDateRange, toDateFilter } = require('../../utils/dateRange');
const {
  addMinutes,
  addDays,
  isOverlapping,
  toDateTime,
  todayWib,
  isoDayOfWeek,
  diffInDays,
  generateSlots,
} = require('../../utils/time');
const { ACTIVE_STATUSES } = require('../bookings/bookings.rules');
const { MAX_RANGE_DAYS } = require('./schedules.schema');

const DEFAULT_WINDOW_DAYS = 7;
const MIDNIGHT = '24:00';
const serviceSummary = { model: Service, as: 'service', attributes: ['id', 'name', 'durationMinutes'], paranoid: false };

const withRemaining = (schedule) => {
  const data = schedule.toJSON();
  return { ...data, remaining: Math.max(data.capacity - data.bookedCount, 0) };
};

// FULL and AVAILABLE are derived from the booked count, CLOSED is set manually by admin
const resolveStatus = (requestedStatus, bookedCount, capacity) => {
  if (requestedStatus === 'CLOSED') return 'CLOSED';
  return bookedCount >= capacity ? 'FULL' : 'AVAILABLE';
};

const getBookableService = async (serviceId, transaction) => {
  const service = await Service.findByPk(serviceId, { transaction });
  if (!service) throw ApiError.notFound('Service not found');
  if (service.status !== 'ACTIVE') throw ApiError.badRequest('Service is inactive');
  return service;
};

const findOverlap = ({ serviceId, date, startTime, endTime, excludeId }, transaction) =>
  Schedule.findOne({
    where: {
      serviceId,
      date,
      startTime: { [Op.lt]: endTime },
      endTime: { [Op.gt]: startTime },
      ...(excludeId && { id: { [Op.ne]: excludeId } }),
    },
    transaction,
  });

const assertNotPast = (date, startTime) => {
  if (toDateTime(date, startTime) <= new Date()) throw ApiError.badRequest('Schedule time must be in the future');
};

// Public: bookable slots of one service for a date or a range (default next 7 days)
const listAvailableSchedules = async (serviceId, query) => {
  const service = await getBookableService(serviceId);
  const today = todayWib();
  const range = query.date ? { start: query.date, end: query.date } : resolveDateRange(query) || {};

  const start = range.start && range.start > today ? range.start : today;
  const end = range.end || addDays(start, DEFAULT_WINDOW_DAYS - 1);
  if (diffInDays(start, end) >= MAX_RANGE_DAYS) throw ApiError.badRequest(`Range must be at most ${MAX_RANGE_DAYS} days`);

  const schedules = await Schedule.findAll({
    where: { serviceId, status: 'AVAILABLE', date: { [Op.between]: [start, end] } },
    order: [['date', 'ASC'], ['startTime', 'ASC']],
  });

  const now = new Date();
  return {
    service: { id: service.id, name: service.name, price: service.price, durationMinutes: service.durationMinutes },
    schedules: schedules.filter((s) => toDateTime(s.date, s.startTime) > now).map(withRemaining),
  };
};

const listSchedules = async (query) => {
  const pagination = getPagination(query);
  const where = compact({
    serviceId: query.serviceId,
    status: query.status,
    date: toDateFilter(resolveDateRange(query)),
  });

  const { rows, count } = await Schedule.findAndCountAll({
    where,
    include: [serviceSummary],
    offset: pagination.offset,
    limit: pagination.limit,
    order: [['date', 'ASC'], ['startTime', 'ASC']],
  });

  return { items: rows.map(withRemaining), meta: buildMeta(pagination, count) };
};

const getScheduleById = async (id) => {
  const schedule = await Schedule.findByPk(id, {
    include: [
      serviceSummary,
      {
        model: Booking,
        as: 'bookings',
        required: false,
        where: { status: { [Op.in]: ACTIVE_STATUSES } },
        attributes: ['id', 'bookingCode', 'status'],
        include: [{ model: User, as: 'user', attributes: ['id', 'name', 'email'] }],
      },
    ],
  });
  if (!schedule) throw ApiError.notFound('Schedule not found');
  return withRemaining(schedule);
};

const createSchedule = async ({ serviceId, date, startTime, capacity }) => {
  const service = await getBookableService(serviceId);
  assertNotPast(date, startTime);

  const endTime = addMinutes(startTime, service.durationMinutes);
  if (endTime > MIDNIGHT) throw ApiError.badRequest('Schedule must end before midnight');

  const overlap = await findOverlap({ serviceId, date, startTime, endTime });
  if (overlap) throw ApiError.conflict(`Schedule overlaps with existing slot ${overlap.startTime}-${overlap.endTime}`);

  const schedule = await Schedule.create({ serviceId, date, startTime, endTime, capacity });
  return withRemaining(schedule);
};

// Generate back-to-back slots for a date range, skipping past and overlapping ones
const bulkCreateSchedules = async ({ serviceId, startDate, endDate, openTime, closeTime, capacity, daysOfWeek }) => {
  const service = await getBookableService(serviceId);
  const slots = generateSlots(openTime, closeTime, service.durationMinutes);
  if (slots.length === 0) throw ApiError.badRequest('Opening window is shorter than the service duration');

  const existing = await Schedule.findAll({
    where: { serviceId, date: { [Op.between]: [startDate, endDate] } },
    attributes: ['date', 'startTime', 'endTime'],
  });

  const now = new Date();
  const rows = [];
  let skipped = 0;

  for (let date = startDate; date <= endDate; date = addDays(date, 1)) {
    if (!daysOfWeek.includes(isoDayOfWeek(date))) continue;
    const sameDay = existing.filter((e) => e.date === date);

    slots.forEach((slot) => {
      const isPast = toDateTime(date, slot.startTime) <= now;
      const clashes = sameDay.some((e) => isOverlapping(slot.startTime, slot.endTime, e.startTime, e.endTime));
      if (isPast || clashes) {
        skipped += 1;
        return;
      }
      rows.push({ serviceId, date, startTime: slot.startTime, endTime: slot.endTime, capacity });
    });
  }

  const created = await Schedule.bulkCreate(rows, { ignoreDuplicates: true });
  return { created: created.length, skipped };
};

const updateSchedule = async (id, body) =>
  sequelize.transaction(async (transaction) => {
    const schedule = await Schedule.findByPk(id, { transaction, lock: transaction.LOCK.UPDATE });
    if (!schedule) throw ApiError.notFound('Schedule not found');

    const data = {};

    if (body.date || body.startTime) {
      if (schedule.bookedCount > 0) throw ApiError.conflict('Cannot move a schedule that already has bookings');
      const service = await Service.findByPk(schedule.serviceId, { transaction, paranoid: false });
      const date = body.date || schedule.date;
      const startTime = body.startTime || schedule.startTime;
      const endTime = addMinutes(startTime, service.durationMinutes);

      assertNotPast(date, startTime);
      if (endTime > MIDNIGHT) throw ApiError.badRequest('Schedule must end before midnight');

      const overlap = await findOverlap({ serviceId: schedule.serviceId, date, startTime, endTime, excludeId: id }, transaction);
      if (overlap) throw ApiError.conflict(`Schedule overlaps with existing slot ${overlap.startTime}-${overlap.endTime}`);

      Object.assign(data, { date, startTime, endTime });
    }

    const capacity = body.capacity ?? schedule.capacity;
    if (capacity < schedule.bookedCount) {
      throw ApiError.conflict(`Capacity cannot be lower than the booked count (${schedule.bookedCount})`);
    }

    data.capacity = capacity;
    data.status = resolveStatus(body.status ?? schedule.status, schedule.bookedCount, capacity);

    await schedule.update(data, { transaction });
    return withRemaining(schedule);
  });

// Schedules with any booking history are kept; admins should close them instead
const deleteSchedule = async (id) => {
  const schedule = await Schedule.findByPk(id);
  if (!schedule) throw ApiError.notFound('Schedule not found');
  const bookings = await Booking.count({ where: { scheduleId: id } });
  if (bookings > 0) throw ApiError.conflict('Schedule has booking history; close it instead of deleting');
  await schedule.destroy();
};

module.exports = {
  listAvailableSchedules,
  listSchedules,
  getScheduleById,
  createSchedule,
  bulkCreateSchedules,
  updateSchedule,
  deleteSchedule,
  resolveStatus,
};
