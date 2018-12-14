import {Dialogtype} from '../enums/dialogtype.enum';

export interface Dialogdata {
  title: string;
  type: Dialogtype;
  okText?: string;
  dialogText: string;
}
