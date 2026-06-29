const http = require('http');
const { Pool } = require('pg');

const PORT = process.env.PORT || 8080;

// DB config comes from ECS task environment variables
// which are injected from Secrets Manager and RDS outputs
const dbPool = new Pool({
  host:     process.env.DB_HOST,
  database: process.env.DB_NAME,
  user:     process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  port:     parseInt(process.env.DB_PORT || '5432'),
  ssl:      { rejectUnauthorized: false },
  connectionTimeoutMillis: 3000,
});

const server = http.createServer(async (req, res) => {
  const url = req.url;

  // ALB health check, must return 200 fast
  if (url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', timestamp: new Date().toISOString() }));
    return;
  }

  // Home route, shows env info (no secrets)
  if (url === '/') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      app:         'CloudNorth API',
      environment: process.env.ENVIRONMENT || 'unknown',
      region:      process.env.AWS_REGION   || 'unknown',
      version:     process.env.APP_VERSION  || '1.0.0',
    }));
    return;
  }

  // DB test route, verifies ECS can reach RDS
  if (url === '/db') {
    try {
      const result = await dbPool.query('SELECT NOW() AS time, current_database() AS db');
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        status:   'connected',
        db:       result.rows[0].db,
        db_time:  result.rows[0].time,
      }));
    } catch (err) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        status: 'db_error',
        error:  err.message,
      }));
    }
    return;
  }

  // 404 for anything else
  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'not found' }));
});

server.listen(PORT, () => {
  console.log(`CloudNorth API running on port ${PORT}`);
  console.log(`Environment: ${process.env.ENVIRONMENT || 'unknown'}`);
  console.log(`DB Host: ${process.env.DB_HOST || 'not set'}`);
});

// Graceful shutdown, ECS sends SIGTERM before stopping a task
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    dbPool.end();
    process.exit(0);
  });
});
