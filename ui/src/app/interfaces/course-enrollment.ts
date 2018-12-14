import { UserLevels } from '../enums/user-levels.enum';

export interface CourseEnrollmentInterface {
  accessKey: string;
  isManualEnrollment: boolean;
  email: string;
  type: UserLevels;
}
