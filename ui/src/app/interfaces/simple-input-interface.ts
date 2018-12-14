import {SimpleInputTypes} from '../enums/simple-input-types.enum';

export interface SimpleInputInterface {
  title: string;
  question: string;
  type: SimpleInputTypes;
  result: any;
  placeholder: string;
}
