import {GroupMembers} from './group-members';

export interface GroupAddMemberModal {
  members: GroupMembers[];
  classId: number;
  groupId: number;
}
