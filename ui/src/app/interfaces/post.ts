import {Setting} from './setting';
import {GroupMember} from './group-member';

export interface Post {
  CourseID: number;
  Title: string;
  Message: string;
  Settings: Setting[];
  GroupMembers: GroupMember[];
  UserMembers?: GroupMember[];
  PollType: number;
  PollItems: any[];
  Type: number;
  UserID: number;
  ID: number;
  TimeCreated: string;
  FirstName: string;
  LastName: string;
  Setting: string;
  PollVotes: any[];
  score: number;
  SendEmailNotificationsImmediately?: boolean;
  isread?: boolean;
}
