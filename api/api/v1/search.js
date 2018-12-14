let express = require('express');
let router = express.Router();
let utils = require('../../utils/utils.js');
let responseModel = require('../../models/v1/response');


router.post('/', function(req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);

        if (req.body['UserGroupID'] == 0) {
                delete req.body['UserGroupID'];
        }

        if (req.body['MessageGroupID'] == 0) {
                delete req.body['MessageGroupID'];
        }

        if (req.body['CourseID'] == 0) {
                delete req.body['CourseID'];
        }

        if (req.body['CreationTimeGTE'] == '') {
                delete req.body['CreationTimeGTE'];
        }

        if (req.body['CreationTimeLTE'] == '') {
                delete req.body['CreationTimeLTE'];
        }

        if (req.body['ChildCountLTE'] == 0) {
                delete req.body['ChildCountLTE'];
        }

        if (req.body['ScoreGTE'] == 0) {
                delete req.body['ScoreGTE'];
        }

        if (req.body['ScoreLTE'] == 0) {
                delete req.body['ScoreLTE'];
        }

        delete req.body['name'];

        let criteria = req.body;

        global.db.executeProcedure(res, 'search_messages', [token, criteria]);
    })
    .post('/save/:id', function (req, res) {
            respModel = new responseModel();
            respModel.ErrNo = '1';
            respModel.Description = 'Invalid Session';

            let token = utils.getAuthTokenFromHeader(req.headers.authorization);
            let userId = req.params.id;
            global.db.isValidToken(token).then(function (response) {
                if (response) {
                    global.db.executeQuery('SELECT * from "Settings" WHERE "UserID" = $1 and "Name" = \'savedSearches\';', [userId]).then(data => {
                        if (data) {
                            if (data.length == 0) {
                                let arr = [];
                                arr.push(req.body);
                                global.db.executeProcedure(res, 'set_user_default_setting', [token, 'savedSearches', JSON.stringify(arr)]);
                            } else {
                                if (utils.isJson(data[0]['Value'])) {
                                    let arr = JSON.parse(data[0]['Value']);

                                    if (arr.length == undefined) {
                                        let arr2 = [];
                                        arr2.push(arr);
                                        arr2.push(JSON.parse(req.body));
                                        arr = arr2;
                                    } else {
                                        arr.push(req.body);
                                    }

                                    global.db.executeProcedure(res, 'set_user_default_setting', [token, 'savedSearches', JSON.stringify(arr)]);
                                } else {
                                    respModel.ErrNo = '20';
                                    respModel.Description = 'Invalid JSON';
                                    res.send(respModel);
                                }

                            }
                        } else {
                            res.send(respModel);
                        }
                    })
                }
            })
    })
    .post('/lookup', function (req, res) {
        respModel = new responseModel();
        respModel.ErrNo = '1';
        respModel.Description = 'Invalid Session';

        let userId = req.body.userId;
        let name = req.body.name;
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);

        global.db.isValidToken(token).then(function (response) {
            if (response) {
                global.db.executeQuery('SELECT * From "Settings" WHERE "UserID" = $1 AND "Name" = \'savedSearches\';', [userId]).then(function (resp2) {
                    let arr2 = JSON.parse(resp2[0]['Value']);
                    let foundItem;

                    for (let n = 0; n < arr2.length; n++) {
                        if (arr2[n].name === name) {
                            foundItem = arr2[n];
                            n = arr2.length + 1;
                        }
                    }

                    if (foundItem) {
                        global.db.executeProcedure(res, 'search_messages', [token, JSON.stringify(removeExtraInfo(foundItem))]);
                    } else {
                        respModel.ErrNo = '0';
                        respModel.Description = 'No results found.';
                        res.send(respModel);
                    }
                });
            } else {
                res.send(respModel);
            }
        });
    });

/* Class Helper Utilities */
function removeExtraInfo(data) {
    if (data.UserGroupID === 0) {
        delete data.UserGroupID;
    }

    if (data.MessageGroupID === 0) {
        delete data.MessageGroupID;
    }

    if (data.CourseID === 0) {
        delete data.CourseID;
    }

    if (data.CreationTimeGTE === '') {
        delete data.CreationTimeGTE;
    }

    if (data.CreationTimeLTE === '') {
        delete data.CreationTimeLTE;
    }

    if (data.ChildCountGTE === 0) {
        delete data.ChildCountGTE;
    }

    if (data.ScoreGTE === '') {
        delete data.ScoreGTE;
    }

    if (data.ScoreLTE === '') {
        delete data.ScoreLTE;
    }

    delete data.name;
    delete data.IsThhread;

    return data;
}
/* End of Class Helper Utillies */

module.exports = router;


