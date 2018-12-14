let express = require('express');
let router = express.Router();
let utils = require('../../utils/utils.js');

router.get('/', function (res, req) {
    res.json({message: 'Return List of Users Attachments'});
}).get('/:courseid', function (res, req) {
    res.json({message: 'Return list of Users Attachments in Course'})
}).delete('/:courseid/:fileid', function (res, req) {
    res.json({message: 'Delete Attachment'})
});

module.exports = router;