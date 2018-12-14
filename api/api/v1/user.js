let express = require('express');
let router = express.Router();
let utils = require('../../utils/utils.js');
let responseModel = require('../../models/v1/response');
let pug = require('pug');

/* Helper Functions */
function getMessage(token, id) {
    return global.db.executeProcNoRet('get_message', [token, id]);
}
/* End */

router.post('/init', function (req, res) { /* This may need to change to Get */
        /* initializes a user at first login.  This must be done before login is allowed.  Users
          * can be added to a course before they are initialized though. */
        let token =  utils.getAuthTokenFromHeader(req.headers.authorization);
        let loginName = req.body.LoginName;
        let firstName = req.body.FirstName;
        let lastName = req.body.LastName;
        let email = req.body.Email;
        global.db.executeProcedure(res,'init_user',[token,loginName,firstName,lastName,email]);
    })
    .get('/settings', function (req, res) {
        /* gets all settings related to this user.  Gets the same data as /setting
         * but retrieves everything related to this user.
         * Returns a list of : { Name, Value  } */
        let token =  utils.getAuthTokenFromHeader(req.headers.authorization);
        global.db.executeProcedure(res,'get_user_settings',[token]);
    })
    .post('/setting', function (req, res) {
        /* Set Setting - sets a default setting for this user for all classes.  This overrides
        * both system defaults and instructor set course defaults.  You are responsible for ensuring
        * that a student can not override an instructors setting unless you want them to. */
        let token =  utils.getAuthTokenFromHeader(req.headers.authorization);
        let settingName = req.body.Name;
        let settingValue = req.body.Value;
        global.db.executeProcedure(res,'set_user_default_setting',[token,settingName,settingValue]);

    })
    .post('/settings', function (req, res) {
        /* Updates all of the user settings at once */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let item = { "ErrNo": "0", "Description": "Success"};
        for(let index = 0; index < req.body.length; index++) {
            const setName = req.body[index]['Name'];
            const setValue = req.body[index]['Value'];
           item = global.db.executeProcNoRet('set_user_default_setting', [token, setName, setValue]);
        }
        res.send(item);
    })
    .post('/favorites', function (req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        global.db.isValidToken(token).then(function (response) {
            if (response) {
                model = new responseModel();
                model.ErrNo = '1';
                model.Description = 'Invalid Session.';

                let userID = req.body.UserID;
                let value = req.body.Value;

                global.db.executeQuery('SELECT * from "Settings" WHERE "UserID" = $1 and "Name"=\'favorites\';', [userID]).then(response => {
                    if (response) {
                        if (response.length == 0) {
                            if (value > 0) {
                                let item = "[{ \"postId\": " + value + " }]";
                                global.db.executeProcedure(res, 'set_user_default_setting', [token, req.body.Name, item]);
                            } else {
                                model.ErrNo = '8';
                                model.Description = 'Cannot find Post ID';
                                res.send(model);
                            }
                        } else {
                            let intItem = response[0];
                            let jsonObj = JSON.parse(intItem.Value);
                            let doSave = true;

                            for(let m = 0; m < jsonObj.length; m++) {
                                if (jsonObj[m]['postId'] === value) {
                                    doSave = false;
                                    model.Description = 'This has already been added.';
                                    model.ErrNo = '9';
                                }
                            }

                            if (doSave) {
                                jsonObj.push(JSON.parse("{ \"postId\": " + value + " }"));
                                global.db.executeProcedure(res, 'set_user_default_setting', [token, req.body.Name, JSON.stringify(jsonObj)]);
                            } else {
                                res.send(model);
                            }
                        }
                    } else {
                        res.send(model);
                    }
                });

            } else {
                let item = { "ErrNo": "999", "Description": "Invalid Session."};
                res.send(item);
            }
        });
    })
    .get('/favorites/:id', function (req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let userId = req.params.id;
        resModel = new responseModel();
        resModel.ErrNo = '1';
        resModel.Description = 'Invalid Session.';
        global.db.isValidToken(token).then(function (response) {
            if (response) {
                global.db.executeQuery('SELECT * from "Settings" WHERE "UserID" = $1 and "Name" = \'favorites\';', userId).then(setData => {
                    if (setData && setData.length > 0) {
                        let item = JSON.parse(setData[0]['Value']);

                        if (item) {
                            let promises = [];
                            for(let i = 0; i < item.length; i++) {
                                promises.push(getMessage(token, item[i]['postId']));
                            }

                            Promise.all(promises).then((response) => {
                               if (response) {
                                   let msgs = [];
                                   for(let n = 0; n < response.length; n++) {
                                       msgs.push(response[n][0]['get_message']['Message']);
                                   }
                                   res.send(msgs);
                               } else {
                                   res.send(resModel);
                               }
                            });
                        }
                    } else {
                        res.send(resModel);
                    }
                })
            } else {
                res.send(resModel);
            }
        });
    })
    .get('/testpug', function (req, res) {

    })
;


module.exports = router;