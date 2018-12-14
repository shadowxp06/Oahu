import { GroupMembers } from './group-members';

export interface Groups {
  ID: number;
  CourseID: number;
  GroupName: string;
  Visibility: number;
  members: GroupMembers[];
}

