let express = require('express');
let router = express.Router();

router.post('/add', function (req, res) {
        /* adds a new system administrator.  Administrators currently use a completely separate login.
        * Returns - error or success  */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let newUserName = req.body.NewUserName;  //new users username
        global.db.executeProcedure(res,'db_admin_add_admin',[token,newUserName]);
    })
    .post('/delete', function (req, res) {
        /* deletes an administrator
        * Returns - error or success  */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let deleteUserName = req.body.DeleteUserName;  //admin password
        global.db.executeProcedure(res,'db_admin_delete_admin',[token,deleteUserName]);
    })

    .post('/adduser', function (req, res) {
        /* adds a new user to the system.  Probably unnecessary since it happens automatically when they are added
           to a class.
           Returns - error or success  */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let newUser = req.body.NewUser;  //the username being added to the system
        global.db.executeProcedure(res,'db_admin_add_user',[token,newUser]);
    })
    .post('/deactivateuser', function (req, res) {
        /* A deativated user can no longer login */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let user = req.body.User;  //the username of the user being deactivated
        global.db.executeProcedure(res,'db_admin_deactivate_user',[token,user]);
    })
    .post('/activateuser', function (req, res) {
        /* A user must be activated to login.  Users are activated by default on creation.
        * Returns - error or success */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let user = req.body.User;  //the username of the user being activated.
        global.db.executeProcedure(res,'db_admin_activate_user',[token,user]);
    })
    .post('/addsetting', function (req, res) {
        /* This adds a global setting that applies to all users and all courses unless overridden by another
           more specific user or course setting.
           Returns - error or success */
        let token = utils.getAuthTokenFromHeader(req.headers.authorization);
        let settingName = req.body.SettingName;
        let settingValue = req.body.SettingValue;
        let permission = req.body.Permission;
        let visibility = req.body.Visibility;
        global.db.executeProcedure(res,'db_admin_set_system_default_setting',[token,settingName,settingValue,permission,visibility]);
    });



module.exports = router;