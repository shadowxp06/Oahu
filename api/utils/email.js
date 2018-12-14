let sgMail = require('@sendgrid/mail');
let utils = require('./utils.js');
let config = utils.getConfig();

module.exports = {
    sendMail: function (toEmail, subjectLine, message) {
        sgMail.setApiKey(config.app.sendgrid_api_key);
        const msg = {
            to: toEmail,
            from: 'wking6@gatech.edu',
            subject: subjectLine,
            html: message
        };
        sgMail.send(msg);
    },
    sendMailNoHTML: function (toEmail, subjectLine, message) {
        sgMail.setApiKey(config.app.sendgrid_api_key);
        const msg = {
            to: toEmail,
            from: 'wking6@gatech.edu',
            subject: subjectLine,
            text: message
        };
        sgMail.send(msg);
    }
};