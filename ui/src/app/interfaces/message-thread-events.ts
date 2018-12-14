import {MessageType} from '../enums/message-type.enum';
import {PollType} from './poll-type.enum';
import {PollItem} from './poll-item';
import {Setting} from './setting';
import {PollVoteItem} from './poll-vote-item';

export interface MessageThreadEvents {
  messageType: MessageType;
  settings: Setting[];
  pollVotes: PollVoteItem[];
  pollType: PollType;
  pollItems: PollItem[];
  title: string;
}
