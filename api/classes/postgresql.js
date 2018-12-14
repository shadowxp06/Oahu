class postgresql {

    constructor() {
        this.utils = require('../utils/utils.js');
        this.logging = require('../utils/logging.js');
        this.config = this.utils.getConfig();


        let pgp = require('pg-promise')(/*options*/);
        this.db = pgp(this.config.db);

        this.baseenums = require('../enums/base-enums.js');
    }

    getDBObject() {
        return this.db;
    }

    /* Parameters must be in the form of an array IE: ['test','test1',123] */
    execute(procName, parameters) {
        let db = this.getDBObject();
        let retData = []; /* This should be returning a JSON Object */
        if (db) {
            db.proc(procName, parameters).then(function (data) {
               retData = data;
            }).catch(function (error) {
                retData = error;
            });
        }

        return retData
    }

    /* Parameters must be in the form of an array IE: ['test','test1',123] */
    executeProcedure(res, procName, parameters) {
        let db = this.getDBObject();
        if (db) {
            db.func(procName, parameters).then(function (data) {
                res.send(data[0][procName]);
            }).catch(function (error) {
                res.send(error);
            });
        }
    }

    executeProcNoRet(procName, parameters) {
        let db = this.getDBObject();
        if (db) {
            return db.func(procName,parameters);
        }
    }

     isValidToken(token) {
        let db = this.getDBObject();
        if (db) {
            let map = new Map();
            map.set('Ticket', token);
            return global.db.queryOne('Sessions', '', map);
        }
    }

    executeQuery(query, parameters) {
        let db = this.getDBObject();
        if (db) {
            return db.any(query, parameters);
        }
    }

        queryOne(table, columns, whereClause) {
            if (table) {
                let queryString = 'SELECT ';
                let columnsstr = '*';
                let db = this.getDBObject();

                if (columns && columns != '') {
                    columnsstr = ''; //Clear it before iteration
                    columns.forEach(function(value, index) {
                        columnsstr += "\"" + value + "\"";
                        if (((index+1) != columns.length)) { columnsstr += ","; }
                    });
                }
                queryString += columnsstr + " FROM \"" + table + "\"";

                if (whereClause) {
                    queryString += " WHERE ";
                    let mapSize = 0;
                    let inc = 1;
                    let ourParams = [];

                    for (const [key, value] of whereClause.entries()) {
                        queryString += "\"" + key + "\" = $" + inc; // Create the Parameterized SQL Query
                        ourParams.push(value); //Push it to the Array
                        mapSize += 1;
                        inc += 1;
                        if (mapSize != whereClause.size) {
                            queryString += ",";
                        }
                    }

                    queryString += ";";

                    if (db)
                    {
                        return db.oneOrNone(queryString, ourParams).then(data => {
                            return data;
                        }).catch(error => {
                            this.logging.writeToFile(this.baseenums.LogLevel.Error, error, "postgresql");
                        })
                    }
                }else {
                    if (db) {
                        return db.any(queryString).then(
                            data => {
                                return data;
                            }
                        ).catch(error => {
                            this.logging.writeToFile(this.baseenums.LogLevel.Error, error, "postgresql");
                        })
                    }
                }
            }
            return "Missing Table Name";
        }
}

module.exports = postgresql;