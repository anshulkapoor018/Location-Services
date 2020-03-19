const express = require("express");
const app = express();
const configRoutes = require("./routes");

app.use(express.json());
configRoutes(app);

app.listen(process.env.PORT || 3000, function(){
    console.log("Express server listening on port %d in %s mode", this.address().port, app.settings.env);
});