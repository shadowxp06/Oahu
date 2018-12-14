import {PollItem} from './poll-item';
import {PollVoteItem} from './poll-vote-item';

export interface PollVotes {
  PollItems: PollItem[];
  PollVotes: PollVoteItem[];
}
