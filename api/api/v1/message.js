let express = require('express');
let router = express.Router();
let utils = require('../../utils/utils.js');
let messageTypeEnum = require('../../enums/message-enums.js');
let responseModel = require('../../models/v1/response');
let enums = require('../../enums/base-enums');
let fs = require('fs');

/* Helper Functions */
function getMessageThreads(token, id) {
    return global.db.executeProcNoRet('get_message_threads', [token, id]);
}

function add_messsage_to_usergroup(token, msgId, userGroup) {
    return global.db.executeProcNoRet('add_message_to_usergroup', [token, msgId, userGroup]);
}
/* End */

router.get('/:courseId', function (req, res) {
    /*  Get Thread Posts - This gets a list the Original Posts of all message threads in a course.
        Returns: error or a list of:
        [{"ID","Type","TimeCreated","Title","Message","hasAttachment"}]*/
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let courseID = req.params.courseId;
        global.db.executeProcedure(res,'get_message_threads',[token,courseID]);
    })
    .get('/all/:userid', function (req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        global.db.isValidToken(token).then(function (response) {
            resModel = new responseModel();
            resModel.ErrNo = '1';
            resModel.Description = 'Invalid Session.';

            if (response) {
                let id = req.params.userid;
                if (id > 0) {
                    global.db.executeQuery('SELECT "Value" from "Settings" WHERE "UserID" = $1 and "Name" = \'activeCourses\';', [id]).then(myData => {
                        if (myData && myData.length > 0) {
                            let item = JSON.parse(myData[0]['Value']);

                            if (item.length > 0) {
                                let promises = [];
                                for (let i = 0; i < item.length; i++) {
                                    promises.push(getMessageThreads(token, item[i]['id']));
                                }

                                Promise.all(promises).then((response) => {
                                    if (response) {
                                        let msgs = [];
                                        for(let n = 0; n < response.length; n++) { /* N^2 runtime -- this potentially is a problem; I will go back and fix this before we go live */
                                            for (let z = 0; z < response[n][0]['get_message_threads'].length; z++) {
                                                msgs.push(response[n][0]['get_message_threads'][z]);
                                            }
                                        }
                                        res.send(msgs);
                                    } else {
                                        res.send(resModel);
                                    }
                                });
                            } else {
                                resModel.ErrNo = '0';
                                resModel.Description = 'Success';
                                res.send(resModel);
                            }
                        } else {
                            resModel.ErrNo = '0';
                            resModel.Description = 'Success';
                            res.send(resModel);
                        }
                    })
                } else {
                    res.send(resModel);
                }
            } else {
                res.send(resModel);
            }
        });
    })
    .get('/', function (req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        global.db.isValidToken(token).then(function (response) {
            if (response) {

            } else {
                let item = { "ErrNo": "999", "Description": "Invalid Session."};
                res.send(item);
            }
        })
    })
    .get('/posts/:postid', function (req, res) {
        let postID = req.params.postid;
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);

        resModel = new responseModel();
        resModel.ErrNo = '1';
        resModel.Description = 'Invalid Session.';

        global.db.executeProcNoRet('get_thread_messages', [token, postID]).then(data => {
            if (data) {
                if (data[0]['get_thread_messages']['ErrNo']) {
                    resModel.Description = data[0]['get_thread_messages']['Description'];
                    res.send(resModel);
                } else {
                    data[0]['get_thread_messages'][0]['isread'] = true;
                    global.db.executeProcNoRet('mark_message_as_read', [token, data[0]['get_thread_messages'][0]['ID']]).then(data2 => {
                        if (data2[0]['mark_message_as_read']['ErrNo'] != '0') {
                            console.log(data2[0]['mark_message_as_read']['Description']);
                        }
                        res.send(data[0]['get_thread_messages']);
                    });
                }
            } else {
                res.send(resModel);
            }
        })
    })
    .get('/post/:postid', function (req, res) {
        /* Get Post - gets a specific post.
         *  Returns - error or one item of:
         *  [{ "ID","ParentID","CourseID","UserID","Type","TimeCreated","Title","Message","hasAttachment" }] */
        let postID = req.params.postid;
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);

        resModel = new responseModel();
        resModel.ErrNo = '1';
        resModel.Description = 'Invalid Session.';

        global.db.executeProcNoRet('get_message', [token, postID]).then(data => {
            if (data)
            {
                if (data[0]['get_message']['ErrNo']) {
                    resModel.Description = data[0]['get_thread_messages']['Description'];
                    res.send(resModel);
                } else {
                    data[0]['get_message']['Message']['isread'] = true;
                    global.db.executeProcNoRet('mark_message_as_read', [token, data[0]['get_message']['Message']['ID']]).then(data2 => {
                        res.send(data[0]['get_message']['Message']);
                    });
                }
            }
        })
    })
    .post('/post/:messageid', function (req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let postID = req.params.messageid;
        let title = req.body.Title;
        let message = req.body.Message;
        let settings = req.body.Setting;
        let type = req.body.Type;
        let pollType = req.body.PollType;

        resModel = new responseModel();
        resModel.ErrNo = '1';
        resModel.Description = 'Invalid Session.';
        global.db.executeProcNoRet('edit_message', [token,postID,title,message, JSON.stringify(settings), type]).then(data => {
            if (data[0]['edit_message']['ErrNo'] == '0') {
                if (type == messageTypeEnum.messageType.poll) {
                     res.send(resModel);
                } else {
                    res.send(data[0]['edit_message']);
                }
            }
        });
    })
    .post('/:courseid/createthread', function (req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);

        if (req.body['GroupMembers']) {
            if (req.body['GroupMembers'].length === 0) {
                delete req.body['GroupMembers'];
            }
        }

        if (req.body['PollType'] === null) {
            delete req.body['PollType'];
            delete req.body['PollItems'];
        }

        let model = new responseModel();
        model.ErrNo = '1';
        model.Description = 'Unsuccessful';

        global.db.executeProcNoRet('create_message', [token, req.body]).then(data => {
                if (data[0]['create_message']['ErrNo'] == '0') {
                    if (req.body['SendEmailNotificationsImmediately'] && !utils.isDev()) {
                        let query = 'SELECT "EmailAddr" from "Users" ';
                        query += ' INNER JOIN "CourseMembers" on "CourseMembers"."UserID" = "Users"."ID"';
                        query += ' WHERE "CourseMembers"."CourseID" = $1';

                        let email = '';
                        fs.readFile("templates/v1/post-notification.html", "utf8", function (err, data) {
                           if (err) {
                               global.errLogging.writeToFile(enums.LogLevel.Error, err, 'Create Thread - Email');
                           } else {
                               email = data;
                           }
                        });

                        global.db.executeQuery(query, [req.params.courseid]).then(function (response) {
                            if (response) {
                                for (let n = 0; n < response.length; n++) {
                                    global.email.sendMail(response[n]['EmailAddr'], 'New Post Added by Instructor', email);
                                }
                            }
                        });
                    }

                    global.db.executeQuery('SELECT * from "Messages" WHERE "UserID" = $1 ORDER BY "ID" DESC LIMIT 1', [req.body['UserID']]).then(msgData => {
                        if (msgData[0]['ID'] > 0) {
                            model.ErrNo = '0';
                            model.Description = 'Successful';
                            model.ID = msgData[0]['ID'];

                            let promises = [];

                            for (let i = 0; i < req.body['UserMembers'].length; i++) {
                                promises.push(add_messsage_to_usergroup(token, msgData[0]['ID'], req.body['UserMembers'][i]['UserID']));
                            }

                            Promise.all(promises).then((promiseResponse) => {
                                if (promiseResponse) {
                                    res.send(model);
                                }
                            });
                        } else {
                            model.ErrNo = '7';
                            model.Description = 'Unable to get Message ID';
                            res.send(model);
                        }
                    });
                } else {
                    res.send(data[0]['create_message']);
                }
        })
    })

    .post('/createreply', function (req, res) {
        /* Create Reply Post - this creates a new post that must have a parent, meaning that the post
         * is a reply to another thread.  The reply can be any post and not just original or thread posts.
         * Returns - error or success  */
        let courseID = req.body.courseid;
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let title = req.body.title;
        let message = req.body.message;
        let parentID = req.body.parentid;
        global.db.executeProcedure(res,'create_message_reply',[token,parentID, courseID,title,message]);
    })
    .post('/pollitem/:postid', function (req, res) {
        /* Poll messages have a list of items that are being voted on.  This attaches one of those
         * items to a poll message
         * Returns - error or success */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let postID = req.params.postid;
        let pollItemName = req.body.PollItemName;
        global.db.executeProcedure(res,'add_message_poll_item',[token,postID,pollItemName]);
    })
    .post('/pollvote/:pollid', function (req, res) {
        /* In a poll message, users can vote on items.  This adds a vote to a specific poll item.  Votes
        * are only restricted in the sense that a user can not vote twice on the same item.  Otherwise,
        * votes for multiple items are allowed.  You are responsible for ensuring that only one item is
        * voted for if that is what you want.  Any integer voteValue is allowed.
        * Returns - error or success */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let pollItemID = req.params.pollid; // A specific pole item.
        let voteValue = req.body.VoteValue; //must be an integer, but can be negative or 0.
        global.db.executeProcedure(res,'add_message_poll_vote',[token,pollItemID,voteValue]);
    })
    .get('/pollvotes/:pollid', function (req, res) {
        /*  This returns a list of all of the votes on a particular poll post including all items.
         * Returns error or a list of
         * [{ MessagePollItemID, PollItemName, LoginName, Value  }]
         * LoginName is the users login name who cast the vote.  */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let pollPostID = req.params.pollid;  // this is the original post id
        global.db.executeProcedure(res,'get_message_poll_votes',[token,pollPostID]);
    })
    .post('/vote', function (req, res) {
        /* Messages themselves can be ranked. If students or instructors like a particular message, they
           can vote it up.  This function allows a message vote to be registered with the system.
           Returns - error or success
         */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let postID = req.body.postId;
        let userId = req.body.userId;
        let score = req.body.score;


        global.db.executeProcedure(res,'add_message_vote',[token,Number.parseInt(postID),score]);
    })
    .post('/vote/instructorendorsed', function (req, res) {
        /* Will be added shortly - 11-15-2018 */
    })
    .get('/votes/:postid', function (req, res) {
        /* Gets a list of all votes that have been registered for this post.
         * Returns - error or list of:
          * [{UserID,Score }] */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let postID = req.params.postid;
        global.db.executeProcedure(res,'get_message_votes',[token,postID]);
    })
    .post('/group', function (req, res) {
        /*  This adds a new custom message group. Think: favorites, announcements, or instructor approved.
        * We may eventually want to hard code a few of these.  The marker for if a message has been read
        * or not is already a hard coded message group.
        * Returns - error or success  */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let courseID = req.body.CourseID;
        let newGroupName = req.body.NewGroupName;
        global.db.executeProcedure(res,'create_message_group',[token,courseID,newGroupName]);
    })
    .post('/groupmember', function (req, res) {
        /* Adds a new post to a messagegroup.
        * Returns - error or success*/
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let groupID = req.body.GroupID;
        let postID = req.body.PostID;
        global.db.executeProcedure(res,'add_message_group_members',[token,groupID,postID]);
    })
    .get('/group/:groupid', function (req, res) {
        /*  gets a list of all of the posts that are in the selected message group.
         * Returns - error or a list of:
         * [{MessageID, Title, Message}] */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let groupID = req.params.groupid;
        global.db.executeProcedure(res,'get_message_group_members',[token,groupID]);
    });


module.exports = router;