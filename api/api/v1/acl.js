let express = require('express');
let router = express.Router();
let utils = require('../../utils/utils.js');
let responseModel = require('../../models/v1/response');
let fs = require('fs');
router.get('/', function (req, res) {

})
    .post('/:courseid', function (req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let courseId = req.params.courseid;
        respModel = new responseModel();
        respModel.ErrNo = '1';
        respModel.Description = 'Invalid Session.';
        global.db.isValidToken(token).then(function (response) {
            if (response && courseId > 0) {
                let userTypeValue = 1; // 1 for Student, 2 for TA
                if (req.body['Demote'] == false) {
                    userTypeValue = 2;
                }

                let id = req.body['ID'];

                global.db.executeQuery('UPDATE "CourseMembers" set "UserType" = $1 WHERE "UserID" = $2 and "CourseID" = $3;', [userTypeValue, id, courseId]).then(function (resp) {
                    if (resp) {

                        respModel.ErrNo = '0';
                        respModel.Description = 'Success!';
                        res.send(respModel);
                    } else {
                        respModel.ErrNo = '1';
                        respModel.Description = 'An error has occurred.';
                        res.send(respModel);
                    }
                });
            } else {
                res.send(respModel);
            }
        })
    })
    .post('/enroll/:courseid', function (req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let courseId = req.params.courseid;
        respModel = new responseModel();
        respModel.ErrNo = '1';
        respModel.Description = 'Invalid Session.';
        global.db.isValidToken(token).then(function (response) {
            if (response && courseId > 0) {
                global.db.executeQuery('SELECT * from "Users" WHERE "LoginName" = $1;', [req.body.LoginName]).then(function (resp2) {
                   if (resp2) {
                       if (resp2.length > 0) {
                           if (req.body.UserType === '1') {
                               global.db.executeProcNoRet('add_student_to_course',[token,req.body.LoginName, courseId]).then(function (resp3) {
                                   if (resp3) {
                                       if (resp3[0]['add_student_to_course']['ErrNo'] === '0') {
                                           let email = '';
                                           fs.readFile("templates/v1/enrollment-notice.html", "utf8", function (err, data) {
                                               if (err) {
                                                   if (utils.isDev()) {
                                                       console.log(err);
                                                   }
                                                   global.errLogging.writeToFile(enums.LogLevel.Error, err, 'Create Thread - Email');
                                               } else {
                                                   email = data;
                                                   if (!utils.isDev()) {
                                                       global.email.sendMail(req.body.LoginName, 'Course Enrollment Notification', email);
                                                   }
                                               }
                                           });
                                           res.send(resp3[0]['add_student_to_course']);
                                       } else {
                                           res.send(resp3[0]['add_student_to_course']);
                                       }
                                   } else {
                                       res.send(respModel);
                                   }
                               });
                           } else if (req.body.UserType === '2') {
                               global.db.executeProcNoRet('add_ta_to_course',[token,req.body.LoginName, courseId]).then(function (resp3) {
                                   if (resp3) {
                                       if (resp3[0]['add_ta_to_course']['ErrNo'] === '0') {
                                           let email = '';
                                           fs.readFile("templates/v1/enrollment-notice.html", "utf8", function (err, data) {
                                               if (err) {
                                                   if (utils.isDev()) {
                                                       console.log(err);
                                                   }
                                                   global.errLogging.writeToFile(enums.LogLevel.Error, err, 'Create Thread - Email');
                                               } else {
                                                   email = data;
                                                   if (!utils.isDev()) {
                                                       global.email.sendMail(req.body.LoginName, 'Course Enrollment Notification', email);
                                                   }
                                               }
                                           });
                                           res.send(resp3[0]['add_ta_to_course']);
                                       } else {
                                           res.send(resp3[0]['add_ta_to_course']);
                                       }
                                   } else {
                                       res.send(respModel);
                                   }
                               });
                           } else {
                               respModel.ErrNo = '11';
                               respModel.Description = 'Invalid User Type';
                           }
                       } else {
                           respModel.ErrNo = '10';
                           respModel.Description = 'User does not exist.';
                           res.send(respModel);
                       }
                   } else {
                       res.send(respModel);
                   }
                });
            } else {
                res.send(respModel);
            }
        });
    });


module.exports = router;