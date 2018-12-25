import {Component, Input, OnDestroy, OnInit, ViewChild} from '@angular/core';
import {FormBuilder, FormControl, FormGroup, Validators} from '@angular/forms';
import {Courseusersinterface} from '../../interfaces/courseusers';
import {Tagsinterface} from '../../interfaces/tagsinterface';
import {MessageType} from '../../enums/message-type.enum';
import {DirectionAlignment} from '../../enums/direction-alignment.enum';
import {PollMultiSelect} from '../../enums/poll-multi-select.enum';
import {PollStudentResults} from '../../enums/poll-student-results.enum';
import {YesNo} from '../../enums/yes-no.enum';
import {PollAnonymity} from '../../enums/poll-anonymity.enum';
import {ClassListInterface} from '../../interfaces/class-list';
import {APIService} from '../../services/api/api.service';
import {AlertService} from '../../services/alert/alert.service';
import {Dropdownlistiteminterface} from '../../interfaces/dropdownlistitem';
import {SidebarService} from '../../services/sidebar/sidebar.service';
import {UserLevels} from '../../enums/user-levels.enum';
import * as moment from 'moment';
import {Router} from '@angular/router';
import {AuthSystemService} from '../../services/auth-system/auth-system.service';
import {Post} from '../../interfaces/post';
import {User} from '../../interfaces/user';
import {environment} from '../../../environments/environment';
import {PollType} from '../../interfaces/poll-type.enum';
import {SettingLayer} from '../../enums/setting-layer.enum';
import {SettingVisibility} from '../../enums/setting-visibility.enum';
import {UserLookupType} from '../../enums/user-lookup-type.enum';
@Component({
  selector: 'app-post',
  templateUrl: './post.component.html',
  styleUrls: ['./post.component.css']
})
export class PostComponent implements OnInit, OnDestroy {
  @Input() courseId?: number;
  @Input() postId?: number;
  @Input() courseUsers?: Courseusersinterface[];
  @Input() tags?: Tagsinterface[];

  _users: User[] = [];
  _groups: User[] = [];
  DirAlign = DirectionAlignment;
  postTypeEnum = MessageType;

  isEdit = false;
  hideReleaseDate = true;
  hideNotifications = true;

  ckeConfig: any;

  permission = SettingLayer;
  visibility = SettingVisibility;

  /* Start of Output Variables */
  content: string;
  postType = this.postTypeEnum.note;
  postCourseId = 0;
  title: string;
  releaseDate: string;
  multiSelect: number;
  studentResults: number;
  revotes: number;
  anonymity: number;
  votes: string[] = [];
  /* end of Output Variables */

  post: Post = {CourseID: 0, Title: '', Message: '', Settings: [], GroupMembers: [], UserMembers: [], PollType: 0, PollItems: [], Type: 0, UserID: 0, ID: 0, TimeCreated: '', FirstName: '', LastName: '', Setting: '', PollVotes: [], score: 0};

  pollMultiSelectItems = [
    { name: 'One Choice', value: PollMultiSelect.OneChoice },
    { name: 'Multi-Choice', value: PollMultiSelect.MultiChoice }];

  showStudentResults = [
    { name: 'Before a Student Votes', value: PollStudentResults.BeforeAStudentVotes },
    { name: 'After a Student Votes', value: PollStudentResults.AfterAStudentVotes },
    { name: 'After poll closes', value: PollStudentResults.AfterPollCloses},
    { name: 'Never', value: PollStudentResults.Never }
  ];

  RevotesAllowed = [
    { name: 'Yes', value: YesNo.yes },
    { name: 'No', value: YesNo.no }
  ];

  PollAnonymity = [
    { name: 'Don\'t Show Names to Anyone', value: PollAnonymity.DontShowNames},
    { name: 'Show names to Instructors and Teaching Assistants', value: PollAnonymity.ShowNamesToInstructors}
  ];

  postTypeData = [
    { name: 'Question', value: MessageType.question },
    { name: 'Note', value: MessageType.note },
    { name: 'Poll', value: MessageType.poll }
  ];

  origPostTypeData = [
    { name: 'Question', value: MessageType.question },
    { name: 'Note', value: MessageType.note },
    { name: 'Poll', value: MessageType.poll }
  ];

  postForm: FormGroup;
  courses: Dropdownlistiteminterface[] = [];
  usrLookupType = UserLookupType;


  @ViewChild('myckeditor') ckeditor: any;



  constructor(private formBuilder: FormBuilder,
              private _api: APIService,
              private _alert: AlertService,
              private _sideBar: SidebarService,
              private _router: Router,
              private _authSystem: AuthSystemService) {

  }

  ngOnDestroy(): void {

  }

  ngOnInit() {
    this.isEdit = (this.postId > 0);
    this.ckeConfig = {
      allowedContent: false,
      extraPlugins: '',
      forcePasteAsPlainText: true
    };

    this.postForm = new FormGroup({
      courseSelector: new FormControl({ value: '', disabled: false }, [Validators.required]),
      postTypeSelector: new FormControl({ value: '1', disabled: false }, [Validators.required]),
      title: new FormControl('', [Validators.required]),
      editor: new FormControl('', [Validators.required]),
      pollAnswers: new FormControl(''),
      correctAnswer: new FormControl('', []),
      PollMultiSelect: new FormControl(''),
      showStudentResults: new FormControl(''),
      RevotesAllowed: new FormControl(''),
      PollAnonymity: new FormControl(''),
      releaseDate: new FormControl(''),
      userLookup: new FormControl(),
      groupLookup: new FormControl(),
      sendEmailNotificationsImmediately: new FormControl({value: false}, []),
      makeThreadReadOnly: new FormControl({value: false}, []),
      postAnonymously: new FormControl({value: false}, [])
    });

    if (this.postId > 0) {
      this._api.getThread(this.postId).subscribe( data => {
        if (data['Message']['UserID'] !== this._authSystem.userId) { /* This will need to change to permit multiple users modifying */
          this._alert.showErrorAlert('You do not have permission to edit this thread.');
          this._router.navigate(['/dashboard']);
        } else {
          this.postForm['controls']['title'].setValue(data['Message']['Title']);
          this.postForm['controls']['editor'].setValue(data['Message']['Message']);
          this.postForm['controls']['postTypeSelector'].setValue(data['Message']['Type']);
          this.postCourseId = data['Message']['CourseID'];
          this.postForm['controls']['courseSelector'].reset({value: this.postCourseId.toString(), disabled: true });
        }
      });

    } else if (this.courseId > 0) {
      this.postCourseId = this.courseId;
    }

    this._api.getUserCourses().subscribe(((data: ClassListInterface[]) => {
      if (data) {
        if (data['ErrNo'] === undefined) {
          for (let i = 0; i < data.length; i++) {
            this.courses.push({ name: data[i]['Name'], value: data[i]['ID'].toString(), selected: true });
          }
        } else {
          this._alert.showErrorAlert(data['Description']);
        }
      } else {
        this._alert.showErrorAlert('An unspecified error has occurred.  Please contact the system admins for help.');
      }
    }),
      error => {
        this._alert.showErrorAlert(error['message']);
      }
    );

    this.onChanges();
  }

  onChanges() {
    this.postForm.get('courseSelector').valueChanges.subscribe(val => {
      this.courseIdUpdate(val);
    });

    this.postForm.get('postTypeSelector').valueChanges.subscribe(val => {
      if (val === this.postTypeEnum.announcement) {
        this.postForm.get('sendEmailNotificationsImmediately').setValue(1);
      } else {
        this.postForm.get('sendEmailNotificationsImmediately').setValue(0);
      }
    });
  }

  courseIdUpdate($event) {
    if ($event > 0) {
      this.postCourseId = $event;

      if (this._sideBar.classAccessLookup($event) === UserLevels.teachingAssistant
        || this._sideBar.classAccessLookup($event) === UserLevels.instructor) {

        if (!this.postTypeData.filter(x => x.value === MessageType.announcement)[0]) {
          const announcementItem = { name: 'Announcement', value: MessageType.announcement };
          this.postTypeData.push(announcementItem);
        }

        this.hideReleaseDate = false;
        this.hideNotifications = false;

      } else {
        this.hideReleaseDate = true;
        this.hideNotifications = true;

        this.postTypeData = this.origPostTypeData;
      }
    }
  }

  postTypeUpdate($event) {
    if (!($event === null)) {
      this.postType = $event;
    }
  }

  releaseDateUpdate($event) {
    if (!($event == null)) {
      this.releaseDate = $event;
    }
  }

  titleUpdate() {
    if (!this.postForm.controls['title']) {
      this.title = this.postForm.controls['title'].value;
    }
  }

  multiSelectUpdate($event) {
    if (!($event === null)) {
      this.multiSelect = $event;
    }
  }

  studentResultsUpdate($event) {
    if (!($event === null)) {
      this.studentResults = $event;
    }
  }

  revotesUpdate($event) {
    if (!($event === null)) {
      this.revotes = $event;
    }
  }

  anonymityUpdate($event) {
    if (!($event === null)) {
      this.anonymity = $event;
    }
  }

  saveDraft() {
    this._alert.showInfoAlert('Feature not ready yet.');
  }

  getUsers($event) {
    this._users = $event;
  }

  getGroups($event) {
    this._groups = $event;
  }

  updatePollVotes($event) {
    this.votes = $event;
  }

  save() {
    this.post.CourseID = this.postCourseId;
    this.post.Message = this.postForm.get('editor').value;
    this.post.Title = this.postForm.get('title').value;
    this.post.Type = this.postForm.get('postTypeSelector').value;
    this.post.PollType = null;
    this.post.UserID = this._authSystem.userId;

    const releaseDate = { Name: 'releaseDate', Value: '', Rank: 0, Type: 1, UserID: 0, Permission: this.permission.course, Visibility: this.visibility.course };

    if (this.postForm.get('releaseDate').value === null || this.postForm.get('releaseDate').value === undefined || this.postForm.get('releaseDate').value === '') {
      releaseDate.Value = moment().format('MM/DD/YYYY');
    } else {
      releaseDate.Value = (this.postForm.get('releaseDate').value).format('MM/DD/YYYY');
    }

    if (this._users.length > 0) {
      for (let i = 0; i < this._users.length; i++) {
        const item = {UserID: 0, UserType: 0};
        item.UserID = this._users[i].ID;
        item.UserType = 3;
        this.post.GroupMembers.push(item);
      }
    }

    if (this._groups.length > 0) {
      for (let i = 0; i < this._groups.length; i++) {
        const item = {UserID: 0, UserType: 0};
        item.UserID = this._groups[i].ID;
        item.UserType = 3;
        this.post.UserMembers.push(item);
      }
    }

    this.post.SendEmailNotificationsImmediately = this.postForm.get('sendEmailNotificationsImmediately').value;
    this.post.Settings.push(releaseDate);

    const markThreadAsReadOnly = { Name: 'makeThreadReadOnly', Value: this.postForm.get('makeThreadReadOnly').value, Rank: 0, Type: 1, UserID: 0, Permission: this.permission.course, Visibility: this.visibility.course };
    this.post.Settings.push(markThreadAsReadOnly);

    const anonymousPost = { Name: 'anonymousPost', Value: this.postForm.get('isAnonymousPost').value, Rank: 0, Type: 1, UserID: 0, Permission: this.permission.course, Visibility: this.visibility.course  };
    this.post.Settings.push(anonymousPost);

    if (this.post.Type === MessageType.poll) {
      /* Poll Items */
      const revotesAllowed = { Name: 'revotesAllowed', Value: this.revotes, Rank: 0, Type: 1, UserID: 0, Permission: this.permission.course, Visibility: this.visibility.course };
      this.post.Settings.push(revotesAllowed);

      const pollAnonymity = { Name: 'pollAnonymity', Value: this.anonymity, Rank: 0, Type: 1, UserID: 0, Permission: this.permission.course, Visibility: this.visibility.course};
      this.post.Settings.push(pollAnonymity);

      const showStudentResults = { Name: 'showStudentResults', Value: this.studentResults, Rank: 0, Type: 1, UserID: 0, Permission: this.permission.course, Visibility: this.visibility.course};
      this.post.Settings.push(showStudentResults);

      const correctAnswer = { Name: 'correctAnswer', Value:  this.postForm.get('correctAnswer').value, Rank: 0, Type: 1, UserID: 0, Permission: this.permission.course, Visibility: this.visibility.course };
      this.post.Settings.push(correctAnswer);
      /* End of Poll Items */

      if (this.votes.length > 0) {
        this.post.PollItems = this.votes;

        if (this.multiSelect === 1) {
          this.post.PollType = PollType.multiSum;
        } else {
          this.post.PollType = PollType.singleSum;
        }

      } else {
        this._alert.showErrorAlert('Missing poll items');
        return;
      }
    }

    if (this.postId > 0) {
      this.post.ID = this.postId;
      this._api.updateThread(this.postId, this.post).subscribe(((data) => {
        if (data['body']['ErrNo'] === '0') {
          this._router.navigate(['/message', this.post.ID]);

        } else {
          this._alert.showErrorAlert(data['body']['Description']);
        }

      }));
    } else {
      this._api.postThread(this.postCourseId, this.post).subscribe((data => {
        if (data.body['ErrNo'] === '0') {
          this._alert.showSuccessAlert('Message has been posted.');
          if (data.body['ID'] > 0) {
            this._router.navigate(['/message', data.body['ID']]);
          }
        } else {
          if (environment.production === false) {
            if (data.body['name']) {
              this._alert.showErrorAlert(data.body['code'] + ' - ' + data.body['where']);
            } else {
              this._alert.showErrorAlert(data.body['Description']);
            }
          } else {
            if (data.body['Description'] !== null || data.body['Description'] !== undefined) {
              this._alert.showErrorAlert(data.body['Description']);
            }
          }
        }
      }));
    }
  }
}
