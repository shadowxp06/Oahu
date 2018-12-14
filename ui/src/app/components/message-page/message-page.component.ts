import {ChangeDetectorRef, Component, OnDestroy, OnInit, ViewChild} from '@angular/core';
import {BreakpointObserver, MediaMatcher} from '@angular/cdk/layout';
import {SidebarService} from '../../services/sidebar/sidebar.service';
import {APIService} from '../../services/api/api.service';
import {ActivatedRoute, Router} from '@angular/router';
import {FormControl, FormGroup, Validators} from '@angular/forms';
import {AlertService} from '../../services/alert/alert.service';
import {UserService} from '../../services/user/user.service';
import {MessageType} from '../../enums/message-type.enum';
import {Setting} from '../../interfaces/setting';
import {PollItem} from '../../interfaces/poll-item';
import {PollType} from '../../interfaces/poll-type.enum';
import {MessageThreadEvents} from '../../interfaces/message-thread-events';
import {AuthSystemService} from '../../services/auth-system/auth-system.service';
import {PollVoteItem} from '../../interfaces/poll-vote-item';

@Component({
  selector: 'app-message-page',
  templateUrl: './message-page.component.html',
  styleUrls: ['./message-page.component.css']
})
export class MessagePageComponent implements OnInit, OnDestroy {
  showSideBar = true;
  title = 'This is a test';
  messageId = 0;
  retMessageId = 0;
  showReply = false;
  ckeConfig: any;
  messageForm: FormGroup;
  messageType: MessageType = MessageType.all;
  hasVoted = false;

  settings: Setting[] = [];
  pollItems: PollItem[] = [];
  pollVotes: PollVoteItem[] = [];
  pollType: PollType = PollType.singleSum;

  messageData: MessageThreadEvents;

  mt = MessageType;

  @ViewChild('myckeditor') ckeditor: any;


  constructor(private _breakpointObserver: BreakpointObserver,
              private _sidebarService: SidebarService,
              private _api: APIService,
              private _aroute: ActivatedRoute,
              private _router: Router,
              private _alert: AlertService,
              private _user: UserService,
              private _auth: AuthSystemService) {


  }

  ngOnInit() {

    if (this._aroute.snapshot.queryParams['retMessageId']) {
      this.retMessageId = this._aroute.snapshot.queryParams['retMessageId'];
    }

    if (this._aroute.snapshot.params['id'] > 0) {
      this.messageId = this._aroute.snapshot.params['id'];
    } else {
      this._router.navigate(['/dashboard']);
    }

    if (this._aroute.snapshot.queryParams['reply']) {
      this.showReply = true;
    }

    this.ckeConfig = {
      allowedContent: false,
      extraPlugins: '',
      forcePasteAsPlainText: true
    };

    this.messageForm = new FormGroup({
      editor: new FormControl('', [Validators.required]),
      PollAnswers: new FormControl('', [])
    });

  }

  save() {
    const myMessage = { title: '', message: '', parentid: 0, courseid: 0};
    myMessage.title = this.title;
    myMessage.message = this.messageForm.get('editor').value;
    myMessage.parentid = this.messageId;
    myMessage.courseid = this._user.currentCourseID;

    if (myMessage.courseid > 0) {
      this._api.postReply(myMessage).subscribe( data => {
        if (data) {
          if (data['body']['ErrNo'] === '0') {
            if (this.retMessageId > 0) {
              this._router.navigate(['/message', this.retMessageId]);
            } else {
              this._router.navigate(['/message', myMessage.courseid]);
            }
            this._alert.showSuccessAlert('Reply posted');
          } else {
            this._alert.showErrorAlert(data['body']['Description']);
          }
        }
      });
    }
  }

  saveDraft() {

  }

  messageDataOutput($event) {
    this.messageData = $event;
    // this.title = this.messageData.title;
    this.messageType = this.messageData.messageType;
    this.settings = this.messageData.settings;
    this.pollItems = this.messageData.pollItems;
    this.pollVotes = this.messageData.pollVotes;
    this.pollType = this.messageData.pollType;

    if (this.pollVotes) {
      for (let i = 0; i < this.pollVotes.length; i++) {
        if (this.pollVotes[i].UserID === this._auth.userId) {
          this.hasVoted = true;
        }
      }
    }
  }

  ngOnDestroy(): void {

  }

}
