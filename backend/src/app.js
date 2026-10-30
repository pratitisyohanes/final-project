const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const swaggerUi = require('swagger-ui-express');
const env = require('./config/env');
const openapiSpec = require('./docs/openapi');
const routes = require('./routes');
const { apiLimiter } = require('./middlewares/rateLimiter');
const notFound = require('./middlewares/notFound');
const errorHandler = require('./middlewares/errorHandler');

const app = express();

// Needed for correct client IPs behind Railway/Render proxies
app.set('trust proxy', 1);

// Docs are mounted before helmet because Swagger UI needs inline scripts
app.get('/api/docs.json', (req, res) => res.json(openapiSpec));
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(openapiSpec, { customSiteTitle: 'Booking API Docs' }));

app.use(helmet());
app.use(cors({ origin: env.CORS_ORIGINS, credentials: true }));
app.use(express.json({ limit: '1mb' }));
if (env.NODE_ENV !== 'test') app.use(morgan(env.NODE_ENV === 'production' ? 'combined' : 'dev'));

app.get('/health', (req, res) =>
  res.json({ success: true, message: 'OK', data: { uptime: Math.round(process.uptime()) } }),
);

// Server-to-server routes for pos-api; mounted before apiLimiter because every call comes from 127.0.0.1
app.use('/api/v1/internal', require('./modules/internal/internal.routes'));
app.use('/api/v1', apiLimiter, routes);

app.use(notFound);
app.use(errorHandler);

module.exports = app;
