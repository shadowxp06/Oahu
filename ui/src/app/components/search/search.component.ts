import {ChangeDetectorRef, Component, OnDestroy, OnInit} from '@angular/core';
import {SidebarService} from '../../services/sidebar/sidebar.service';
import {FormBuilder, FormControl, FormGroup} from '@angular/forms';
import {ClassListInterface} from '../../interfaces/class-list';
import {APIService} from '../../services/api/api.service';
import {Dropdownlistiteminterface} from '../../interfaces/dropdownlistitem';
import {AlertService} from '../../services/alert/alert.service';
import {SearchInterface} from '../../interfaces/search-interface';
import {faSearch, faSearchPlus} from '@fortawesome/free-solid-svg-icons';
import {SearchType} from '../../enums/search-type.enum';
import {DirectionAlignment} from '../../enums/direction-alignment.enum';
import {SearchService} from '../../services/search/search.service';
import {Subscription} from 'rxjs';
import {CourseMessageListDashboardInterface} from '../../interfaces/course-message-list-dashboard';
import {Post} from '../../interfaces/post';
import {MessageType} from '../../enums/message-type.enum';
import {AuthSystemService} from '../../services/auth-system/auth-system.service';
import {MatDialog} from '@angular/material';
import {SimpleInputInterface} from '../../interfaces/simple-input-interface';
import {SimpleInputTypes} from '../../enums/simple-input-types.enum';
import {OmsSimpleInputComponent} from '../common/oms-simple-input/oms-simple-input.component';
import {UserService} from '../../services/user/user.service';
import {UserSettings} from '../../interfaces/user-settings';
import {UserLookupType} from '../../enums/user-lookup-type.enum';
import {MediaMatcher} from '@angular/cdk/layout';

@Component({
  selector: 'app-search',
  templateUrl: './search.component.html',
  styleUrls: ['./search.component.css']
})
export class SearchComponent implements OnInit, OnDestroy {
  showSideBar = false;

  results: Post[] = [];
  resultsInterface: CourseMessageListDashboardInterface[] = [];
  recent: SearchInterface[] = [];
  saved: SearchInterface[] = [];
  courses: Dropdownlistiteminterface[] = [];

  searchForm: FormGroup;

  inputItem: SimpleInputInterface = {
    title: 'Search Name',
    question: 'Enter a name to save the search under',
    type: SimpleInputTypes.Text,
    result: '',
    placeholder: 'Search Name'
  };

  search = faSearch;
  savedSearches = faSearchPlus;

  sType = SearchType;
  align = DirectionAlignment;

  _searchSubscription: Subscription;
  _settingsSubscription: Subscription;

  selectedTab = 0;
  courseId = 0;
  userId = 0;

  usrLookupType = UserLookupType;


  constructor(private _sidebar: SidebarService,
              private _formBuilder: FormBuilder,
              private _api: APIService,
              private _alert: AlertService,
              private _search: SearchService,
              private _auth: AuthSystemService,
              public dialog: MatDialog,
              private _user: UserService) {

    this.showSideBar = this._sidebar.isSidebarVisible;
  }

  ngOnInit() {
    this.userId = this._auth.userId;


    this.searchForm = this._formBuilder.group( {
      courseSelector: new FormControl({ value: '', disabled: false}),
      CreationTimeLTE: new FormControl({ value: '', disabled: false}),
      userLookup: new FormControl({ value: '', disabled: false}),
      groupLookup: new FormControl({ value: '', disabled: false }),
      CreationTimeGTE: new FormControl({ value: '', disabled: false}),
      ScoreGTE: new FormControl({ value: '', disabled: false}),
      ScoreLTE: new FormControl({ value: '', disabled: false})
    });


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
    }), error => {
      this._alert.showErrorAlert(error['message']);
    });

    this._user.refreshUserSettings();
    this._settingsSubscription = this._user.settings.subscribe((settings: UserSettings) => {
      if (settings.savedSearches.length > 0) {
        for (let i = 0; i < settings.savedSearches.length; i++) {
          this.saved.push(settings.savedSearches[i]);
        }
      }
    });
  }

  ngOnDestroy() {
    if (this._searchSubscription) {
      this._searchSubscription.unsubscribe();
    }

    if (this._settingsSubscription) {
      this._settingsSubscription.unsubscribe();
    }
  }

  submit() {
    const item = this.getSearchObj();

    this._search.addToSessionSearches(item);
    this._search.CurrentSearchObj = item;

    this.recent = this._search.SessionSearches;

    this._api.postSearch(item).subscribe(((searchItem: Post[]) => {
      if (searchItem) {
        this.results = [];
        this.resultsInterface = [];
        if (searchItem['ErrNo'] === undefined) {
          if (searchItem['Count'] === '0') {
            this._alert.showWarnAlert('No result(s) found.');
          } else {
            this.results = searchItem;
           for (let i = 0; i < this.results.length; i++) {
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
               courseName: ''
             };

             CMItem.messageId  = this.results[i].ID;
             CMItem.courseId = this.results[i].CourseID;
             CMItem.title = this.results[i].Title;
             CMItem.message = this.results[i].Message;
             CMItem.author = this.results[i].FirstName + ' ' + this.results[i].LastName;
             CMItem.authorId = this.results[i].UserID;
             CMItem.lastUpdate = this.results[i].TimeCreated;
             CMItem.type = this.results[i].Type;
             CMItem.courseName = this._sidebar.getCourseName(CMItem.courseId);

             this.resultsInterface.push(CMItem);
           }
           this.selectedTab = 1;
          }
        } else {
          this._alert.showErrorAlert(searchItem['Description']);
        }
      }
    }));
  }

  saveSearch() {
    const item = this.getSearchObj();
    const _dialog = this.dialog.open(OmsSimpleInputComponent, {
      width: '350px',
      height: '200px',
      data: this.inputItem
    });

    _dialog.afterClosed().subscribe(result => {
      if (result) {
       item.name = result;
        this._api.addSearch(item, this.userId).subscribe((saveItem) => {
          if (saveItem['ErrNo'] === undefined || saveItem['ErrNo'] === '0') {
            this._alert.showSuccessAlert('Search has been saved.');
            this._user.refreshUserSettings();
            this._settingsSubscription = this._user.settings.subscribe((settings: UserSettings) => {
              if (settings.savedSearches.length > 0) {
                for (let i = 0; i < settings.savedSearches.length; i++) {
                  this.saved.push(settings.savedSearches[i]);
                }
              }
            });
          } else {
            this._alert.showErrorAlert(saveItem['Description']);
          }
        });
      }
    });
  }


  private getSearchObj(): SearchInterface {
    const item = {
      CourseID: 0,
      UserGroupID: 0,
      MessageGroupID: 0,
      IsThread: false,
      CreationTimeGTE: '',
      CreationTimeLTE: '',
      ChildCountGTE: 0,
      ChildCountLTE: 0,
      ScoreGTE: 0,
      ScoreLTE: 0,
      name: ''
    };

    if (this.searchForm.controls['courseSelector']) {
      item.CourseID = Number(this.searchForm.controls['courseSelector'].value);
    }

    if (this.searchForm.controls['CreationTimeGTE']) {
      item.CreationTimeGTE = this.searchForm.controls['CreationTimeGTE'].value;
    }
    if (this.searchForm.controls['CreationTimeLTE']) {
      item.CreationTimeLTE = this.searchForm.controls['CreationTimeLTE'].value;
    }

    if (this.searchForm.controls['ChildCountGTE']) {
      item.ChildCountGTE = this.searchForm.controls['ChildCountGTE'].value;
    }

    if (this.searchForm.controls['ChildCountLTE']) {
      item.ChildCountLTE = this.searchForm.controls['ChildCountLTE'].value;
    }

    if (this.searchForm.controls['ScoreGTE']) {
      item.ScoreGTE = this.searchForm.controls['ScoreGTE'].value;
    }

    if (this.searchForm.controls['ScoreLTE']) {
      item.ScoreLTE = this.searchForm.controls['ScoreLTE'].value;
    }

    return item;
  }

  courseOutput($event) {
    if ($event > 0) {
      this.courseId = $event;
    }
  }
}
