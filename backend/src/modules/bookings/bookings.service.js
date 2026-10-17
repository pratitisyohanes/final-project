const { Op } = require('sequelize');
const { sequelize, Booking, Schedule, Service, User, Payment, BookingStatusLog } = require('../../models');
const ApiError = require('../../utils/ApiError');
const compact = require('../../utils/compact');
const generateBookingCode = require('../../utils/bookingCode');
const { getPagination, buildMeta, getSort } = require('../../utils/pagination');
const { resolveDateRange, toDateFilter } = require('../../utils/dateRange');
const { toDateTime } = require('../../utils/time');
const {
  ACTIVE_STATUSES,
  CANCEL_DEADLINE_HOURS,
  canTransition,
  isBeforeCancelDeadline,
} = require('./bookings.rules');

// Service include ignores soft delete so history still shows deleted services
const bookingInclude = (scheduleWhere) => [
  { model: Service, as: 'service', attributes: ['id', 'name', 'price', 'durationMinutes'], paranoid: false },
  {
    model: Schedule,
    as: 'schedule',
    attributes: ['id', 'date', 'startTime', 'endTime'],
    ...(scheduleWhere && { where: scheduleWhere }),
  },
  { model: User, as: 'user', attributes: ['id', 'name', 'email', 'phone'] },
  { model: Payment, as: 'payment' },
];

const findBookingDetail = (id, transaction) => Booking.findByPk(id, { include: bookingInclude(), transaction });

// Every query below receives { transaction } and the schedule row is locked with FOR UPDATE
const createBooking = async (userId, { scheduleId, notes }) =>
  sequelize.transaction(async (transaction) => {
    const slot = await Schedule.findByPk(scheduleId, { transaction, lock: transaction.LOCK.UPDATE });
    const service = slot && (await Service.findByPk(slot.serviceId, { transaction }));

    if (!slot || !service || service.status !== 'ACTIVE') throw ApiError.notFound('Schedule not found');
    if (toDateTime(slot.date, slot.startTime) <= new Date()) {
      throw ApiError.badRequest('This schedule has already started or passed');
    }
    if (slot.status === 'CLOSED') throw ApiError.conflict('This schedule is closed for booking');
    if (slot.bookedCount >= slot.capacity) throw ApiError.conflict('This schedule is fully booked');

    // Same rule as slot overlap: existing.start < new.end AND existing.end > new.start
    const clash = await Booking.findOne({
      where: { userId, status: { [Op.in]: ACTIVE_STATUSES } },
      attributes: ['bookingCode'],
      include: [
        {
          model: Schedule,
          as: 'schedule',
          attributes: [],
          where: { date: slot.date, startTime: { [Op.lt]: slot.endTime }, endTime: { [Op.gt]: slot.startTime } },
        },
      ],
      transaction,
    });
    if (clash) throw ApiError.conflict(`You already have booking ${clash.bookingCode} at an overlapping time`);

    const booking = await Booking.create(
      {
        bookingCode: generateBookingCode(),
        userId,
        serviceId: slot.serviceId,
        scheduleId: slot.id,
        totalPrice: service.price,
        notes,
        payment: { amount: service.price },
        logs: [{ toStatus: 'PENDING', changedById: userId, note: 'Booking created' }],
      },
      {
        include: [
          { model: Payment, as: 'payment' },
          { model: BookingStatusLog, as: 'logs' },
        ],
        transaction,
      },
    );

    const bookedCount = slot.bookedCount + 1;
    await slot.update({ bookedCount, status: bookedCount >= slot.capacity ? 'FULL' : slot.status }, { transaction });

    return findBookingDetail(booking.id, transaction);
  });

// Give the seat back to the schedule when a booking is cancelled
const releaseSlot = async (scheduleId, transaction) => {
  const slot = await Schedule.findByPk(scheduleId, { transaction, lock: transaction.LOCK.UPDATE });
  const bookedCount = Math.max(slot.bookedCount - 1, 0);
  await slot.update({ bookedCount, status: slot.status === 'FULL' ? 'AVAILABLE' : slot.status }, { transaction });
};

// Apply a validated status change, write the audit log and run side effects
const applyStatusChange = async ({ booking, payment }, toStatus, actorId, note, transaction) => {
  if (!canTransition(booking.status, toStatus)) {
    throw ApiError.badRequest(`Cannot change booking status from ${booking.status} to ${toStatus}`);
  }

  if (toStatus === 'CANCELLED') {
    await releaseSlot(booking.scheduleId, transaction);
    if (payment?.status === 'PAID') await payment.update({ status: 'REFUNDED' }, { transaction });
  }

  await BookingStatusLog.create(
    { bookingId: booking.id, fromStatus: booking.status, toStatus, changedById: actorId, note },
    { transaction },
  );
  await booking.update({ status: toStatus }, { transaction });

  return findBookingDetail(booking.id, transaction);
};

const findBookingForUpdate = async (id, transaction) => {
  const booking = await Booking.findByPk(id, { transaction, lock: transaction.LOCK.UPDATE });
  if (!booking) throw ApiError.notFound('Booking not found');
  const [schedule, payment] = await Promise.all([
    booking.getSchedule({ transaction }),
    booking.getPayment({ transaction }),
  ]);
  return { booking, schedule, payment };
};

const cancelBooking = async (id, actor, reason) =>
  sequelize.transaction(async (transaction) => {
    const record = await findBookingForUpdate(id, transaction);
    const isAdmin = actor.role === 'ADMIN';

    if (!isAdmin && record.booking.userId !== actor.id) throw ApiError.forbidden('You can only cancel your own booking');

    const slotStart = toDateTime(record.schedule.date, record.schedule.startTime);
    if (!isAdmin && !isBeforeCancelDeadline(slotStart)) {
      throw ApiError.badRequest(`Bookings can only be cancelled at least ${CANCEL_DEADLINE_HOURS} hours in advance`);
    }

    const note = reason || (isAdmin ? 'Cancelled by admin' : 'Cancelled by customer');
    return applyStatusChange(record, 'CANCELLED', actor.id, note, transaction);
  });

const updateBookingStatus = async (id, { status, note }, actorId) =>
  sequelize.transaction(async (transaction) => {
    const record = await findBookingForUpdate(id, transaction);

    const slotStart = toDateTime(record.schedule.date, record.schedule.startTime);
    if (status === 'COMPLETED' && slotStart > new Date()) {
      throw ApiError.badRequest('A booking can only be completed after its schedule has started');
    }

    return applyStatusChange(record, status, actorId, note, transaction);
  });

// Date filters (from/to/period) apply to the service date, not the booking creation date
const paginate = async (where, query) => {
  const pagination = getPagination(query);
  const dateFilter = toDateFilter(resolveDateRange(query));
  const { rows, count } = await Booking.findAndCountAll({
    where,
    include: bookingInclude(dateFilter && { date: dateFilter }),
    distinct: true,
    offset: pagination.offset,
    limit: pagination.limit,
    order: getSort(query.sort, ['createdAt', 'totalPrice', 'status']),
  });
  return { items: rows, meta: buildMeta(pagination, count) };
};

const listMyBookings = (userId, query) => paginate(compact({ userId, status: query.status }), query);

const listBookings = (query) => {
  const where = compact({ status: query.status, serviceId: query.serviceId, userId: query.userId });
  if (query.search) {
    const pattern = { [Op.iLike]: `%${query.search}%` };
    where[Op.or] = [{ bookingCode: pattern }, { '$user.name$': pattern }, { '$user.email$': pattern }];
  }
  return paginate(where, query);
};

const getBookingById = async (id, actor) => {
  const booking = await Booking.findByPk(id, {
    include: [
      ...bookingInclude(),
      {
        model: BookingStatusLog,
        as: 'logs',
        include: [{ model: User, as: 'changedBy', attributes: ['id', 'name', 'role'] }],
      },
    ],
    order: [[{ model: BookingStatusLog, as: 'logs' }, 'createdAt', 'ASC']],
  });
  if (!booking) throw ApiError.notFound('Booking not found');
  if (actor.role !== 'ADMIN' && booking.userId !== actor.id) {
    throw ApiError.forbidden('You can only view your own booking');
  }
  return booking;
};

module.exports = {
  createBooking,
  cancelBooking,
  updateBookingStatus,
  listMyBookings,
  listBookings,
  getBookingById,
};
