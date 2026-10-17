const { z } = require('zod');
const { uuidParam, paginationQuery, dateRangeQuery, searchQuery } = require('../../utils/commonSchemas');

const bookingStatus = z.enum(['PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED']);

const createBookingSchema = z.object({
  body: z.object({
    scheduleId: z.coerce.number().int().positive('Schedule is required'),
    notes: z.string().trim().max(500).optional(),
  }),
});

const listMyBookingsSchema = z.object({
  query: z.object({ ...paginationQuery, ...dateRangeQuery, status: bookingStatus.optional() }),
});

const listBookingsSchema = z.object({
  query: z.object({
    ...paginationQuery,
    ...dateRangeQuery,
    search: searchQuery,
    status: bookingStatus.optional(),
    serviceId: z.coerce.number().int().positive().optional(),
    userId: z.string().uuid().optional(),
  }),
});

const bookingIdSchema = z.object({ params: uuidParam() });

const cancelBookingSchema = z.object({
  params: uuidParam(),
  body: z.object({ reason: z.string().trim().max(255).optional() }),
});

const updateBookingStatusSchema = z.object({
  params: uuidParam(),
  body: z.object({
    status: z.enum(['CONFIRMED', 'COMPLETED', 'CANCELLED']),
    note: z.string().trim().max(255).optional(),
  }),
});

module.exports = {
  createBookingSchema,
  listMyBookingsSchema,
  listBookingsSchema,
  bookingIdSchema,
  cancelBookingSchema,
  updateBookingStatusSchema,
};
