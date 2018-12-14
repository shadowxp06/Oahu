import { UserLevels } from '../enums/user-levels.enum';
export interface ClassListInterface {
  ID: number;
  Number: string;
  Name: string;
  StartDate: string;
  EndDate: string;
  UserType: UserLevels;
}
