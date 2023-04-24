// Bibliotheken
const express = require('express');
require('dotenv').config();
const player = require('./routes/player');
const club = require('./routes/club');
const match = require('./routes/match');

// Variabele
const app = express();

// Routes
app.use('/player', player);
app.use('/club', club);
app.use('/match', match);

// Starten server
app.listen(3000);