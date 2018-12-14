// Based off of the example from: https://scotch.io/tutorials/build-a-restful-api-using-node-and-express-4
let express    = require('express');
let helmet    = require('helmet');
let app        = express();
let bodyParser = require('body-parser');
let utils = require('./utils/utils.js');
let postgresql = require('./classes/postgresql.js');
let config = utils.getConfig();
let passport = require("passport");
let cors = require('cors');

let corsOptions = {
    origin: process.env.CORS_ALLOW_ORIGIN || '*',
    methods: ['GET', 'PUT', 'POST', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
};

// configure app to use bodyParser()
// this will let us get the data from a POST
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(passport.initialize());
app.use(helmet()); // Used for Protection against known vulnerabilities
if (config.app.use_inbuilt_cors == true) {
    app.use(cors(corsOptions));
}

/* App Routing */
let userapi = require('./api/v1/user.js');
let courseapi = require('./api/v1/course.js');
let aclapi = require('./api/v1/acl.js');
let authapi = require('./api/v1/auth.js');
//let authcasapi = require('./api/v1/authcas.js');
//let authcanvasapi = require('./api/v1/authcanvas.js');
let searchapi = require('./api/v1/search.js');
let attachmentsapi = require('./api/v1/attachments.js');
let messageapi = require('./api/v1/message.js');
let adminapi = require('./api/v1/admin.js');
let groupsapi = require('./api/v1/groups.js');

/* Route Registration */
app.use('/api/v1/user', userapi);
app.use('/api/v1/course', courseapi);
app.use('/api/v1/auth', authapi);
app.use('/api/v1/acl', aclapi);
//app.use('/api/v1/authcas', authcasapi);
//app.use('/api/v1/authcanvas', authcanvasapi);
app.use('/api/v1/search', searchapi);
app.use('/api/v1/attachments', attachmentsapi);
app.use('/api/v1/message', messageapi);
app.use('/api/v1/admin', adminapi);
app.use('/api/v1/groups', groupsapi);

global.db = new postgresql();
global.errLogging = require('./utils/logging.js');
global.email = require('./utils/email.js');

app.listen(config.app.port, function () {
    console.log("API layer is running on port " + config.app.port + " (" + utils.getEnvironment() + ")");
});