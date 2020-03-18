const connection = require('../config/mongoConnection');
const data = require('../data/');
const location = data.location;


const main = async () => {
    const db = await connection();
	await db.dropDatabase();
	//Creating first Location
    const Home = await location.addLocationHistory("44.4647452", "7.3553838")
    const College = await location.addLocationHistory("40.7469274", "-74.0345757")

    console.log('Done seeding database for Location Collection!');
	await db.serverConfig.close();
};

main().catch(error => {
    console.log(error);
});