const express = require("express");
const router = express.Router();
const data = require('../data/');
const location = data.location;

router.get("/:id", async (req, res) => {
  try {
    const locationData = await location.getLocationHistory(req.params.id);
    res.status(200).json(locationData);
  } catch (e) {
    res.status(404).json({ message: "location not found!" });
  }
});

router.get("/", async (req, res) => {
  try {
    const locationList = await location.getAllLocationHistory();
    res.status(200).json(locationList);
  } catch (e) {
    // Something went wrong with the server!
    res.status(404).send();
  }
});

router.get("/limit/5", async (req, res) => {
  try {
    const locationList = await location.getLocationHistoryLimited();
    res.status(200).json(locationList);
  } catch (e) {
    // Something went wrong with the server!
    res.status(404).send();
  }
});
// https://location-history-server.herokuapp.com/location/date/2010-03-12/2020-03-13
router.get("/date/:startDate/:endDate", async (req, res) => {
  try {
    const locationList = await location.getLocationHistoryInRange(req.params.startDate, req.params.endDate);
    res.status(200).json(locationList);
  } catch (e) {
    // Something went wrong with the server!
    res.status(404).send();
  }
});

router.post('/', async (req, res) => {
	const locationData = req.body;
	if (!locationData.latitude) {
		res.status(400).json({ error: 'You must provide latitude for the location' });
		return;
	}
	if (!locationData.longitude) {
		res.status(400).json({ error: 'You must provide longitude for the location' });
		return;
	}
	try {
		const { latitude, longitude} = locationData;
        const newLocation = await location.addLocationHistory(locationData.latitude, locationData.longitude)
        res.json(newLocation);
	} catch (e) {
		res.status(500).json({ error: e });
	}
});


module.exports = router;