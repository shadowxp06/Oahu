let utils = require('./utils.js');
let baseenums = require('../enums/base-enums.js');
let winston = require('winston');
let config = utils.getConfig();

let logTransport = [ /* For Production, let's separate out the log files */
    new winston.transports.File({ filename: config.app.logdir + 'errors.json', level: 'error' }),
    new winston.transports.File({ filename: config.app.logdir + 'info.json', level: 'info' }),
    new winston.transports.File({ filename: config.app.logdir + 'warn.json', level: 'warn' }),
    new winston.transports.File({ filename: config.app.logdir + 'verbose.json', level: 'verbose' }),
    new winston.transports.File({ filename: config.app.logdir + 'debug.json', level: 'debug' })

];

if (utils.isDev())  {
    logTransport = [
        new winston.transports.File({ filename: config.app.logdir + 'errors.json' }),
        new winston.transports.File({ filename: config.app.logdir + 'debug.json', level: 'debug' }),
        new winston.transports.Console()
    ]
}


//Format partially borrowed from: https://github.com/winstonjs/winston/issues/1134
const logger = winston.createLogger({
    level: 'silly',
    transports: logTransport,
    format: winston.format.combine(
        winston.format.timestamp({
            format: 'YYYY-MM-DD HH:mm:ss'
        }),winston.format.json())
});

module.exports = {
    writeToFile: function (logLevel, logMessage, module)
    {
        switch(logLevel) {
            case baseenums.LogLevel.Warn:
                logger.warn(logMessage, { module: module });
                break;
            case baseenums.LogLevel.Error:
                logger.error(logMessage, { module: module });
                break;
            case baseenums.LogLevel.Info:
                logger.info(logMessage, { module: module });
                break;
            case baseenums.LogLevel.Verbose:
                logger.verbose(logMessage, { module: module });
                break;
            case baseenums.LogLevel.Debug:
                logger.debug(logMessage, { module: module });
                break;
            default:
                logger.log({ level: 'info', message: logMessage });
                break;
        }

    },
    writeToDB: function(logMessage, logLevel, module) //TODO: Create Table Schema
    {
        this.writeToFile(logMessage, logLevel, module); // In case DB fails for whatever reason, write it out to File
        switch(logLevel) {
            case baseenums.LogLevel.Warn:
                break;
            case baseenums.LogLevel.Error:
                break;
            case baseenums.LogLevel.Info:
                break;
            case baseenums.LogLevel.Verbose:
                break;
            case baseenums.LogLevel.Debug:
                break;
            default:
                break;
        }
    }
};