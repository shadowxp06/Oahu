import {Component, Input, OnInit, ViewChild, OnDestroy} from '@angular/core';
import {MessageType} from '../../../enums/message-type.enum';
import {APIService} from '../../../services/api/api.service';
import {ActivatedRoute} from '@angular/router';
import {animate, state, style, transition, trigger} from '@angular/animations';
import {faEdit, faStickyNote, faTrashAlt, faHeart, faStar, faBullhorn, faQuestionCircle, faPoll} from '@fortawesome/free-solid-svg-icons';
import {MatPaginator, MatTableDataSource} from '@angular/material';
import {AuthSystemService} from '../../../services/auth-system/auth-system.service';
import {CourseMessageListDashboardInterface} from '../../../interfaces/course-message-list-dashboard';
import {Subscription} from 'rxjs';
import {SidebarService} from '../../../services/sidebar/sidebar.service';
import {Post} from '../../../interfaces/post';
import {MessagesService} from '../../../services/messages/messages.service';
import {Setting} from '../../../interfaces/setting';
import {SettingLayer} from '../../../enums/setting-layer.enum';
import {SettingVisibility} from '../../../enums/setting-visibility.enum';
import {AlertService} from '../../../services/alert/alert.service';
import {BreakpointObserver} from '@angular/cdk/layout';
import {MyCourseList} from '../../../interfaces/my-course-list';
import {KeyedCollection} from '../../../classes/keyed-collection';

@Component({
  selector: 'app-messages-datatable',
  templateUrl: './messages-datatable.component.html',
  styleUrls: ['./messages-datatable.component.css'],
  animations: [
    trigger('detailExpand', [
      state('collapsed', style({height: '0px', minHeight: '0', display: 'none'})),
      state('expanded', style({height: '*'})),
      transition('expanded <=> collapsed', animate('225ms cubic-bezier(0.4, 0.0, 0.2, 1)')),
    ]),
  ]
})
export class MessagesDatatableComponent implements OnInit, OnDestroy {
  @Input() messageType: MessageType;

  displayedColumns: string[] = ['type', 'title', 'quickactions'];
  courseId = 0;
  userId = 0;

  faNote = faStickyNote;
  faEdit = faEdit;
  faDelete = faTrashAlt;
  faFavorite = faStar;
  faAnnouncement = faBullhorn;
  faQuestion = faQuestionCircle;
  faPoll = faPoll;

  data: CourseMessageListDashboardInterface[] = [];

  myDataSource: MatTableDataSource<CourseMessageListDashboardInterface>;
  expandedElement: CourseMessageListDashboardInterface;

  mType = MessageType;

  _messagesSubscription: Subscription;

  @ViewChild(MatPaginator) paginator: MatPaginator;

  constructor(private _activatedRoute: ActivatedRoute,
              private _auth: AuthSystemService,
              private _sidebar: SidebarService,
              private _api: APIService,
              private _messages: MessagesService,
              private _alert: AlertService,
              private breakpointObserver: BreakpointObserver) { }

  ngOnInit() {
    this.userId = this._auth.userId;

    if (this._activatedRoute.snapshot.params['id']) {
      this.courseId = this._activatedRoute.snapshot.params['id'];
    } else {
      this.breakpointObserver.observe(['(max-width: 600px)']).subscribe(result => {
        this.displayedColumns = result.matches ?
          ['course', 'title'] :
          ['type', 'course', 'title', 'quickactions'];
      });

      this.courseId = 0;
    }

    this._api.getAllCourses().subscribe((data3: MyCourseList[]) => {
      const courses = new KeyedCollection<string>();
      for (let z = 0; z < data3.length; z++) {
        courses.Add(String(data3[z].ID), data3[z].Name);
      }

      if (this.courseId > 0) {
        this._activatedRoute.params.subscribe(data => {
          this.courseId = data['id'];
          this._messages.clearClassItems();
          this._api.getMessageForCourse(this.courseId).subscribe((data2: Post[]) => {
            this.data = [];
            for (let i = 0; i < data2.length; i++) {
              const CMItem = {
                messageId: 0,
                title: '',
                author: '',
                authorId: 0,
                lastUpdate: '',
                type: MessageType.all,
                message: '',
                selected: false,
                courseId: 0,
                courseName: '',
                isReadOnly: false
              };

              const obj = JSON.parse(data2[i].Setting);

              for (let z = 0; z < obj.length; z++) {
                if (obj[z].Name === 'makeThreadReadOnly') {
                  CMItem.isReadOnly = true;
                }
              }

              CMItem.messageId  = data2[i].ID;
              CMItem.courseId = data2[i].CourseID;
              CMItem.title = data2[i].Title;
              CMItem.message = data2[i].Message;
              CMItem.author = data2[i].FirstName + ' ' + data2[i].LastName;
              CMItem.authorId = data2[i].UserID;
              CMItem.lastUpdate = data2[i].TimeCreated;
              CMItem.type = data2[i].Type;
              CMItem.courseName = this._sidebar.getCourseName(CMItem.courseId);

              if (CMItem.type === this.mType.announcement) {
                this._messages.announcements += 1;
              }

              this._messages.all += 1;
              this._messages.updateItems();
              this.data.push(CMItem);
            }

            this.myDataSource = new MatTableDataSource<CourseMessageListDashboardInterface>(this.data);
            this.myDataSource.paginator = this.paginator;
          });
        });
      } else {
        if (!(this.messageType === this.mType.starred)) {
          this._messages.clearGlobalItems();

          this.data = [];
          this._messagesSubscription = this._api.getMessagesFromCourses(this._auth.userId).subscribe((data2: Post[]) => {
            this.data = [];
            for (let i = 0; i < data2.length; i++) {
              const CMItem = {
                messageId: 0,
                title: '',
                author: '',
                authorId: 0,
                lastUpdate: '',
                type: MessageType.all,
                message: '',
                selected: false,
                courseId: 0,
                courseName: '',
                isReadOnly: false
              };

              const obj = JSON.parse(data2[i].Setting);

              for (let z = 0; z < obj.length; z++) {
                if (obj[z].Name === 'makeThreadReadOnly') {
                  CMItem.isReadOnly = true;
                }
              }

              CMItem.messageId  = data2[i].ID;
              CMItem.courseId = data2[i].CourseID;
              CMItem.title = data2[i].Title;
              CMItem.message = data2[i].Message;
              CMItem.author = data2[i].FirstName + ' ' + data2[i].LastName;
              CMItem.authorId = data2[i].UserID;
              CMItem.lastUpdate = data2[i].TimeCreated;
              CMItem.type = data2[i].Type;
              CMItem.courseName = courses.Item(String(CMItem.courseId));

              if (Number(CMItem.type) === this.mType.announcement) {
                this._messages.globalAnnouncements += 1;
              }

              if (!data2[i].isread) {
                this._messages.unread += 1;
              }

              this._messages.globalAll += 1;
              this._messages.updateItems();

              if (this.messageType !== this.mType.announcement) {
                if (this.messageType === this.mType.unread) {
                  if (!data2[i].isread) {
                    this.data.push(CMItem);
                  }
                } else {
                  this.data.push(CMItem);
                }
              } else if (this.messageType === this.mType.announcement && Number(CMItem.type) === this.mType.announcement) {
                this.data.push(CMItem);
              }
            }

            this.myDataSource = new MatTableDataSource<CourseMessageListDashboardInterface>(this.data);
            this.myDataSource.paginator = this.paginator;
          });
        }


        this._messages.globalStarred = 0;
        this._messages.updateItems();

        this._messagesSubscription = this._api.getFavorites(this._auth.userId).subscribe((data2: Post[]) => {
          this.data = [];

          for (let i = 0; i < data2.length; i++) {
            const CMItem = {
              messageId: 0,
              title: '',
              author: '',
              authorId: 0,
              lastUpdate: '',
              type: MessageType.all,
              message: '',
              selected: false,
              courseId: 0,
              courseName: '',
              isReadOnly: false
            };

            const obj = JSON.parse(data2[i].Setting);

            for (let z = 0; z < obj.length; z++) {
              if (obj[z].Name === 'makeThreadReadOnly') {
                CMItem.isReadOnly = true;
              }
            }

            CMItem.messageId  = data2[i].ID;
            CMItem.courseId = data2[i].CourseID;
            CMItem.title = data2[i].Title;
            CMItem.message = data2[i].Message;
            CMItem.author = data2[i].FirstName + ' ' + data2[i].LastName;
            CMItem.authorId = data2[i].UserID;
            CMItem.lastUpdate = data2[i].TimeCreated;
            CMItem.type = data2[i].Type;
            CMItem.courseName = courses.Item(String(CMItem.courseId));

            this._messages.globalStarred += 1;
            this._messages.updateItems();

            if (this.messageType === this.mType.starred) {
              this.data.push(CMItem);
              this.myDataSource = new MatTableDataSource<CourseMessageListDashboardInterface>(this.data);
              this.myDataSource.paginator = this.paginator;
            }
          }
        });
      }

    });
  }

  ngOnDestroy() {
    if (this._messagesSubscription) {
      this._messagesSubscription.unsubscribe();
    }
  }

  applyFilter(filterValue: string) {
    this.myDataSource.filter = filterValue.trim().toLowerCase();

    if (this.myDataSource.paginator) {
      this.myDataSource.paginator.firstPage();
    }
  }

  addFavorite(id: number) {
    const setting: Setting = { Name: '', Value: '', Rank: 0, Type: 0, Permission: SettingLayer.user, Visibility: SettingVisibility.user, UserID: this._auth.userId };
    const favorite = id;

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
