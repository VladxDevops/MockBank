const express = require('express');
const session = require('express-session');
const { generators } = require('openid-client');
const jwt = require('jsonwebtoken');
const { initializeOidcClient } = require('./config/oidc');

const app = express();

// Session is mandatory for PKCE to store the code_verifier
app.use(session({
  secret: process.env.SESSION_SECRET || 'dev-secret-keep-it-safe',
  resave: false,
  saveUninitialized: true,
  cookie: { secure: process.env.NODE_ENV === 'production' }
}));

let oidcClient;
initializeOidcClient().then(c => oidcClient = c);

/**
 * STEP 1 & 2: Initiate Login Redirect with PKCE
 */
app.get('/login', (req, res) => {
  const code_verifier = generators.codeVerifier();
  const code_challenge = generators.codeChallenge(code_verifier);

  // Store verifier in session for the callback step
  req.session.code_verifier = code_verifier;

  const authUrl = oidcClient.authorizationUrl({
    scope: 'openid profile email',
    code_challenge,
    code_challenge_method: 'S256',
  });

  res.redirect(authUrl);
});

/**
 * STEP 3: Callback - Exchange Code for Token and Capture JWT
 */
app.get('/auth/callback', async (req, res) => {
  const params = oidcClient.callbackParams(req);
  const code_verifier = req.session.code_verifier;

  try {
    const tokenSet = await oidcClient.callback(
      process.env.OIDC_REDIRECT_URI,
      params,
      { code_verifier }
    );

    // Capture the Access Token (JWT)
    const accessToken = tokenSet.access_token;
    
    // Decode JWT to inspect claims (Roles, User ID)
    // Note: In prod, use jwt.verify() with Keycloak public keys
    const claims = jwt.decode(accessToken);

    req.session.user = claims;
    req.session.token = accessToken;

    res.json({
      message: "Authenticated successfully",
      user: claims.preferred_username,
      token_preview: `${accessToken.substring(0, 20)}...`
    });
  } catch (err) {
    delete req.session.code_verifier;
    res.status(500).send("Auth failed: " + err.message);
  }
});

app.get('/me', (req, res) => {
  if (!req.session.user) return res.status(401).send("Unauthorized");
  res.json(req.session.user);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Retail App active on port ${PORT}`);
});
