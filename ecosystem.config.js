module.exports = {
  apps: [{
    name: 'baust-xyz',
    script: 'npm',
    args: 'start',
    env: {
      NODE_ENV: 'production',
      PORT: 5173
    },
    watch: false,
    max_memory_restart: '1G',
    exec_mode: 'cluster',
    instances: 1,
    autorestart: true
  }]
}
