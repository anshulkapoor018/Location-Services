const locationRoutes = require('./location');
const constructorMethod = (app) => { 
 
    app.use('/location', locationRoutes);
    app.use('*', (req, res) => {   
        res.status(404).json({ error: 'Not found' });  
    }); 
};  
module.exports = constructorMethod;