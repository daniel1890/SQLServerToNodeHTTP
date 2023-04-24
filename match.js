// Bibliotheken
const express = require('express');
const connect = require('../utils/db');


// Variabele
const router = express.Router();

// Middleware to parse request body
router.use(express.json());

// Endpoint voor het verkrijgen van alle clubs data.
router.post('/', async (req, res) => {

  console.log(req.body);

  await connect(async (db) => {
    const collection = db.collection('Match');
    const insertResult = await collection.insertMany(req.body);
    console.log('Inserted documents =>', insertResult);
  });

});

// Endpoint voor het verkrijgen van specifieke club data.
router.get('/:clubid', (req, res) => {
  res.send('TODO: ' + req.params.clubid);
});

module.exports = router;