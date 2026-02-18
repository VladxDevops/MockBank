require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');

const app = express();
app.use(express.json());

const port = process.env.PORT || 3000;

// Connect to MongoDB
if (process.env.MONGO_URI) {
  mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log('MongoDB connected successfully.'))
    .catch(err => console.error('MongoDB connection error:', err));
} else {
  console.warn('MONGO_URI environment variable not set. Skipping database connection.');
}

// Basic Health Check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', service: 'Transaction Service' });
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
