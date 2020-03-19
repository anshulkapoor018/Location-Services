import mongodb from 'mongodb';

export default {
  "port": process.env.PORT,
  "mongoUrl": "mongodb://django:12345A@ds113845.mlab.com:13845/location_history",
  "bodyLimit": "100kb"
}