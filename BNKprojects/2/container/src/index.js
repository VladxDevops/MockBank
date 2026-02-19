const express = require('express');
const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

const app = express();
app.use(express.json());

const port = process.env.PORT || 3000;

// MongoDB Connection
const mongoUri = process.env.MONGO_URI;

// Audit Log Schema (as per PROJECT_DETAILS.md)
const auditSchema = new mongoose.Schema({
  journey_id: String,
  user_id: String,
  timestamp: { type: Date, default: Date.now },
  status: String,
  risk_score: Number,
  steps: [
    {
      step: String,
      timestamp: { type: Date, default: Date.now },
      status: String,
      input: Object,
      decision: String,
      error_code: String
    }
  ]
});

const AuditLog = mongoose.model('AuditLog', auditSchema);

// Health Check Route
app.get('/', (req, res) => {
  res.send('Transaction Service is running. Use POST /transfer to initiate a transaction.');
});

// Transaction Route
app.post('/transfer', async (req, res) => {
  const { user_id, amount } = req.body;

  if (!user_id || !amount) {
    return res.status(400).json({ error: 'Missing user_id or amount' });
  }

  const journey_id = uuidv4();
  const steps = [];
  let risk_score = 0;
  let decision = 'approved';

  // Step 1: Login (Simulated)
  steps.push({
    step: 'login',
    timestamp: new Date(),
    status: 'success'
  });

  // Step 2: Risk Evaluation
  if (amount >= 10000) {
    decision = 'step_up_required';
    risk_score = 85;
  } else {
    risk_score = 10;
  }

  steps.push({
    step: 'risk_evaluation',
    timestamp: new Date(),
    input: { amount },
    decision: decision
  });

  // Step 3: Step-Up Auth (if required)
  if (decision === 'step_up_required') {
    steps.push({ step: 'mfa_challenge_issued', timestamp: new Date(), status: 'success' });
    // Simulate successful MFA
    steps.push({ step: 'mfa_verification', timestamp: new Date(), status: 'success' });
  }

  // Save to MongoDB
  try {
    const auditEntry = new AuditLog({
      journey_id, user_id, status: 'success', risk_score, steps
    });
    await auditEntry.save();
    
    res.json({ message: 'Transaction processed', journey_id, status: 'success', decision });
  } catch (error) {
    console.error('Error saving audit log:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

const startServer = async () => {
  try {
    if (!mongoUri) {
      throw new Error('MONGO_URI environment variable not set. Cannot start server.');
    }
    await mongoose.connect(mongoUri);
    console.log('Successfully connected to MongoDB.');

    app.listen(port, () => {
      console.log(`Server listening on port ${port}`);
    });
  } catch (error) {
    console.error('Failed to connect to MongoDB. Server is not starting.', error);
    process.exit(1); // Exit with a failure code
  }
};

startServer();
