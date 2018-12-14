let moment = require('moment');

module.exports = {
    getConfig: function() {
        let config;
        if (!this.isDev()) {
            config = require('../config/config.prod.js');
        }else {
            config = require('../config/config.qa.js');
        }
        return config;
    },
    getEnvironment: function() {
        if (process.env.NODE_ENV === undefined) {
            return 'dev';
        }
        return process.env.NODE_ENV;
    },
    isDev: function() {
        return this.getEnvironment() === 'dev' || this.getEnvironment() === undefined;
    },
    generateCourseAccessCode: function(CourseName,Semester,Section) {
        //Code borrowed from https://stackoverflow.com/questions/5878682/node-js-hash-string
        let crypto = require('crypto');
        let accessCode = CourseName +'-' + Semester + "-"+Section + "-" + this.generateRandomNumber();
        return crypto.createHash('sha512').update(accessCode).digest('hex');
    },
    generateRandomNumber: function() {
        let randInt = require('random-int');
        return randInt(99999999999999999999);
    },
    getAuthTokenFromHeader: function(header) {
        if (header && header.split(' ')[0] === 'Bearer') { /* Always pass in req.headers.authorization */
            return header.split(' ')[1];
        } else {
            return 'Invalid Header';
        }
    },
    getCurrentDate: function() {
        return moment().format("MM/DD/YYYY");
    },
    isJson: function(str) {
        try {
            JSON.parse(str);
        } catch(e) {
            return false;
        }

        return true;
    }
};