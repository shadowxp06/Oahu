let express = require('express');
let router = express.Router();
let utils = require('../../utils/utils.js');
let groupModel = require('../../models/v1/groups');
let groupMemberModel = require('../../models/v1/groupMember');

router.get('/', function (req, res) {
    const item = { test: 'test'};
    res.send(item);
})
    .get('/:groupid/members', function (req, res) { /* Temporary until we can fix the Stored procedure to get the Users */
    let token = utils.getAuthTokenFromHeader(req.headers.authorization);
    let groupID = req.params.groupid;
    let item = { "ErrNo": "1", "Description": "Invalid Session." };

    global.db.isValidToken(token).then(function (response) {
        if (response) {
            if (groupID > 0) {
                global.db.executeQuery('select "GroupID", "UserID", "FirstName", "LastName" from "UserGroupMembers" JOIN "Users" on "Users"."ID" = "UserGroupMembers"."UserID" where "GroupID" = \'' + groupID + '\';').then(function (response) {
                    let groupMembers = [];
                    for(let index = 0; index < response.length; index++) {
                        let groupMember = new groupMemberModel();
                        groupMember.id = response[index].GroupID;
                        groupMember.userId = response[index].UserID;
                        groupMember.name = response[index].FirstName + ' ' + response[index].LastName;
                        groupMembers.push(groupMember);
                    }
                    item = groupMembers;
                    res.send(item);
                });
            } else {
                item.Description = 'Invalid Group ID';
                res.send(item);
            }
        } else {
            res.send(item);
        }
    });
})
    .post('/:classid', function (req, res) {
        /* Creates a new user group.  Think splitting the class into smaller project groups.  */
        let token =  utils.getAuthTokenFromHeader(req.headers.authorization);
        let classID = req.params.classid;
        let newGroupName = req.body.NewGroupName;
        let newGroupVisibility = req.body.NewGroupVisibility;
        global.db.executeProcedure(res,'create_user_group',[token,classID,newGroupName,newGroupVisibility]);
    })
    .post('/:groupid/members/add', function (req, res) {
        /* Adds a user to a group  */
        let token =  utils.getAuthTokenFromHeader(req.headers.authorization);
        let groupID = req.params.groupid;
        let newMemberUsername = req.body.NewMemberUsername;
        let newUserType = req.body.NewUserType;
        global.db.executeProcedure(res,'add_user_to_group',[token,groupID,newMemberUsername,newUserType]);
    })
    .delete('/:groupid', function (req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let groupid = req.params.groupid;
    })
    .delete('/:groupid/:userid', function (req, res) {
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let groupid = req.params.groupid;
        let userid = req.params.userid;
        global.db.executeProcedure(res, 'delete_user_from_group', [token,groupid,userid]);
    });

module.exports = router;