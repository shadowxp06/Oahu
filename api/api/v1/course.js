let express = require('express');
let router = express.Router();
let utils = require('../../utils/utils.js');
let moment = require('moment');
let courseModel = require('../../models/v1/course');
let groupModel = require('../../models/v1/groups');
let groupMemberModel = require('../../models/v1/groupMember');
let responseModel = require('../../models/v1/response');

router.get('/', function (req, res) {
        /*  Gets a list of all courses that this user is in - including inactive ones
        * Returns list of:
        * {ID,Number,Name,StartDate,EndDate,UserType}
        * Number - The course number such as "CS101"
        * Name - The course name "Introduction to Computer Science"
        * UserType - the type of this user in the course: 1-student,2-TA,3-Instructor
        * StartDate,EndDate - A course this is in between these dates is active, otherwise inactive.*/
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        global.db.executeProcedure(res,'get_my_all_courses',[token]);
    })
    .get('/active', function (req, res) {
        /*  Gets a list of all active courses that this user is in
        *  Returns list of:
        * {ID,Number,Name,StartDate,EndDate,UserType}
        * Number - The course number such as "CS101"
        * Name - The course name "Introduction to Computer Science"
        * UserType - the type of this user in the course: 1-student,2-TA,3-Instructor
        * StartDate,EndDate - A course this is in between these dates is active, otherwise inactive.*/
        let token =  utils.getAuthTokenFromHeader(req.headers.authorization);
        global.db.executeProcedure(res,'get_my_active_courses',[token]);
    })
    .get('/courselist', function (req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        resmodel = new responseModel();
        resmodel.ErrNo = '1';
        resmodel.Description = 'Invalid Session Key.';
        global.db.isValidToken(token).then(function (response) {
            if (response) {
                global.db.executeQuery('SELECT "ID","Name" from "Courses"',[]).then(function (resp2) {
                    if (resp2) {
                        res.send(resp2);
                    }
                })
            } else {
                res.send(resmodel);
            }
        })
    })
    .get('/all', function (req, res) {
        /*  Gets a list of all courses in the system including inactive and ones that this user is not in.
        *  Returns list of:
        * {ID,Number,Name,StartDate,EndDate,UserType}
        * Number - The course number such as "CS101"
        * Name - The course name "Introduction to Computer Science"
        * UserType - the type of this user in the course: 1-student,2-TA,3-Instructor
        * StartDate,EndDate - A course this is in between these dates is active, otherwise inactive.*/
        let token =  utils.getAuthTokenFromHeader(req.headers.authorization);
        global.db.executeProcedure(res,'get_all_courses',[token]);
    })
    .get('/allactive', function (req, res) {
        /*  Gets a list of all active courses including ones that this user is not in
        *  Returns list of:
        * {ID,Number,Name,StartDate,EndDate,UserType}
        * Number - The course number such as "CS101"
        * Name - The course name "Introduction to Computer Science"
        * UserType - the type of this user in the course: 1-student,2-TA,3-Instructor
        * StartDate,EndDate - A course this is in between these dates is active, otherwise inactive.*/
        let token =  utils.getAuthTokenFromHeader(req.headers.authorization);
        global.db.executeProcedure(res,'get_active_courses',[token]);
    })
    .get('/:id', function (req, res) {
        /*  Gets course information on a specific course
        *   Returns:
        *   {ID,Number,Name,StartDate,EndDate}
        *   Details are the same as above.*/
        let ID = req.params.id; //courseid
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        global.db.executeProcedure(res,'get_course',[token,ID]);
    })
    .get('/:id/users', function (req, res) {
        /*  Gets all users in a specific course. Currently, all logged in users can execute this function even
        * if they are not in the course.
        * Returns a list of:
        * {ID,LoginName,FirstName,LastName,UserType}
        * UserType is a string: Student,TA, or Instructor.*/
        let ID = req.params.id; //courseid
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        global.db.executeProcedure(res,'get_users_in_course',[token,ID]);
    })
    .post('/addcourse', function (req, res) {
        /* Adds a new course to the system.  Currently, administrators are the only type of user that
         * can create a new course.
         * Returns - error or success  */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let classNumber = req.body.ClassNumber; // this is not a number.  it is something like 'CS 102'
        let className = req.body.ClassName;  // this is more a description of the class.  'Educational Technology'
        let setupKey = req.body.SetupKey;  // this is used for students to auto enroll
        let startDate = req.body.StartDate;  // classes are active between the StartDate and EndDate and inactive otherwise.
        let endDate = req.body.EndDate;
        global.db.executeProcedure(res,'db_admin_create_course',[token,classNumber,className,setupKey,startDate,endDate]);
    })
    .post('/:id/updatecourse', function (req, res) {
        /* Adds a new course to the system.  Currently, administrators are the only type of user that
         * can create a new course.
         * Returns - error or success  */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let courseID = req.params.id;
        let classNumber = req.body.ClassNumber; // this is not a number.  it is something like 'CS 102'
        let className = req.body.ClassName;  // this is more a description of the class.  'Educational Technology'
        let startDate = req.body.StartDate;  // classes are active between the StartDate and EndDate and inactive otherwise.
        let endDate = req.body.EndDate;
        global.db.executeProcedure(res,'update_course_settings',[token,courseID,classNumber,className,startDate,endDate]);
    })
    .get('/enroll/:accesscode', function (req, res) {
        /* Allows a student to self enroll.
        *
        *  DB Errors: 0 - Success, 1 through 5 are DB-related errors enforced on the DB layer
        *  API Errors: 6 - Course has not started, 7 - Course has already ended, 8 - No Response (meaning something has gone wrong, we should never hit this)
        * */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        global.db.isValidToken(token).then(function(response) {
            if (response) {
                let studentEnrollKey = req.params.accesscode;
                let map = new Map();
                map.set('SetupKey',studentEnrollKey);
                global.db.queryOne('Courses', '', map).then(function (response)  {
                    if (response) {
                        if (response['ID'] && response['ID'] > 0) {
                            let currentDate = moment(utils.getCurrentDate(), 'MM/DD/YYYY');
                            let startDate = moment(response['StartDate'], 'MM/DD/YYYY');
                            let endDate = moment(response['EndDate'], 'MM/DD/YYYY');

                            if (currentDate.isBefore(startDate)) {
                                let item = {
                                    "ErrNo": "6",
                                    "Description": "Class has not started"
                                };
                                res.send(item);
                            } else if (currentDate.isAfter(endDate)) {
                                let item = {
                                    "ErrNo": "7",
                                    "Description": "Class has ended"
                                };
                                res.send(item);
                            } else {
                                 global.db.executeProcNoRet('self_enroll_student', [token, studentEnrollKey, response['ID']]).then(myresponse => {
                                     let resmodel = new responseModel();
                                     resmodel.ErrNo = '1';
                                     resmodel.Description = 'Invalid Session.';
                                     if (myresponse[0]['self_enroll_student']['ErrNo'] === '0') {
                                         if (myresponse[0]['self_enroll_student']['UserID'] > 0) {
                                             global.db.executeQuery('SELECT * from "Settings" WHERE "UserID" = $1 and "Name"=\'activeCourses\';', [myresponse[0]['self_enroll_student']['UserID']]).then(setResponse => {
                                                 if (setResponse) {
                                                     if (setResponse.length === 0) {
                                                         let newItem = "[{\"id\": " + response['ID'] + ", \"active\": true}]";
                                                         global.db.executeProcedure(res, 'set_user_default_setting', [token, 'activeCourses', newItem]);
                                                     } else {
                                                         let jsonItem = JSON.parse(setResponse[0]['Value']);
                                                         let newItem = "{\"id\": " + response['ID'] + ", \"active\": true}";
                                                         jsonItem.push(JSON.parse(newItem));
                                                         global.db.executeProcedure(res, 'set_user_default_setting', [token, 'activeCourses', JSON.stringify(jsonItem)]);
                                                     }
                                                 } else {
                                                     resmodel.Description = 'Cannot find User Settings';
                                                     res.send(resmodel);
                                                 }
                                             });
                                         } else {
                                             resmodel.Description = 'Cannot find User ID.';
                                             res.send(resmodel);
                                         }
                                     } else {
                                         resmodel.ErrNo = myresponse[0]['self_enroll_student']['ErrNo'];
                                         resmodel.Description = myresponse[0]['self_enroll_student']['Description'];
                                         res.send(resmodel);
                                     }
                                 });
                            }
                        }else {
                            item = { "ErrNo": "1", "Description": "Cannot find Course ID" };
                            res.send(item);
                        }
                    } else {
                        resmodel = new responseModel();
                        resmodel.ErrNo = '5';
                        resmodel.Description = 'Enrollment key is invalid.';
                        res.send(resmodel);
                    }
                });
            } else {
                let item = { "ErrNo": "999", "Description": "Invalid Session."};
                res.send(item);
            }
        })
    })
    .get('/:id/settings', function (req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let courseID = req.params.id;

        if (req.params.id > 0) {
            global.db.executeProcNoRet('get_course', [token, courseID]).then(data => {
                if (data) {
                    if (data[0]['get_course']['ErrNo'] == undefined || data[0]['get_course']['ErrNo'] == null || data[0]['get_course']['ErrNo'] != '1') {
                        let model = new courseModel();
                        if (data.length > 0) {
                            model.ID = data[0]['get_course'][0]['ID'];
                            model.Name = data[0]['get_course'][0]['Name'];
                            model.Number = data[0]['get_course'][0]['Number'];
                            model.StartDate = data[0]['get_course'][0]['StartDate'];
                            model.EndDate = data[0]['get_course'][0]['EndDate'];
                            model.SetupKey = data[0]['get_course'][0]['SetupKey'];

                            global.db.executeQuery('SELECT * From "Settings" WHERE "CourseID"=$1 and "UserID" is null', [model.ID]).then(response => {
                                if(response) {
                                    for (let i = 0; i < response.length; i++) {
                                        switch(response[i]['Name']) {
                                            case 'courseDescription':
                                                model.Description = response[i]['Value'];
                                                break;
                                            case 'allowStudentsToCreateGroups':
                                                model.allowStudentsToCreateGroups = (response[i]['Value'] == 'true');
                                                break;
                                            case 'allowStudentsToTagInstructors':
                                                model.allowStudentsToTagTAInstructors = (response[i]['Value'] == 'true');
                                                break;
                                            case 'allowAnonymousPosts':
                                                model.allowAnonymousPosts = (response[i]['Value'] == 'true');
                                                break;
                                            case 'allowStudentsToTagInQAPosts':
                                                model.allowStudentsToTagInQAPosts = (response[i]['Value'] == 'true');
                                                break;
                                            case 'threadsShown':
                                                model.threadsShown = response[i]['Value'];
                                                break;
                                        }
                                    }
                                }
                                return res.send(model);
                            });
                        }

                    } else {
                        return res.send(data[0]['get_course']);
                    }
                } else {
                    item = {"ErrNo": "1", "Description": "Cannot retrieve Course Information."};
                    res.send(item);
                }
            });
        } else {
            item = {"ErrNo": "1", "Description": "Missing Course ID"};
            res.send(item);
        }
    })
    .post('/:id/settings', function(req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let courseID = req.params.id;
        let item = { "ErrNo": "1", "Description": "Error - Cannot get course id" };
        if (courseID > 0) {
            let courseStart = '';
            let courseEnd = '';

            for(let index = 0; index < req.body.length; index++) {
                const setName = req.body[index]['Name'];
                const setValue = req.body[index]['Value'];

                if (setName == 'courseStart') {
                    courseStart = req.body[index]['Value'];
                } else if (setName == 'courseEnd') {
                    courseEnd = req.body[index]['Value'];
                } else {
                    item = global.db.executeProcNoRet('set_course_default_setting', [token, courseID, setName, setValue, 1,1]);
                }
            }

            if (courseStart != '' && courseEnd != '') {
                global.db.executeProcNoRet('get_course', [token, courseID]).then(response => {
                     global.db.executeProcedure(res, 'update_course_settings', [token, courseID, response[0]['get_course'][0]['Number'], response[0]['get_course'][0]['Name'], courseStart, courseEnd]);
                });
            } else {
                res.send(item);
            }
        } else {
           item = {"ErrNo": "1", "Description": "Missing Course ID"};
            res.send(item);
        }
    })
    .get('/:id/groups', function (req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let courseID = req.params.id;
        let item = { "ErrNo": "1", "Description": "Invalid Session." };

        global.db.isValidToken(token).then(function (response) {
            if (response) {
                if (courseID > 0) {
                    global.db.executeQuery('SELECT * from "UserGroups" where "CourseID" = \'' + courseID + '\' and "GroupName" Not Like\'%MessageAttachedUsergroup%\';').then(function(response) {
                        let groups = [];
                        for(let index = 0; index < response.length; index++) {
                            let group = new groupModel();
                            group.ID = response[index].ID;
                            group.CourseID = response[index].CourseID;
                            group.GroupName = response[index].GroupName;
                            group.Visibility = response[index].Visibility;
                            groups.push(group);
                        }
                        item = groups;
                        res.send(item);
                    });
                } else {
                    item.Description = 'Missing Course ID';
                    res.send(item);
                }

            } else {
                res.send(item);
            }
        })
    });



module.exports = router;