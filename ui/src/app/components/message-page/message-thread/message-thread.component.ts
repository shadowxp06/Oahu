import {Component, EventEmitter, Input, OnInit, Output} from '@angular/core';
import {Messagethreadreplyinterface} from '../../../interfaces/messagethreadreply';
import {faEdit, faLock, faStar, faThumbsUp} from '@fortawesome/free-solid-svg-icons';
import {APIService} from '../../../services/api/api.service';
import {MessageType} from '../../../enums/message-type.enum';
import {AuthSystemService} from '../../../services/auth-system/auth-system.service';
import {UserService} from '../../../services/user/user.service';
import {MessageVote} from '../../../interfaces/message-vote';
import {Router} from '@angular/router';
import {AlertService} from '../../../services/alert/alert.service';
import {Setting} from '../../../interfaces/setting';
import {Post} from '../../../interfaces/post';
import {PollItem} from '../../../interfaces/poll-item';
import {PollType} from '../../../interfaces/poll-type.enum';
import {SettingLayer} from '../../../enums/setting-layer.enum';
import {SettingVisibility} from '../../../enums/setting-visibility.enum';
import {MessageThreadEvents} from '../../../interfaces/message-thread-events';
import {PollVoteItem} from '../../../interfaces/poll-vote-item';

@Component({
  selector: 'app-message-thread',
  templateUrl: './message-thread.component.html',
  styleUrls: ['./message-thread.component.css']
})
export class MessageThreadComponent implements OnInit {
  data: Messagethreadreplyinterface = { comment: '', replyBy: '', lastUpdated: '' };
  messageData: MessageThreadEvents = { messageType: MessageType.all, settings: [], pollVotes: [], pollType: PollType.singleSum, pollItems: [], title: '' };
  msgVote: MessageVote = { isInstructorEndorsed: false, postId: 0, score: 0, userId: 0};

  @Input() parentId: number;
  @Input() expandReplies?: boolean;
  @Input() showFavorite?: boolean;
  @Input() isReply?: boolean;

  @Output() messageDataOutput = new EventEmitter();

  isAnnouncement = false;
  isQuestion = true;
  isNote = false;
  isPoll = false;
  isInstructorEndorsed = false;
  instructorEndorsedName = 'George P. Burdell';
  numberOfGoodAnswers = 0;
  mt = MessageType;
  isMessageOwner = false;
  editedDate = '01/01/2018';
  isLocked = false;
  displayName = 'George P. Burdell';
  hasVoted = false;
  hasLiked = false;
  isFavorite = false;


  permission = SettingLayer;
  visibility = SettingVisibility;

  faThumbsUp = faThumbsUp;
  faEdit = faEdit;
  faStar = faStar;
  faLock = faLock;

  title = 'Temporary';
  message = 'This is temporary';

  messageType: MessageType = MessageType.all;

  settings: Setting[] = [];
  pollItems: PollItem[] = [];
  pollVotes: PollVoteItem[] = [];
  pollType: PollType = PollType.singleSum;

  constructor(private _api: APIService,
              private _auth: AuthSystemService,
              private _user: UserService,
              private _route: Router,
              private _alert: AlertService) { }

  ngOnInit() {
    if (this.parentId && this.parentId > 0) {
      console.log(this.parentId);
      this._api.getThreadReplies(this.parentId).subscribe(((data: Post[]) => {
        if (data) {
          console.log(data);
          if (data['ErrNo'] === undefined || data['ErrNo'] === 0) {
            const item = data.filter(x => x.ID.toString() === this.parentId.toString());
            if (item) {
              this.title = item[0].Title;
              this.messageData.title = this.title;
              this.message = item[0].Message;

              switch (item[0].Type.toString()) {
                case '0':
                  this.isAnnouncement = true;
                  this.messageType = MessageType.announcement;
                  break;
                case '1':
                  this.isQuestion = true;
                  this.messageType = MessageType.question;
                  break;
                case '2':
                  this.isNote = true;
                  this.messageType = MessageType.note;
                  break;
                case '3':
                  this.isPoll = true;
                  this.messageType = MessageType.poll;
                  break;
              }

              this.messageData.messageType = this.messageType;

              if (item[0].score) {
                this.numberOfGoodAnswers = item[0].score;
              }

              this.editedDate = item[0].TimeCreated;
              this.isMessageOwner = (this._auth.userId.toString() === item[0].UserID.toString());
              this._user.currentCourseID = item[0].CourseID;
              this.displayName = item[0].FirstName + ' ' + item[0].LastName;

              const jsonSettings = JSON.parse(item[0].Setting);

              for (let n = 0; n < jsonSettings.length; n++)  {
                const setting = {Name: '', Value: '', Rank: 0, Type: 0, UserID: 0, Permission: this.permission.course, Visibility: this.visibility.course };
                switch (jsonSettings[n]['Name']) {
                  case 'revotesAllowed':
                    setting.Name = 'revotesAllowed';
                    break;
                  case 'pollAnonymity':
                    setting.Name = 'pollAnonymity';
                    break;
                  case 'showStudentResults':
                    setting.Name = 'showStudentResults';
                    break;
                  case 'correctAnswer':
                    setting.Name = 'correctAnswer';
                    break;
                }
                setting.Value = jsonSettings[n]['Value'];
                this.settings.push(setting);
              }

              this.pollVotes = item[0].PollVotes;
              this.pollItems = item[0].PollItems;
              this.pollType = item[0].PollType;

              this.messageData.settings = this.settings;
              this.messageData.pollVotes = this.pollVotes;
              this.messageData.pollItems = this.pollItems;
              this.messageData.pollType = this.pollType;

              this.emit();

              this._api.getMessageVotes(this.parentId).subscribe( ( msgData: MessageVote[]) => {
                if (msgData) {
                  for (let i = 0; i < msgData.length; i++) {
                    if (msgData[i].score > 0) {
                      this.numberOfGoodAnswers += 1;
                    }

                    if (msgData[i].userId === data[0]['UserID']) {
                      this.hasLiked = true;
                    }
                  }
                }
              });
            } else {
              this._route.navigate(['/dashboard']);
              this._alert.showErrorAlert('Invalid Message');
            }
          } else {
            console.log('Does this run? 2');
            this._route.navigate(['/dashboard']);
            this._alert.showErrorAlert('Invalid Message');
          }
        }
      }));
    }
  }

  doLike() {
    this.msgVote.isInstructorEndorsed = false;
    this.msgVote.userId = this._auth.userId;
    this.msgVote.postId = this.parentId;
    this.msgVote.score = 1;

    this._api.updateVote(this.msgVote).subscribe((data => {
      if (data) {
        if (data.body['ErrNo'] === '0') {
          this.numberOfGoodAnswers += 1;
        } else if (data.body['ErrNo'] === '999') {
          this.numberOfGoodAnswers += -1;
        } else {
          this._alert.showErrorAlert(data.body['Description']);
        }
      }
    }));
  }

  emit() {
    this.messageDataOutput.emit(this.messageData);
  }

  addFavorite() {
    const setting: Setting = { Name: '', Value: '', Rank: 0, Type: 0, Permission: SettingLayer.user, Visibility: SettingVisibility.user, UserID: this._auth.userId };
    const favorite = this.parentId;

    setting.Name = 'favorites';
    setting.Value = favorite;

    this._api.addFavorite(setting).subscribe((data => {
      if (data) {
        if (data.body['ErrNo'] === '0') {
          this._alert.showSuccessAlert('Added to Favorites');
        } else {
          this._alert.showErrorAlert(data.body['Description']);
        }
      }
    }));
  }
}
