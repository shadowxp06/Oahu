let express = require('express');
let router = express.Router();
let responseModel = require('../../models/v1/response');
let jwt = require('jsonwebtoken');
let passport = require("passport");
let passportJWT = require("passport-jwt");
let utils = require('../../utils/utils.js');
let baseEnums = require('../../enums/base-enums');
let fs = require('fs');

// Based off of https://jonathanmh.com/express-passport-json-web-token-jwt-authentication-beginners/
let ExtractJwt = passportJWT.ExtractJwt;
let JwtStrategy = passportJWT.Strategy;
let jwtOptions = {};

jwtOptions.jwtFromRequest = ExtractJwt.fromAuthHeaderAsBearerToken();
jwtOptions.secretOrKey = 'tasmanianDevil'; /* Need to change this for production */

let strategy = new JwtStrategy(jwtOptions, function(jwt_payload, next) {
});

passport.use(strategy);


router.post('/register', function (req, res) {
        let UserName = req.body.UserName;
        let Password = req.body.Password;
        let FirstName = req.body.FirstName;
        let LastName = req.body.LastName;
        let Email = req.body.Email;
        let ValidationKey = Math.random().toString(36).substring(2, 15)
            + Math.random().toString(36).substring(2, 15)
            + Math.random().toString(36).substring(2, 15);

        if (utils.isDev()) {
            console.log('Validation Key: ', ValidationKey);
            global.db.executeProcNoRet('local_login_create_user', [UserName,Password,FirstName,LastName,Email,ValidationKey]).then(data => {
                if (data[0]['local_login_create_user']['ErrNo'] == '0') {
                    let model = new responseModel();
                    model.ErrNo = '0';
                    model.Description = 'Success';
                    res.send(model);
                } else {
                    res.send(data[0]['local_login_create_user']);
                }
            });
        } else {
            let email = '';

            fs.readFile("templates/user-registration.html", "utf8", function(err, data) {
                if (err) {
                    resp = new responseModel();
                    resp.ErrNo = 9;
                    resp.Description = 'Could not open User Registration Template.  Please contact an administrator for more help with this.';
                    res.send(resp);
                } else {
                    email = data.replace('{{access_key}}', ValidationKey);
                }

            });

            global.db.executeProcNoRet('local_login_create_user', [UserName,Password,FirstName,LastName,Email,ValidationKey]).then(data => {
                if (data[0]['local_login_create_user']['ErrNo'] == '0') {
                    global.email.sendMail(Email, 'OMS Discussions User Activation', email);
                    let model = new responseModel();
                    model.ErrNo = '0';
                    model.Description = 'Success';
                    res.send(model);
                } else {
                    res.send(data[0]['local_login_create_user']);
                }
            });
        }

    })

    .post('/', function(req,res) {
        let UserName = req.body.UserName;
        let Password = req.body.Password;

        const payload = { userId: UserName, Rand: utils.getConfig().app.access_key_random };
        let token = jwt.sign(payload,jwtOptions.secretOrKey);

        global.db.executeProcedure(res,'local_login_get_user',[token,UserName,Password]);

    })
    .get('/validate/:key', function (req, res) {
        let ValidationKey = req.params['key'];
        if (ValidationKey != "") {
            global.db.executeProcedure(res,'local_login_validate',[ValidationKey]);
        }
    });

module.exports = router;