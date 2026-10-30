const { z } = require('zod');
const { dateRangeQuery } = require('../../utils/commonSchemas');

// Accept "bk-seed-0001" as well as "BK-SEED-0001"
const bookingCode = z
  .string()
  .trim()
  .max(30)
  .regex(/^BK-[A-Za-z0-9-]+$/i, 'Booking code must look like BK-20261022-7F3A9C')
  .transform((value) => value.toUpperCase());

const bookingCodeSchema = z.object({ params: z.object({ code: bookingCode }) });

const settleBookingSchema = z.object({
  params: z.object({ code: bookingCode }),
  body: z.object({
    method: z.enum(['CASH', 'TRANSFER', 'EWALLET']),
    amount: z.coerce.number().positive('Amount must be greater than 0'),
    externalRef: z.string().trim().min(3).max(40),
  }),
});

const summarySchema = z.object({ query: z.object({ ...dateRangeQuery }) });

module.exports = { bookingCodeSchema, settleBookingSchema, summarySchema };
