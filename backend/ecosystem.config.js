// PM2 process file used on the VPS: keeps the API running and restarts it after crashes or reboots
module.exports = {
  apps: [
    {
      name: 'booking-api',
      script: 'src/server.js',
      cwd: __dirname,
      instances: 1,
      exec_mode: 'fork',
      env: { NODE_ENV: 'production' },
      // Restart before the API can push a 1 GB VPS into heavy swapping
      max_memory_restart: '300M',
      time: true,
    },
  ],
};
