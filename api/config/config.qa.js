var config = {
    app: {
        port: 8085,
        version: "1.0.0",
        attachmentsdir: './attachments/',
        logdir: './logs/',
        allow_origin: '*',
        sendgrid_api_key: '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',
        access_key_random: '43278417844231',
        dev_mode_bypass_security: true,
        use_inbuilt_cors: true
    },
    db: {
        host: '127.0.0.1',
        port: 5432,
        database: 'omsdiscussions',
        user: 'oahu_user',
        password: 'password123'
    }
};

module.exports = config;

