import { MessageType } from '../enums/message-type.enum';

export interface CourseMessageListDashboardInterface {
  messageId: number;
  title: string;
  author: string;
  authorId: number;
  lastUpdate: string;
  icon?: string;
  type: MessageType;
  message: string;
  selected: boolean;
  courseId?: number;
  courseName?: string;
}

