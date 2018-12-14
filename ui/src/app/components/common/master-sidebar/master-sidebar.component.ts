import {Component, OnInit, Input, OnDestroy} from '@angular/core';
import {
  faCheck,
  faWrench,
  faEnvelope,
  faStar,
  faExclamation,
  faHome,
  faBullhorn,
  faSearch
} from '@fortawesome/free-solid-svg-icons';
import { SidebarService } from '../../../services/sidebar/sidebar.service';
import { ClassListInterface } from '../../../interfaces/class-list';
import {ActivatedRoute, Router} from '@angular/router';
import {MatDialog, MatDrawer} from '@angular/material';
import { AuthSystemService } from '../../../services/auth-system/auth-system.service';
import { APIService } from '../../../services/api/api.service';
import {AlertService} from '../../../services/alert/alert.service';
import {UserLevels} from '../../../enums/user-levels.enum';
import {UserService} from '../../../services/user/user.service';
import {UserSettings} from '../../../interfaces/user-settings';
import {MessagesService} from '../../../services/messages/messages.service';
import {MessageCounts} from '../../../interfaces/message-counts';
import {UrlEnum} from '../../../enums/url-enum.enum';

@Component({
  selector: 'app-master-sidebar',
  templateUrl: './master-sidebar.component.html',
  styleUrls: ['./master-sidebar.component.css']
})
export class MasterSidebarComponent implements OnInit, OnDestroy {
  showSideBar = true;
  faSelectedCourse = faCheck;
  faCourseSettings = faWrench;
  faFavorite = faStar;
  faDrafts = faEnvelope;
  faImportant = faExclamation;
  faHome = faHome;
  faAnnouncement = faBullhorn;
  faSearch = faSearch;

  selectedCourseId = 0;
  userLevelsEnum = UserLevels;

  classList: ClassListInterface[] = [];
  showClassList = false;

  url = UrlEnum;


  BadgeCount: MessageCounts = {
    all: 0,
    unread: 0,
    announcements: 0,
    globalUnread: 0,
    globalAnnouncements: 0,
    globalAll: 0, globalStarred: 0,
    globalDrafts: 0
  };


  @Input() hideCreatePost?: boolean;
  @Input() isEditPost?: boolean;
  @Input() courseId?: number;

  constructor(private _sidebarService: SidebarService,
              private _router: Router,
              private _activatedRoute: ActivatedRoute,
              public dialog: MatDialog,
              private _auth: AuthSystemService,
              private _api: APIService,
              private _alert: AlertService,
              private _user: UserService,
              private _messages: MessagesService) {


    this.showSideBar = _sidebarService.isSidebarVisible;


    if (!this.isEditPost) {
      this._activatedRoute.params.subscribe((params) => {
        if (params) {
          this.selectedCourseId = params['id'];
        } else {
          this.selectedCourseId = 0;
        }
      });
    }
  }

  ngOnInit() {
    if (this.isEditPost) {
      this.selectedCourseId = this.courseId;
    }

    this._api.getUserCourses().subscribe(((data: ClassListInterface[]) => {
      if (data) {
        if (data['ErrNo'] === undefined) {
          this.classList = [];
          this._user.refreshUserSettings();

          this._user.settings.subscribe( (usrSettings: UserSettings) => {
            if (usrSettings.activeCourses.length > 0) {
              this._sidebarService.clearItems();
              for (let i = 0; i < data.length; i++) {
                const item = usrSettings.activeCourses.filter(course => course.id === data[i].ID);
                if (item && item.length > 0) {
                  if (item[0].active) {
                    this._sidebarService.addItem(data[i]);
                    this.showClassList = true;
                  }
                }
              }

              this._sidebarService.sideBarItemsBS.asObservable().subscribe((CLdata: ClassListInterface[]) => {
                this.classList = CLdata;
              });
            }
          });

          this.BadgeCount = this._messages.countsBS.value;
        } else {
          if (data['ErrNo'] === '1' && data['Description'] === this._auth.invalidSessionMessage) {
            this._auth.logout(); /* Force a logout to make sure Auth Guard doesn't keep them on the same page */
            this._alert.showErrorAlert(data['Description']);
            this._router.navigate(['/login']);
          } else {
            this._alert.showErrorAlert(data['Description']);
          }
        }
      }
    }));

  }

  ngOnDestroy(): void {

  }

  goToClass(id: number) {
    if (id > 0) {
      this._sidebarService.setSidebarVisibility(false);
      this._router.navigate(['/dashboard', id]);
    }
  }

  goToCreatePost() {
    this._sidebarService.setSidebarVisibility(false);
    if (this.selectedCourseId) {
      if (this.selectedCourseId > 0) {
        this._router.navigate(['/createpost', this.selectedCourseId]);
      }
    }

    this._router.navigate(['/createpost']);
  }

  goToUrl(myUrl: UrlEnum, id?: number) {
    this._sidebarService.toggleSidebarVisibility();
    switch (myUrl) {
      case UrlEnum.dashboard:
        this._router.navigate(['/dashboard']);
        break;
      case UrlEnum.starred:
        this._router.navigate(['/favorites']);
        break;
      case UrlEnum.announcements:
        this._router.navigate(['/announcements']);
        break;
      case UrlEnum.unread:
        this._router.navigate(['/unread']);
        break;
      case UrlEnum.search:
        this._router.navigate(['/search']);
        break;
      case UrlEnum.settings:
        this._router.navigate(['/settings']);
        break;
      case UrlEnum.newpost:
        this._router.navigate(['/createpost']);
        break;
      case UrlEnum.coursesettings:
        this._router.navigate(['/coursesettings', id]);
        break;
    }
  }
}
