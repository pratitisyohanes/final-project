const { z } = require('zod');
const {
  dateString,
  timeString,
  idParam,
  paginationQuery,
  dateRangeQuery,
  atLeastOneField,
} = require('../../utils/commonSchemas');
const { diffInDays } = require('../../utils/time');

const MAX_RANGE_DAYS = 31;

const capacity = z.coerce.number().int().min(1, 'Capacity must be at least 1').max(100);

const availableSchedulesSchema = z.object({
  params: idParam,
  query: z.object({ date: dateString.optional(), ...dateRangeQuery }),
});

const listSchedulesSchema = z.object({
  query: z.object({
    ...paginationQuery,
    ...dateRangeQuery,
    serviceId: z.coerce.number().int().positive().optional(),
    status: z.enum(['AVAILABLE', 'FULL', 'CLOSED']).optional(),
  }),
});

const scheduleIdSchema = z.object({ params: idParam });

const createScheduleSchema = z.object({
  body: z.object({
    serviceId: z.coerce.number().int().positive(),
    date: dateString,
    startTime: timeString,
    capacity: capacity.default(1),
  }),
});

const bulkCreateSchedulesSchema = z.object({
  body: z
    .object({
      serviceId: z.coerce.number().int().positive(),
      startDate: dateString,
      endDate: dateString,
      openTime: timeString,
      closeTime: timeString,
      capacity: capacity.default(1),
      daysOfWeek: z.array(z.number().int().min(1).max(7)).min(1).default([1, 2, 3, 4, 5, 6, 7]),
    })
    .refine((b) => b.openTime < b.closeTime, { message: 'openTime must be before closeTime', path: ['closeTime'] })
    .refine((b) => b.startDate <= b.endDate, { message: 'startDate must be on or before endDate', path: ['endDate'] })
    .refine((b) => diffInDays(b.startDate, b.endDate) < MAX_RANGE_DAYS, {
      message: `Date range must be at most ${MAX_RANGE_DAYS} days`,
      path: ['endDate'],
    }),
});

const updateScheduleSchema = z.object({
  params: idParam,
  body: atLeastOneField(
    z.object({
      date: dateString.optional(),
      startTime: timeString.optional(),
      capacity: capacity.optional(),
      status: z.enum(['AVAILABLE', 'CLOSED']).optional(),
    }),
  ),
});

module.exports = {
  availableSchedulesSchema,
  listSchedulesSchema,
  scheduleIdSchema,
  createScheduleSchema,
  bulkCreateSchedulesSchema,
  updateScheduleSchema,
  MAX_RANGE_DAYS,
};
