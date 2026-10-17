const { z } = require('zod');
const { idParam, paginationQuery, searchQuery, atLeastOneField } = require('../../utils/commonSchemas');

const serviceFields = {
  categoryId: z.coerce.number().int().positive('Category is required'),
  name: z.string().trim().min(3, 'Name must be at least 3 characters').max(150),
  description: z.string().trim().max(2000).nullable().optional(),
  price: z.coerce.number().positive('Price must be greater than 0').max(100000000),
  durationMinutes: z.coerce
    .number()
    .int()
    .min(15, 'Duration must be at least 15 minutes')
    .max(480, 'Duration must be at most 480 minutes'),
  status: z.enum(['ACTIVE', 'INACTIVE']).optional(),
  imageUrl: z.string().url('Image URL is not valid').nullable().optional(),
};

const listServicesSchema = z.object({
  query: z
    .object({
      ...paginationQuery,
      search: searchQuery,
      categoryId: z.coerce.number().int().positive().optional(),
      status: z.enum(['ACTIVE', 'INACTIVE']).optional(),
      minPrice: z.coerce.number().min(0).optional(),
      maxPrice: z.coerce.number().min(0).optional(),
    })
    .refine((q) => q.minPrice === undefined || q.maxPrice === undefined || q.minPrice <= q.maxPrice, {
      message: 'minPrice must be lower than or equal to maxPrice',
      path: ['minPrice'],
    }),
});

const serviceIdSchema = z.object({ params: idParam });

const createServiceSchema = z.object({ body: z.object(serviceFields) });

const updateServiceSchema = z.object({
  params: idParam,
  body: atLeastOneField(z.object(serviceFields).partial()),
});

module.exports = { listServicesSchema, serviceIdSchema, createServiceSchema, updateServiceSchema };
