export interface SearchInterface {
  CourseID: number;
  UserGroupID: number;
  MessageGroupID: number;
  IsThread: boolean;
  CreationTimeLTE: string; /* Creation Time is less than or equal to this value */
  CreationTimeGTE: string; /* Creation Time is greater than or equal to this value */
  ChildCountGTE: number; /* Number of replies greater than or equal to */
  ChildCountLTE: number; /* Number of replies less than or equal to */
  ScoreGTE: number; /* Based on user votes */
  ScoreLTE: number; /* Based on user votes */
  name?: string;
}
