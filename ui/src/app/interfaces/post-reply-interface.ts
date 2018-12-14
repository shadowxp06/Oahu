import {Setting} from './setting';

export interface PostReplyInterface {
  TimeCreated: string;
  FirstName: string;
  Title: string;
  CourseID: number;
  LastName: string;
  hasAttachment: boolean;
  UserID: number;
  PollType: null;
  LastEditedBy: null;
  isread: boolean;
  Setting: Setting[];
  UserGroupID: number;
  Message: string;
  Type: number;
  ID: number;
  ChildCount: number;
  ChildThreads: PostReplyInterface[];
}
