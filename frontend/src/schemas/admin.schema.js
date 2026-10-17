import { z } from 'zod';

const dateString = z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Date is required');
const timeString = z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/, 'Time is required');
const capacity = z.coerce.number().int().min(1, 'Capacity must be at least 1').max(100, 'Capacity must be at most 100');

export const categorySchema = z.object({
  name: z.string().trim().min(2, 'Name must be at least 2 characters').max(100),
});

export const serviceSchema = z.object({
  categoryId: z.coerce.number({ invalid_type_error: 'Category is required' }).int().positive('Category is required'),
  name: z.string().trim().min(3, 'Name must be at least 3 characters').max(150),
  description: z.string().trim().max(2000),
  price: z.coerce.number().positive('Price must be greater than 0').max(100000000),
  durationMinutes: z.coerce
    .number()
    .int('Duration must be a whole number')
    .min(15, 'Duration must be at least 15 minutes')
    .max(480, 'Duration must be at most 480 minutes'),
  status: z.enum(['ACTIVE', 'INACTIVE']),
  imageUrl: z.string().trim().url('Image URL is not valid').or(z.literal('')),
});

export const scheduleSchema = z.object({
  serviceId: z.coerce.number().int().positive('Service is required'),
  date: dateString,
  startTime: timeString,
  capacity,
});

export const scheduleUpdateSchema = z.object({
  date: dateString,
  startTime: timeString,
  capacity,
  status: z.enum(['AVAILABLE', 'CLOSED']),
});

export const bulkScheduleSchema = z
  .object({
    serviceId: z.coerce.number().int().positive('Service is required'),
    startDate: dateString,
    endDate: dateString,
    openTime: timeString,
    closeTime: timeString,
    capacity,
    daysOfWeek: z.array(z.coerce.number()).min(1, 'Pick at least one day'),
  })
  .refine((data) => data.openTime < data.closeTime, { message: 'Close time must be after open time', path: ['closeTime'] })
  .refine((data) => data.startDate <= data.endDate, { message: 'End date must be on or after start date', path: ['endDate'] });
