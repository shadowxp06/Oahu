class courseModel {
    constructor() {
        this.Name = '';
        this.Number = '';
        this.Description = '';
        this.StartDate = '';
        this.EndDate = '';
        this.ID = 0;
        this.SetupKey = '';

        /* Settings */
        this.allowStudentsToCreateGroups = false;
        this.allowStudentsToTagInQAPosts = false;
        this.allowStudentsToTagTAInstructors = false;
        this.allowAnonymousPosts = false;
        this.threadsShown = 0;
        this.disableCourseEnrollment = false;
        this.disallowLikes = false;
    }
}

module.exports = courseModel;