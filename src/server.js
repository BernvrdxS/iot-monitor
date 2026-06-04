const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// PostgreSQL connection pool
const pool = new Pool({
  host: process.env.DB_HOST || 'db',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'iot_monitor',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

// Initialize DB tables
async function initDB() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS sensors (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        type VARCHAR(50) NOT NULL,
        location VARCHAR(150),
        unit VARCHAR(20),
        active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS readings (
        id SERIAL PRIMARY KEY,
        sensor_id INTEGER REFERENCES sensors(id) ON DELETE CASCADE,
        value NUMERIC(10,2) NOT NULL,
        status VARCHAR(20) DEFAULT 'normal',
        recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Database initialized successfully');
  } catch (err) {
    console.error('❌ DB init error:', err.message);
    setTimeout(initDB, 3000);
  }
}

// ─── SENSORS CRUD ───────────────────────────────────────────────────────────

// GET all sensors
app.get('/api/sensors', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT s.*, 
        (SELECT value FROM readings WHERE sensor_id = s.id ORDER BY recorded_at DESC LIMIT 1) as last_value,
        (SELECT recorded_at FROM readings WHERE sensor_id = s.id ORDER BY recorded_at DESC LIMIT 1) as last_reading
       FROM sensors s ORDER BY s.created_at DESC`
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET single sensor
app.get('/api/sensors/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM sensors WHERE id = $1', [id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Sensor not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST create sensor
app.post('/api/sensors', async (req, res) => {
  try {
    const { name, type, location, unit } = req.body;
    if (!name || !type) return res.status(400).json({ error: 'Name and type are required' });
    const result = await pool.query(
      'INSERT INTO sensors (name, type, location, unit) VALUES ($1, $2, $3, $4) RETURNING *',
      [name, type, location || '', unit || '']
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT update sensor
app.put('/api/sensors/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, type, location, unit, active } = req.body;
    const result = await pool.query(
      'UPDATE sensors SET name=$1, type=$2, location=$3, unit=$4, active=$5 WHERE id=$6 RETURNING *',
      [name, type, location, unit, active, id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Sensor not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE sensor
app.delete('/api/sensors/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM sensors WHERE id=$1 RETURNING *', [id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Sensor not found' });
    res.json({ message: 'Sensor deleted', sensor: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─── READINGS CRUD ───────────────────────────────────────────────────────────

// GET readings for a sensor
app.get('/api/sensors/:id/readings', async (req, res) => {
  try {
    const { id } = req.params;
    const limit = req.query.limit || 50;
    const result = await pool.query(
      'SELECT * FROM readings WHERE sensor_id=$1 ORDER BY recorded_at DESC LIMIT $2',
      [id, limit]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET all recent readings
app.get('/api/readings', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT r.*, s.name as sensor_name, s.type, s.unit 
       FROM readings r JOIN sensors s ON r.sensor_id = s.id 
       ORDER BY r.recorded_at DESC LIMIT 100`
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST add reading
app.post('/api/readings', async (req, res) => {
  try {
    const { sensor_id, value } = req.body;
    if (!sensor_id || value === undefined) return res.status(400).json({ error: 'sensor_id and value are required' });

    // Auto-determine status based on value
    let status = 'normal';
    if (value > 80) status = 'critical';
    else if (value > 60) status = 'warning';

    const result = await pool.query(
      'INSERT INTO readings (sensor_id, value, status) VALUES ($1, $2, $3) RETURNING *',
      [sensor_id, value, status]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT update reading status
app.put('/api/readings/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const result = await pool.query(
      'UPDATE readings SET status=$1 WHERE id=$2 RETURNING *',
      [status, id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Reading not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE reading
app.delete('/api/readings/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM readings WHERE id=$1 RETURNING *', [id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Reading not found' });
    res.json({ message: 'Reading deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Health check
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', db: 'connected', timestamp: new Date() });
  } catch {
    res.status(500).json({ status: 'error', db: 'disconnected' });
  }
});

// Serve frontend
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`🚀 IoT Monitor running on port ${PORT}`);
  initDB();
});
