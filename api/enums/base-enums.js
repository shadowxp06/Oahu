
let AccessEnums = {
    NoAccess:0,
    Student:1,
    TeachingAssistant:2,
    Instructor:3,
    Admin:999
};

let LogLevel = {
    Error: 0,
    Warn: 1,
    Info: 2,
    Verbose:3,
    Debug:4,
    Silly:5
};

module.exports = {
    AccessEnums,
    LogLevel
};
