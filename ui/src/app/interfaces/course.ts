import {Threadsshown} from '../enums/threadsshown.enum';

export interface Course {
  Name: string;
  Number: string;
  Description: string;
  StartDate: string;
  EndDate: string;
  ID: number;
  threadsShown: Threadsshown;
  SetupKey?: string;

  allowStudentsToCreateGroups: boolean;
  allowStudentsToTagInQAPosts: boolean;
  allowStudentsToTagTAInstructors: boolean;
  allowAnonymousPosts: boolean;
  disallowLikes: boolean;
}
