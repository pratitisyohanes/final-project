const ref = (name) => ({ $ref: `#/components/schemas/${name}` });

const ok = (description, data, meta) => ({
  description,
  content: {
    'application/json': {
      schema: ref('SuccessResponse'),
      example: { success: true, message: description, data, ...(meta && { meta }) },
    },
  },
});

const errors = (...codes) => Object.fromEntries(codes.map((code) => [code, { $ref: `#/components/responses/E${code}` }]));

const jsonBody = (schemaName, example) => ({
  required: true,
  content: { 'application/json': { schema: ref(schemaName), example } },
});

const query = (name, schema, description) => ({ name, in: 'query', required: false, schema, description });

const pathParam = (name, type = 'integer') => ({
  name,
  in: 'path',
  required: true,
  schema: type === 'uuid' ? { type: 'string', format: 'uuid' } : { type: 'integer' },
});

const paging = [
  query('page', { type: 'integer', minimum: 1, default: 1 }, 'Page number'),
  query('limit', { type: 'integer', minimum: 1, maximum: 100, default: 10 }, 'Items per page'),
  query('sort', { type: 'string', example: 'createdAt:desc' }, 'field:asc or field:desc'),
];

const range = [
  query('from', { type: 'string', format: 'date' }, 'Start date YYYY-MM-DD'),
  query('to', { type: 'string', format: 'date' }, 'End date YYYY-MM-DD'),
  query('period', { type: 'string', enum: ['today', 'this_week', 'this_month'] }, 'Shortcut range, overrides from/to'),
];

const secured = [{ bearerAuth: [] }];
const meta = { page: 1, limit: 10, total: 1, totalPages: 1 };

const sampleUser = { id: 'b3f1c2d4-1111-4a5b-9c8d-123456789abc', name: 'Budi Santoso', email: 'budi@example.com', phone: '081234567890', role: 'USER', isActive: true };
const sampleService = { id: 1, categoryId: 1, name: 'Coop Site Survey', price: '150000', durationMinutes: 120, status: 'ACTIVE', category: { id: 1, name: 'Site Survey', slug: 'site-survey' } };
const sampleSchedule = { id: 10, serviceId: 1, date: '2026-10-20T00:00:00.000Z', startTime: '09:00', endTime: '11:00', capacity: 2, bookedCount: 1, status: 'AVAILABLE', remaining: 1 };
const sampleBooking = { id: 'f7a3e8b2-2222-4c1d-8e9f-abcdef123456', bookingCode: 'BK-20261011-7F3A9C', status: 'PENDING', totalPrice: '150000', service: { id: 1, name: 'Coop Site Survey' }, schedule: { id: 10, date: '2026-10-20T00:00:00.000Z', startTime: '09:00', endTime: '11:00' }, payment: { status: 'UNPAID', amount: '150000' } };

const spec = {
  openapi: '3.0.3',
  info: {
    title: 'Service Booking & Management API',
    version: '1.0.0',
    description:
      'REST API for booking services. Roles: ADMIN manages services, schedules, customers and reports; USER books services. ' +
      'Relations: Category 1-N Service 1-N Schedule 1-N Booking 1-1 Payment; User 1-N Booking; Booking 1-N BookingStatusLog.',
  },
  // Relative URL so "Try it out" calls whichever host serves the docs (localhost or the VPS)
  servers: [{ url: '/api/v1', description: 'Current host' }],
  tags: ['Auth', 'Users', 'Categories', 'Services', 'Schedules', 'Bookings', 'Payments', 'Reports'].map((name) => ({ name })),
  components: {
    securitySchemes: { bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' } },
    schemas: {
      SuccessResponse: {
        type: 'object',
        properties: { success: { type: 'boolean' }, message: { type: 'string' }, data: {}, meta: ref('Meta') },
      },
      ErrorResponse: {
        type: 'object',
        properties: {
          success: { type: 'boolean', example: false },
          message: { type: 'string' },
          errors: { type: 'array', items: { type: 'object', properties: { field: { type: 'string' }, message: { type: 'string' } } } },
        },
      },
      Meta: {
        type: 'object',
        properties: { page: { type: 'integer' }, limit: { type: 'integer' }, total: { type: 'integer' }, totalPages: { type: 'integer' } },
      },
      RegisterInput: {
        type: 'object',
        required: ['name', 'email', 'password'],
        properties: { name: { type: 'string' }, email: { type: 'string', format: 'email' }, phone: { type: 'string' }, password: { type: 'string', minLength: 8 } },
      },
      LoginInput: {
        type: 'object',
        required: ['email', 'password'],
        properties: { email: { type: 'string', format: 'email' }, password: { type: 'string' } },
      },
      RefreshInput: { type: 'object', required: ['refreshToken'], properties: { refreshToken: { type: 'string' } } },
      MfaTicketInput: { type: 'object', required: ['mfaToken'], properties: { mfaToken: { type: 'string', description: 'Ticket from /auth/login, valid 5 minutes' } } },
      MfaCodeInput: {
        type: 'object',
        required: ['mfaToken', 'code'],
        properties: { mfaToken: { type: 'string' }, code: { type: 'string', pattern: '^\\d{6}$', description: '6-digit code from the authenticator app' } },
      },
      UpdateMeInput: {
        type: 'object',
        properties: { name: { type: 'string' }, phone: { type: 'string' }, currentPassword: { type: 'string' }, newPassword: { type: 'string' } },
      },
      UpdateUserInput: {
        type: 'object',
        properties: { name: { type: 'string' }, phone: { type: 'string' }, isActive: { type: 'boolean' } },
      },
      CategoryInput: { type: 'object', required: ['name'], properties: { name: { type: 'string' } } },
      ServiceInput: {
        type: 'object',
        required: ['categoryId', 'name', 'price', 'durationMinutes'],
        properties: {
          categoryId: { type: 'integer' },
          name: { type: 'string' },
          description: { type: 'string' },
          price: { type: 'number' },
          durationMinutes: { type: 'integer', minimum: 15, maximum: 480 },
          status: { type: 'string', enum: ['ACTIVE', 'INACTIVE'] },
          imageUrl: { type: 'string', format: 'uri' },
        },
      },
      ScheduleInput: {
        type: 'object',
        required: ['serviceId', 'date', 'startTime'],
        properties: {
          serviceId: { type: 'integer' },
          date: { type: 'string', format: 'date' },
          startTime: { type: 'string', example: '09:00' },
          capacity: { type: 'integer', minimum: 1, default: 1 },
        },
      },
      BulkScheduleInput: {
        type: 'object',
        required: ['serviceId', 'startDate', 'endDate', 'openTime', 'closeTime'],
        properties: {
          serviceId: { type: 'integer' },
          startDate: { type: 'string', format: 'date' },
          endDate: { type: 'string', format: 'date' },
          openTime: { type: 'string', example: '09:00' },
          closeTime: { type: 'string', example: '17:00' },
          capacity: { type: 'integer', default: 1 },
          daysOfWeek: { type: 'array', items: { type: 'integer', minimum: 1, maximum: 7 }, description: '1 = Monday ... 7 = Sunday' },
        },
      },
      UpdateScheduleInput: {
        type: 'object',
        properties: {
          date: { type: 'string', format: 'date' },
          startTime: { type: 'string' },
          capacity: { type: 'integer' },
          status: { type: 'string', enum: ['AVAILABLE', 'CLOSED'] },
        },
      },
      BookingInput: {
        type: 'object',
        required: ['scheduleId'],
        properties: { scheduleId: { type: 'integer' }, notes: { type: 'string', maxLength: 500 } },
      },
      CancelInput: { type: 'object', properties: { reason: { type: 'string' } } },
      BookingStatusInput: {
        type: 'object',
        required: ['status'],
        properties: { status: { type: 'string', enum: ['CONFIRMED', 'COMPLETED', 'CANCELLED'] }, note: { type: 'string' } },
      },
      PaymentInput: {
        type: 'object',
        required: ['method'],
        properties: { method: { type: 'string', enum: ['CASH', 'TRANSFER', 'EWALLET'] } },
      },
    },
    responses: Object.fromEntries(
      [
        [400, 'Business rule violated'],
        [401, 'Missing, invalid or expired token'],
        [403, 'Role or ownership does not allow this action'],
        [404, 'Resource not found'],
        [409, 'Conflict: duplicate data, full slot or overlapping schedule'],
        [422, 'Input validation failed'],
        [429, 'Too many attempts'],
        [503, 'Login service (sso-pro) is not reachable'],
      ].map(([code, description]) => [
        `E${code}`,
        { description, content: { 'application/json': { schema: ref('ErrorResponse') } } },
      ]),
    ),
  },
  paths: {
    '/auth/register': {
      post: {
        tags: ['Auth'],
        summary: 'Register a new customer account',
        requestBody: jsonBody('RegisterInput', { name: 'Budi Santoso', email: 'budi@example.com', phone: '081234567890', password: 'User12345' }),
        responses: { 201: ok('Registration successful', { user: sampleUser, accessToken: '<jwt>', refreshToken: '<jwt>' }), ...errors(409, 422) },
      },
    },
    '/auth/login': {
      post: {
        tags: ['Auth'],
        summary: 'Login; returns tokens, or an mfaToken when a second step is needed',
        description:
          'With AUTH_PROVIDER=sso the password is checked by sso-pro auth-service against LDAP. When the account has two-factor authentication the answer is { requiresMfa, mfaToken }; an ADMIN without it while MFA_ENFORCE_ADMIN=true gets { requiresMfaSetup, mfaToken }.',
        requestBody: jsonBody('LoginInput', { email: 'admin@booking.com', password: 'Admin12345' }),
        responses: { 200: ok('Login successful', { user: sampleUser, accessToken: '<jwt>', refreshToken: '<jwt>' }), ...errors(401, 403, 422, 503) },
      },
    },
    '/auth/mfa/verify': {
      post: {
        tags: ['Auth'],
        summary: 'Second login step: check the authenticator code',
        requestBody: jsonBody('MfaCodeInput', { mfaToken: '<ticket>', code: '123456' }),
        responses: { 200: ok('Login successful', { user: sampleUser, accessToken: '<jwt>', refreshToken: '<jwt>' }), ...errors(400, 401, 422, 429) },
      },
    },
    '/auth/mfa/setup': {
      post: {
        tags: ['Auth'],
        summary: 'Start two-factor setup: returns a QR code for the authenticator app',
        requestBody: jsonBody('MfaTicketInput', { mfaToken: '<ticket>' }),
        responses: { 200: ok('Scan the QR code with your authenticator app', { secret: 'JBSWY3DPEHPK3PXP', otpauthUrl: 'otpauth://totp/...', qrCode: 'data:image/png;base64,...' }), ...errors(401, 409, 422) },
      },
    },
    '/auth/mfa/enable': {
      post: {
        tags: ['Auth'],
        summary: 'Finish two-factor setup with the first code and log in',
        requestBody: jsonBody('MfaCodeInput', { mfaToken: '<ticket>', code: '123456' }),
        responses: { 200: ok('Two-factor authentication enabled', { user: sampleUser, accessToken: '<jwt>', refreshToken: '<jwt>' }), ...errors(400, 401, 409, 422, 429) },
      },
    },
    '/auth/refresh': {
      post: {
        tags: ['Auth'],
        summary: 'Exchange a refresh token for a new token pair',
        requestBody: jsonBody('RefreshInput', { refreshToken: '<jwt>' }),
        responses: { 200: ok('Token refreshed', { accessToken: '<jwt>', refreshToken: '<jwt>' }), ...errors(401) },
      },
    },
    '/auth/logout': {
      post: {
        tags: ['Auth'],
        summary: 'Revoke a refresh token',
        security: secured,
        requestBody: jsonBody('RefreshInput', { refreshToken: '<jwt>' }),
        responses: { 200: ok('Logout successful', null), ...errors(401) },
      },
    },
    '/auth/me': {
      get: { tags: ['Auth'], summary: 'Current user profile', security: secured, responses: { 200: ok('Current user profile', sampleUser), ...errors(401) } },
      patch: {
        tags: ['Auth'],
        summary: 'Update own profile or password',
        security: secured,
        requestBody: jsonBody('UpdateMeInput', { name: 'Budi S.', currentPassword: 'User12345', newPassword: 'NewPass123' }),
        responses: { 200: ok('Profile updated', sampleUser), ...errors(400, 401, 422) },
      },
    },
    '/users': {
      get: {
        tags: ['Users'],
        summary: 'List customers (admin)',
        security: secured,
        parameters: [...paging, query('search', { type: 'string' }, 'Name, email or phone'), query('isActive', { type: 'string', enum: ['true', 'false'] })],
        responses: { 200: ok('Customer list', [{ ...sampleUser, bookingCount: 3 }], meta), ...errors(401, 403) },
      },
    },
    '/users/{id}': {
      get: { tags: ['Users'], summary: 'Customer detail with recent bookings (admin)', security: secured, parameters: [pathParam('id', 'uuid')], responses: { 200: ok('Customer detail', sampleUser), ...errors(401, 403, 404) } },
      patch: {
        tags: ['Users'],
        summary: 'Update or deactivate a customer (admin)',
        security: secured,
        parameters: [pathParam('id', 'uuid')],
        requestBody: jsonBody('UpdateUserInput', { isActive: false }),
        responses: { 200: ok('Customer updated', sampleUser), ...errors(401, 403, 404, 422) },
      },
    },
    '/categories': {
      get: {
        tags: ['Categories'],
        summary: 'List categories',
        parameters: [...paging, query('search', { type: 'string' })],
        responses: { 200: ok('Category list', [{ id: 1, name: 'Site Survey', slug: 'site-survey', serviceCount: 2 }], meta) },
      },
      post: {
        tags: ['Categories'],
        summary: 'Create a category (admin)',
        security: secured,
        requestBody: jsonBody('CategoryInput', { name: 'Site Survey' }),
        responses: { 201: ok('Category created', { id: 1, name: 'Site Survey', slug: 'site-survey' }), ...errors(401, 403, 409, 422) },
      },
    },
    '/categories/{id}': {
      get: { tags: ['Categories'], summary: 'Category detail', parameters: [pathParam('id')], responses: { 200: ok('Category detail', { id: 1, name: 'Site Survey' }), ...errors(404) } },
      patch: { tags: ['Categories'], summary: 'Update a category (admin)', security: secured, parameters: [pathParam('id')], requestBody: jsonBody('CategoryInput', { name: 'Site Survey & Planning' }), responses: { 200: ok('Category updated', { id: 1, name: 'Site Survey & Planning' }), ...errors(401, 403, 404, 409) } },
      delete: { tags: ['Categories'], summary: 'Delete a category without services (admin)', security: secured, parameters: [pathParam('id')], responses: { 200: ok('Category deleted', null), ...errors(401, 403, 404, 409) } },
    },
    '/services': {
      get: {
        tags: ['Services'],
        summary: 'List services with search, filter and pagination',
        description: 'Guests and customers only see ACTIVE services. Admin can filter by status.',
        parameters: [
          ...paging,
          query('search', { type: 'string' }, 'Matches name, description or category name'),
          query('categoryId', { type: 'integer' }),
          query('status', { type: 'string', enum: ['ACTIVE', 'INACTIVE'] }, 'Admin only'),
          query('minPrice', { type: 'number' }),
          query('maxPrice', { type: 'number' }),
        ],
        responses: { 200: ok('Service list', [sampleService], meta), ...errors(422) },
      },
      post: { tags: ['Services'], summary: 'Create a service (admin)', security: secured, requestBody: jsonBody('ServiceInput', { categoryId: 1, name: 'Coop Site Survey', description: 'Measure the land and plan the coop layout', price: 150000, durationMinutes: 120 }), responses: { 201: ok('Service created', sampleService), ...errors(401, 403, 404, 422) } },
    },
    '/services/{id}': {
      get: { tags: ['Services'], summary: 'Service detail', parameters: [pathParam('id')], responses: { 200: ok('Service detail', sampleService), ...errors(404) } },
      patch: { tags: ['Services'], summary: 'Update a service (admin)', security: secured, parameters: [pathParam('id')], requestBody: jsonBody('ServiceInput', { price: 80000 }), responses: { 200: ok('Service updated', sampleService), ...errors(401, 403, 404, 422) } },
      delete: { tags: ['Services'], summary: 'Soft delete a service and close its future slots (admin)', security: secured, parameters: [pathParam('id')], responses: { 200: ok('Service deleted', null), ...errors(401, 403, 404, 409) } },
    },
    '/services/{id}/schedules': {
      get: {
        tags: ['Schedules'],
        summary: 'Bookable slots for a service',
        description: 'Returns AVAILABLE future slots. Defaults to the next 7 days.',
        parameters: [pathParam('id'), query('date', { type: 'string', format: 'date' }), ...range],
        responses: { 200: ok('Available schedules', { service: sampleService, schedules: [sampleSchedule] }), ...errors(400, 404) },
      },
    },
    '/schedules': {
      get: {
        tags: ['Schedules'],
        summary: 'List all schedules (admin)',
        security: secured,
        parameters: [...paging, ...range, query('serviceId', { type: 'integer' }), query('status', { type: 'string', enum: ['AVAILABLE', 'FULL', 'CLOSED'] })],
        responses: { 200: ok('Schedule list', [sampleSchedule], meta), ...errors(401, 403) },
      },
      post: {
        tags: ['Schedules'],
        summary: 'Create one slot (admin)',
        description: 'endTime is computed from the service duration. Rejected with 409 when it overlaps another slot of the same service.',
        security: secured,
        requestBody: jsonBody('ScheduleInput', { serviceId: 1, date: '2026-10-20', startTime: '09:00', capacity: 2 }),
        responses: { 201: ok('Schedule created', sampleSchedule), ...errors(400, 401, 403, 404, 409, 422) },
      },
    },
    '/schedules/bulk': {
      post: {
        tags: ['Schedules'],
        summary: 'Generate slots for a date range (admin)',
        security: secured,
        requestBody: jsonBody('BulkScheduleInput', { serviceId: 1, startDate: '2026-10-20', endDate: '2026-10-26', openTime: '09:00', closeTime: '17:00', capacity: 2, daysOfWeek: [1, 2, 3, 4, 5, 6] }),
        responses: { 201: ok('48 schedule(s) generated', { created: 48, skipped: 0 }), ...errors(400, 401, 403, 404, 422) },
      },
    },
    '/schedules/{id}': {
      get: { tags: ['Schedules'], summary: 'Schedule detail with active bookings (admin)', security: secured, parameters: [pathParam('id')], responses: { 200: ok('Schedule detail', sampleSchedule), ...errors(401, 403, 404) } },
      patch: { tags: ['Schedules'], summary: 'Change capacity, close/reopen or move a slot (admin)', security: secured, parameters: [pathParam('id')], requestBody: jsonBody('UpdateScheduleInput', { capacity: 3 }), responses: { 200: ok('Schedule updated', sampleSchedule), ...errors(400, 401, 403, 404, 409, 422) } },
      delete: { tags: ['Schedules'], summary: 'Delete a slot without booking history (admin)', security: secured, parameters: [pathParam('id')], responses: { 200: ok('Schedule deleted', null), ...errors(401, 403, 404, 409) } },
    },
    '/bookings': {
      post: {
        tags: ['Bookings'],
        summary: 'Book a schedule slot (customer)',
        description: 'Runs in a transaction with a row lock. Fails when the slot is past, closed, full, or overlaps another active booking of the same customer.',
        security: secured,
        requestBody: jsonBody('BookingInput', { scheduleId: 10, notes: 'Please use unscented products' }),
        responses: { 201: ok('Booking created', sampleBooking), ...errors(400, 401, 403, 404, 409, 422) },
      },
      get: {
        tags: ['Bookings'],
        summary: 'List all bookings (admin)',
        security: secured,
        parameters: [
          ...paging,
          ...range,
          query('search', { type: 'string' }, 'Booking code, customer name or email'),
          query('status', { type: 'string', enum: ['PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED'] }),
          query('serviceId', { type: 'integer' }),
          query('userId', { type: 'string', format: 'uuid' }),
        ],
        responses: { 200: ok('Booking list', [sampleBooking], meta), ...errors(401, 403) },
      },
    },
    '/bookings/me': {
      get: {
        tags: ['Bookings'],
        summary: 'Booking history of the logged in customer',
        security: secured,
        parameters: [...paging, ...range, query('status', { type: 'string', enum: ['PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED'] })],
        responses: { 200: ok('My bookings', [sampleBooking], meta), ...errors(401, 403) },
      },
    },
    '/bookings/{id}': {
      get: { tags: ['Bookings'], summary: 'Booking detail with status history', security: secured, parameters: [pathParam('id', 'uuid')], responses: { 200: ok('Booking detail', sampleBooking), ...errors(401, 403, 404) } },
    },
    '/bookings/{id}/cancel': {
      patch: {
        tags: ['Bookings'],
        summary: 'Cancel a booking',
        description: 'Customers can cancel their own PENDING/CONFIRMED booking at least 2 hours before it starts. Admin can cancel any active booking.',
        security: secured,
        parameters: [pathParam('id', 'uuid')],
        requestBody: { required: false, content: { 'application/json': { schema: ref('CancelInput'), example: { reason: 'Schedule conflict' } } } },
        responses: { 200: ok('Booking cancelled', { ...sampleBooking, status: 'CANCELLED' }), ...errors(400, 401, 403, 404) },
      },
    },
    '/bookings/{id}/status': {
      patch: {
        tags: ['Bookings'],
        summary: 'Change booking status (admin)',
        description: 'Allowed: PENDING -> CONFIRMED/CANCELLED, CONFIRMED -> COMPLETED/CANCELLED.',
        security: secured,
        parameters: [pathParam('id', 'uuid')],
        requestBody: jsonBody('BookingStatusInput', { status: 'CONFIRMED' }),
        responses: { 200: ok('Booking status changed to CONFIRMED', { ...sampleBooking, status: 'CONFIRMED' }), ...errors(400, 401, 403, 404, 422) },
      },
    },
    '/payments/{bookingId}': {
      patch: {
        tags: ['Payments'],
        summary: 'Mark a booking payment as paid (admin)',
        security: secured,
        parameters: [pathParam('bookingId', 'uuid')],
        requestBody: jsonBody('PaymentInput', { method: 'TRANSFER' }),
        responses: { 200: ok('Payment recorded', { status: 'PAID', method: 'TRANSFER', amount: '75000' }), ...errors(400, 401, 403, 404, 409) },
      },
    },
    '/reports/summary': {
      get: {
        tags: ['Reports'],
        summary: 'Dashboard summary (admin)',
        security: secured,
        parameters: range,
        responses: { 200: ok('Booking summary', { totalBookings: 42, bookingsByStatus: { PENDING: 5, CONFIRMED: 10, COMPLETED: 24, CANCELLED: 3 }, totalRevenue: 3150000, newCustomers: 7, todayBookings: 4, cancellationRate: 7.1 }), ...errors(401, 403) },
      },
    },
    '/reports/top-services': {
      get: {
        tags: ['Reports'],
        summary: 'Most booked services (admin)',
        security: secured,
        parameters: [...range, query('limit', { type: 'integer', default: 5 })],
        responses: { 200: ok('Top services', { items: [{ serviceId: 1, serviceName: 'Coop Site Survey', totalBookings: 18, totalRevenue: 2700000 }] }), ...errors(401, 403) },
      },
    },
    '/reports/busiest-schedules': {
      get: {
        tags: ['Reports'],
        summary: 'Busiest weekdays, times and dates (admin)',
        security: secured,
        parameters: [...range, query('limit', { type: 'integer', default: 5 })],
        responses: { 200: ok('Busiest schedules', { byDayAndTime: [{ dayOfWeek: 6, dayName: 'Saturday', startTime: '10:00', totalBookings: 9 }], byDate: [{ date: '2026-10-17', totalBookings: 12 }] }), ...errors(401, 403) },
      },
    },
    '/reports/revenue': {
      get: {
        tags: ['Reports'],
        summary: 'Revenue per day or month (admin)',
        security: secured,
        parameters: [...range, query('groupBy', { type: 'string', enum: ['day', 'month'], default: 'day' })],
        responses: { 200: ok('Revenue report', { groupBy: 'day', total: 450000, items: [{ period: '2026-10-10', revenue: 450000, transactions: 5 }] }), ...errors(401, 403) },
      },
    },
    '/reports/export': {
      get: {
        tags: ['Reports'],
        summary: 'Download a report as CSV (admin)',
        security: secured,
        parameters: [...range, query('type', { type: 'string', enum: ['bookings', 'top-services'], default: 'bookings' }), query('format', { type: 'string', enum: ['csv'], default: 'csv' })],
        responses: { 200: { description: 'CSV file', content: { 'text/csv': { schema: { type: 'string' } } } }, ...errors(401, 403) },
      },
    },
  },
};

module.exports = spec;
