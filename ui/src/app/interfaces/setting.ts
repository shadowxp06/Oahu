import {SettingLayer} from '../enums/setting-layer.enum';
import {SettingVisibility} from '../enums/setting-visibility.enum';

export interface Setting {
  Name: string;
  Value: any;
  Rank: number;
  Type: number;
  UserID: number;
  Permission?: SettingLayer;
  Visibility?: SettingVisibility;
}
