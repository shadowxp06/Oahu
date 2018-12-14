let express = require('express');
let jwt = require('jsonwebtoken');
let passport = require("passport");
let passportJWT = require("passport-jwt");
let router = express.Router();
let utils = require('../../utils/utils.js');
let md5 = require('md5');
let baseEnums = require('../../enums/base-enums');

let request = require('request');


// Based off of https://jonathanmh.com/express-passport-json-web-token-jwt-authentication-beginners/
let ExtractJwt = passportJWT.ExtractJwt;
let JwtStrategy = passportJWT.Strategy;
let jwtOptions = {};

jwtOptions.jwtFromRequest = ExtractJwt.fromAuthHeaderAsBearerToken();
jwtOptions.secretOrKey = 'tasmanianDevil'; /* Need to change this for production */

let strategy = new JwtStrategy(jwtOptions, function(jwt_payload, next) {
});

passport.use(strategy);



router.post('/', function (req, res) {
    let username = req.body['user'].match(/^([^@]*)@/)[1]; /* https://stackoverflow.com/questions/7266608/how-can-i-extract-the-user-name-from-an-email-address-using-javascript */
    let pass = req.body['pass'];
    let userMap = new Map();
    userMap.set('User', username);

    let item = { "ErrNo": "1", "Description": "Invalid Username or Password."};

    if (pass) {
        if (utils.isDev() && utils.getConfig().app.dev_mode_bypass_security) {
            let payload = { userId: username, Rand: utils.getConfig().app.access_key_random }; /* Need to add random numbers and letters */
            let token = jwt.sign(payload,jwtOptions.secretOrKey);
            global.db.executeProcNoRet('login', [token, username]).then(data => {
                if (data[0]['login']['ErrNo'] == '0') {
                    global.db.executeProcNoRet('db_get_user_id_from_session', [token]).then(data => { /* TODO: Change login procedure to include UID */
                        item = {
                            "jwtToken": token,
                            "ErrNo": 0,
                            "userName": username,
                            "userId": data[0]['db_get_user_id_from_session']
                        };
                        res.send(item);
                    })
                } else {
                    item = { "ErrNo": "1", "Description": "Invalid Username or Password."};
                    res.send(item);
                }
            }).catch(error => {
                if (utils.isDev()) {
                    console.log(error);
                }
                global.errLogging.writeToFile(baseEnums.LogLevel.Error, error, 'auth v1 (isDev, Security ByPass)');
            });
        } else {
            global.db.queryOne('AdminUsers', '', userMap).then(function (response) {
                const encPass = md5(pass);
                if (response) {
                    if (response['Password'] === encPass) {
                        let payload = { userId: response['User'], Rand: utils.getConfig().app.access_key_random };
                        let token = jwt.sign(payload,jwtOptions.secretOrKey);

                        global.db.executeProcNoRet('login', [token, username]).then(data => {
                            if (data[0]['login']['ErrNo'] == '0') {
                                global.db.executeProcNoRet('db_get_user_id_from_session', [token]).then(data => { /* TODO: Change login procedure to include UID */
                                    item = {
                                        "jwtToken": token,
                                        "ErrNo": 0,
                                        "userName": username,
                                        "userId": data[0]['db_get_user_id_from_session']
                                    };
                                    res.send(item);
                                })
                            } else {
                                item = { "ErrNo": "1", "Description": "Invalid Username or Password."};
                                res.send(item);
                            }
                        }).catch(error => {
                            if (utils.isDev()) {
                                console.log(error);
                            }
                            global.errLogging.writeToFile(baseEnums.LogLevel.Error, error, 'auth v1');
                        });
                    } else {
                        res.send(item);
                    }
                }
            });
        }
    }
})
    /*
    .get('/caslogin/:token', function (req, res) {
        if (req.params['token'] != "") {

        }else {
            userModel.error = 'Missing token from CAS';
            userModel.status = 'fail';
        }
    })
    */





    .get('/caslogin', function (req, res) {
        res.writeHead(301,{location: 'https://cas-test.gatech.edu/cas/login?service=http://gatech.edu/.../casloginreply'}
        );
        res.end();
    })



    .post('/casloginreply', function(req,res) {
        let ticket =  req.query.ticket;
        request({
            uri: 'https://cas-test.gatech.edu/cas/serviceValidate',
            qs: {
                ticket: ticket
            }
        }).pipe(res);

        /* This sends the response back to the browser but what really needs to happen is the data needs
        to be processed here.  It looks like
            <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
                <cas:authenticationSuccess>
                    <cas:user>endjs</cas:user>
                </cas:authenticationSuccess>
            </cas:serviceResponse>

        So we need to process the XML which probably requires a library or module whatever you call them
        https://github.com/Leonidas-from-XIV/node-xml2js
        npm install xml2js


        var parseString = require('xml2js').parseString;

        parseString(xml, function (err, result) {
            global.db.executeProcNoRet(res,'db_login',[ticket,result.user,2]).then(data => {
                if (data[0]['db_login']['ErrNo'] == '0') {
                    // I am not sure what to do here, since the request was sent outside our browser from gatech cas.
                    // how do I get a reply back to our browser?
                    res.send(data);
                } else {
                    res.send(data[0]['db_login']);
                }
        });
         */


    });

/*
An example of how to add a login session to the database.

        let userName = // string of the user name being logged in: eg. bdavis327 (get from CAS)
        let token = // string that you get from cas or JWT or any unique string you want to use.
        // res is the res in the post function call for the route.
        global.db.executeProcedure(res,'login',[token,userName]);


        Whatever you put into token is the same token that is used to call all functions.  As long as
        it is a unique string, it does not matter what it is.


 */


module.exports = router;