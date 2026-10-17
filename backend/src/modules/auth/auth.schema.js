const { z } = require('zod');

const password = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .max(72, 'Password must be at most 72 characters')
  .regex(/[A-Za-z]/, 'Password must contain a letter')
  .regex(/\d/, 'Password must contain a number');

const email = z.string().trim().toLowerCase().email('Email is not valid');

const phone = z.string().trim().regex(/^\+?[0-9]{8,15}$/, 'Phone must be 8-15 digits');

const registerSchema = z.object({
  body: z.object({
    name: z.string().trim().min(2, 'Name must be at least 2 characters').max(100),
    email,
    phone: phone.optional(),
    password,
  }),
});

const loginSchema = z.object({
  body: z.object({
    email,
    password: z.string().min(1, 'Password is required'),
  }),
});

const refreshTokenSchema = z.object({
  body: z.object({
    refreshToken: z.string().min(1, 'Refresh token is required'),
  }),
});

const updateMeSchema = z.object({
  body: z
    .object({
      name: z.string().trim().min(2).max(100).optional(),
      phone: phone.nullable().optional(),
      currentPassword: z.string().min(1).optional(),
      newPassword: password.optional(),
    })
    .refine((data) => Object.keys(data).length > 0, 'Provide at least one field to update')
    .refine((data) => !data.newPassword || data.currentPassword, {
      message: 'Current password is required to set a new password',
      path: ['currentPassword'],
    }),
});

module.exports = { registerSchema, loginSchema, refreshTokenSchema, updateMeSchema };
