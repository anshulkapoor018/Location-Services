const mongoCollections = require('../config/mongoCollections');
const locations = mongoCollections.location;

function currentTimestamp(){
    let date_ob = new Date();
    // current date
    // adjust 0 before single digit date
    let date = ("0" + date_ob.getDate()).slice(-2);

    // current month
    let month = ("0" + (date_ob.getMonth() + 1)).slice(-2);

    // current year
    let year = date_ob.getFullYear();

    // current hours
    let hours = date_ob.getHours();

    // current minutes
    let minutes = date_ob.getMinutes();

    // current seconds
    let seconds = date_ob.getSeconds();

    let timestamp = year + "-" + month + "-" + date + " " + hours + ":" + minutes + ":" + seconds

    return timestamp
}

async function addLocationHistory(latitude, longitude) {
    const locationCollection = await locations();

    if (!latitude) throw 'You must provide latitude';

    if (!longitude) throw 'You must provide latitude';

    let newLocation = {
        latitude: latitude,
        longitude: longitude,
        timestamp: currentTimestamp()
    };

    const insertInfo = await locationCollection.insertOne(newLocation);
    if (insertInfo.insertedCount === 0) throw 'Could not add new Location';

    const newId = insertInfo.insertedId;
    const newIDString = String(newId);
    const locationObj = await this.getLocationHistory(newIDString);
    return locationObj;
}

async function getAllLocationHistory() {
    const locationCollection = await locations();

    const locationsData = await locationCollection.find({}).toArray();

    return locationsData;
}

async function getLocationHistory(id) {
    if (!id) throw 'You must provide an id to search for';
    const locationCollection = await locations();
    const { ObjectId } = require('mongodb');
    const objId = ObjectId.createFromHexString(id);
    const locationSearch = await locationCollection.findOne({_id: objId});
    if (locationSearch === null){
        throw 'No Location with id - ' + id;
    }

    return locationSearch;
}

async function updateLocationHistory(locationId, latitude, longitude) {
    if (!locationId) throw 'You must provide an id to search for';

    if (!latitude) throw 'You must provide latitude';

    if (!longitude) throw 'You must provide latitude';

    const locationCollection = await location();
    const { ObjectId } = require('mongodb');
    const objId = ObjectId.createFromHexString(locationId);

    const updatedLocation = {
        latitude: latitude,
        longitude: longitude,
        timestamp: currentTimestamp()
    };

    const updatedInfo = await locationCollection.updateOne({_id: objId}, {$set: updatedLocation});
    if (updatedInfo.modifiedCount === 0) {
      throw 'could not update location successfully';
    }

    return await this.getLocationHistory(locationId);
}

async function removeLocationHistory(locationId) {
    if (!locationId) throw 'You must provide an id to search for';

    const locationCollection = await location();
    const { ObjectId } = require('mongodb');
    const objId = ObjectId.createFromHexString(locationId);
    const locationSearch = await locationCollection.findOne({_id: objId});
    if (locationSearch === null){
        throw 'No location with id - ' + locationId;
    } else{
        const deletionInfoForLocation = await bandCollection.removeOne({_id: objId});
        if (deletionInfoForLocation.deletedCount === 0) {
            throw `Could not delete location with id of ${locationId}`;
        }
        return true;
    }
}

module.exports = {
    addLocationHistory,
    getAllLocationHistory, 
    getLocationHistory, 
    updateLocationHistory,
    removeLocationHistory
}