import {Component, Input, OnChanges, OnInit, SimpleChanges} from '@angular/core';
import {PollVotes} from '../../../interfaces/poll-votes';
import {PollItem} from '../../../interfaces/poll-item';
import {Setting} from '../../../interfaces/setting';
import {PollType} from '../../../interfaces/poll-type.enum';
import {FormGroup} from '@angular/forms';
import {DirectionAlignment} from '../../../enums/direction-alignment.enum';
import {Dropdownlistiteminterface} from '../../../interfaces/dropdownlistitem';
import {PollShowStudentVotes} from '../../../enums/poll-show-student-votes.enum';
import * as moment from 'moment';
import {APIService} from '../../../services/api/api.service';
import {AlertService} from '../../../services/alert/alert.service';
import {AuthSystemService} from '../../../services/auth-system/auth-system.service';
import {UserService} from '../../../services/user/user.service';
import {Graph} from '../../../interfaces/graph';
import {GraphDataPie} from '../../../interfaces/graph-data-pie';
import {KeyedCollection} from '../../../classes/keyed-collection';
import {GraphLayout} from '../../../interfaces/graph-layout';
import {PollVoteItem} from '../../../interfaces/poll-vote-item';

@Component({
  selector: 'app-message-poll',
  templateUrl: './message-poll.component.html',
  styleUrls: ['./message-poll.component.css']
})
export class MessagePollComponent implements OnChanges {

  @Input() pollItems: PollItem[];
  @Input() pollVotes: PollVoteItem[];
  @Input() pollType: PollType;
  @Input() settings: Setting[];
  @Input() formGroup: FormGroup;
  @Input() hasUserVoted: boolean;
  @Input() threadTitle: string;

  DA = DirectionAlignment;
  pType = PollType;
  ssR = PollShowStudentVotes;

  _pollItems: PollItem[] = [];
  _pollVotes: PollVotes[] = [];
  _settings: Setting[] = [];
  _singleVoteValueId = 0;

  listItems: Dropdownlistiteminterface[] = [];

  pollShowStudentResponses: PollShowStudentVotes = PollShowStudentVotes.Never;
  allowRevote = false;
  pollAnonymity = false;
  correctAnswer = '';
  closeDate = '';
  totalVotes = 0;

  graphLayout: GraphLayout;

  graph: Graph = {
    data: [],
    layout: this.graphLayout
  };

  graphDataPie: GraphDataPie = { values: [], labels: [], type: 'pie' };

  data = new KeyedCollection<Number>();

  constructor(private _api: APIService,
              private _alert: AlertService,
              private _auth: AuthSystemService,
              private _user: UserService) {

  }

  ngOnChanges(changes: SimpleChanges) {
    if (changes) {
      if (changes.pollItems) {
        this._pollItems = changes.pollItems.currentValue;
      }

      if (changes.pollVotes) {
        this._pollVotes = changes.pollVotes.currentValue;
      }

      if (changes.settings) {
        this._settings = changes.settings.currentValue;
      }

      if (this._pollItems) {
        for (let i = 0; i < this._pollItems.length; i++) {
          const item = { name: '', value: '', selected: false };
          item.name = this._pollItems[i].Name;
          this.graphDataPie.labels.push(this._pollItems[i].Name);
          this.data.Add(this._pollItems[i].Name, 0);
          item.value = this._pollItems[i].ID.toString();
          item.selected = false;
          this.listItems.push(item);
        }
      }

      if (this._pollVotes) {
        for (let z = 0; z < this._pollVotes.length; z++) {
          if (this._auth.userName === this._pollVotes[z]['LoginName']) {
            this.hasUserVoted = true;
          }
          const item = this.data.Item(this._pollVotes[z]['PollItemName']);
          this.data.Remove(this._pollVotes[z]['PollItemName']);
          this.data.Add(this._pollVotes[z]['PollItemName'], Number(item) + 1);
          this.totalVotes += 1;
        }

        for (let o = 0; o < this.graphDataPie.labels.length; o++) {
          this.graphDataPie.values.push(this.data.Item(this.graphDataPie.labels[o]));
        }
        this.graph.data.push(this.graphDataPie);

        const layoutItem = { height: 400, width: 400, autosize: true, title: this.threadTitle };
        this.graph.layout = layoutItem;
      }

      if (changes.hasUserVoted) {
        this.hasUserVoted = changes.hasUserVoted.currentValue;
      }

      for (let n = 0; n < this._settings.length; n++) {
        switch (this._settings[n].Name) {
          case 'revotesAllowed':
            if (this._settings[n].Value.toString() === '1') {
              this.allowRevote = true;
            }
            break;
          case 'showStudentResults':
            this.pollShowStudentResponses = this._settings[n].Value;
            break;
          case 'correctAnswer':
            this.correctAnswer = this._settings[n].Value;
            break;
          case 'pollAnonymity':
            if (this._settings[n].Value.toString() === '1') {
              this.pollAnonymity = true;
            }
            break;
          case 'closeDate':
            this.closeDate = moment(this._settings[n].Value).format('MM/DD/YYYY');
            break;
          default:
            break;
        }
      }
    }
  }

  doVote() {
    if (this._singleVoteValueId > 0) {
      const item = { MessagePollItemID: 0, PollItemName: '', LoginName: '', Value: 0, VoteValue: 1, UserID: this._auth.userId };

      this._api.voteOnItem(this._singleVoteValueId, item).subscribe(data => {
        if (data) {
          if (data.body['ErrNo'] === '0') {
            this.hasUserVoted = true;
            this._alert.showSuccessAlert('Vote counted.');
          } else {
            this._alert.showErrorAlert(data.body['Description']);
          }
        }
      });
    }
  }

  disableVoteButton() {
    if (this.pollShowStudentResponses === this.ssR.AfterPollCloses) {
      const currentDate = moment().format('MM/DD/YYYY');
      if (currentDate > this.closeDate) {
        return true;
      }
    }

    if (this.hasUserVoted) {
      return true;
    }

    return false;
  }

  showResults() {
    if (this.pollShowStudentResponses !== this.ssR.Never) {
      if (this.pollShowStudentResponses === this.ssR.BeforeAStudentVotes) {
        return true;
      }

      if (this.hasUserVoted) {
        return true;
      }

      return false;
    } else {
      return false;
    }
  }

  getVoteValue($event) {
    if ($event > 0) {
      this._singleVoteValueId = $event;
    }
  }

}
