const locationRoutes = require('./location');
const constructorMethod = (app) => { 
    // Base URL test endpoint to see if API is running
    app.get('/', (req, res) => {
        res.json({ message: 'API is LIVE!' })
    });
    app.use('/location', locationRoutes);
    app.use('*', (req, res) => {   
        res.status(404).json({ error: 'Not found' });  
    }); 
};  
module.exports = constructorMethod;