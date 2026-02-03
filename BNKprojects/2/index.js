require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;

// Basic Health Check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', service: 'Transaction Service' });
});

app.listen(PORT, () => {
  console.log(`Transaction Service running on port ${PORT}`);
});
