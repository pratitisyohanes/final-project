const { z } = require('zod');
const { uuidParam, paginationQuery, searchQuery, atLeastOneField } = require('../../utils/commonSchemas');

const listUsersSchema = z.object({
  query: z.object({
    ...paginationQuery,
    search: searchQuery,
    isActive: z.enum(['true', 'false']).transform((value) => value === 'true').optional(),
  }),
});

const userIdSchema = z.object({ params: uuidParam() });

const updateUserSchema = z.object({
  params: uuidParam(),
  body: atLeastOneField(
    z.object({
      name: z.string().trim().min(2).max(100).optional(),
      phone: z.string().trim().regex(/^\+?[0-9]{8,15}$/, 'Phone must be 8-15 digits').nullable().optional(),
      isActive: z.boolean().optional(),
    }),
  ),
});

module.exports = { listUsersSchema, userIdSchema, updateUserSchema };
