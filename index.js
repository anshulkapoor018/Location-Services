const express = require("express");
const app = express();
const configRoutes = require("./routes");

app.use(express.json());
configRoutes(app);

app.set('port', (process.env.PORT || 5000));
// app.listen(PORT, () => {
//     console.log(`Our app is running on port ${ PORT }`);
// });

//For avoidong Heroku $PORT error
app.get('/', function(request, response) {
    var result = 'App is running'
    response.send(result);
}).listen(app.get('port'), function() {
    console.log('App is running, server is listening on port ', app.get('port'));
});

// app.listen(process.env.PORT, '0.0.0.0')
//   , () => {
//   console.log("We've now got a server!");
//   console.log("Your routes will be running on http://localhost:3000");
// });