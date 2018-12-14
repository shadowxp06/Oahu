import {ActiveUserCourses} from './active-user-courses';
import {SearchInterface} from './search-interface';

export interface UserSettings {
  displayName: string;
  email: string;
  timezone: string;
  threadsShown: number;
  email_NewQuestionsNotesAnnouncements: boolean;
  email_FollowedQuestionsNotesAnnouncements: boolean;
  email_NewReplyOnFavorite: boolean;
  email_NewReplyOnCreatedThread: boolean;
  email_groupIsTagged: boolean;
  display_NewQuestionsNotesAnnouncements: number;
  display_FollowedQuestionsNotesAnnouncements: number;
  activeCourses: ActiveUserCourses[];
  activeCoursesJSON: string;
  savedSearches?: SearchInterface[];
}
