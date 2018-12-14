import { Injectable } from '@angular/core';
import {APIService} from '../api/api.service';
import {Setting} from '../../interfaces/setting';
import {BehaviorSubject, Observable} from 'rxjs';
import {UserSettings} from '../../interfaces/user-settings';
import {MatDialog} from '@angular/material';
import {BreakpointObserver, Breakpoints, BreakpointState} from '@angular/cdk/layout';

@Injectable({
  providedIn: 'root'
})
export class UserService  {
  _userSettings: Setting[] = [];
  _currentCourseID = 0;


  _userSettingsList: UserSettings = {
    displayName: '',
    email: '',
    timezone: '',
    threadsShown: 0,
    email_NewQuestionsNotesAnnouncements: true,
    email_FollowedQuestionsNotesAnnouncements: true,
    email_NewReplyOnFavorite: true,
    email_NewReplyOnCreatedThread: true,
    email_groupIsTagged: true,
    display_NewQuestionsNotesAnnouncements: 0,
    display_FollowedQuestionsNotesAnnouncements: 0,
    activeCourses: [],
    activeCoursesJSON: '',
    savedSearches: []
  };

  userSettingsList: BehaviorSubject<UserSettings> = new BehaviorSubject(this._userSettingsList);

  constructor(private _api: APIService,
              public dialog: MatDialog,
              private _breakpointObserver: BreakpointObserver) {
  }

  set currentCourseID(id: number) {
    this._currentCourseID = id;
  }

  get currentCourseID(): number {
    return this._currentCourseID;
  }

  get settings(): Observable<any> {
    return this.userSettingsList.asObservable();
  }

  removeActiveCourse(id) {
    if (this._userSettingsList && id > 0) {
      const item = this._userSettingsList.activeCourses.filter(course => course.id === id);
      if (item) {
        this._userSettingsList.activeCourses[this._userSettingsList.activeCourses.indexOf(item[0])].active = false;
      }
    }
  }

  addActiveCourse(id) {
    if (this._userSettingsList && id > 0) {
      const item = this._userSettingsList.activeCourses.filter(course => course.id === id);
      if (item) {
        this._userSettingsList.activeCourses[this._userSettingsList.activeCourses.indexOf(item[0])].active = true;
      }
    }
  }

  isCourseActive(id) {
    if (id > 0) {
      const item = this.userSettingsList.value.activeCourses.filter(course => course.id === id);
      if (item && item.length > 0) {
        return item[0].active;
      }
    }
  }

  getUserCourses() {
    return this._userSettingsList.activeCourses;
  }

  refreshUserSettings() {
    this._api.getUserSettings().subscribe(((data: Setting[]) => {
      if (data) {
        this._userSettings = data;
        for (let i = 0; i < this._userSettings.length; i++) {
          switch (this._userSettings[i].Name) {
            case 'displayName':
              this._userSettingsList.displayName = this._userSettings[i].Value;
              break;
            case 'email':
              this._userSettingsList.email = this._userSettings[i].Value;
              break;
            case 'threadsShown':
              this._userSettingsList.threadsShown = Number(this._userSettings[i].Value);
              break;
            case 'activeCourses':
              const arr = JSON.parse(this._userSettings[i].Value);
              this._userSettingsList.activeCourses = []; /* Clear the list before adding new. */
              for (let n = 0; n < arr.length; n++) {
                const acItem = { active: false, id: 0 };
                acItem.active = arr[n]['active'];
                acItem.id = arr[n]['id'];
                this._userSettingsList.activeCourses.push(acItem);
              }
              break;
            case 'timezone':
              this._userSettingsList.timezone = this._userSettings[i].Value;
              break;
            case 'email_NewQuestionsNotesAnnouncements':
              this._userSettingsList.email_NewQuestionsNotesAnnouncements = this._userSettings[i].Value.toLowerCase() === 'true' ? true : false;
              break;
            case 'email_FollowedQuestionsNotesAnnouncements':
              this._userSettingsList.email_FollowedQuestionsNotesAnnouncements = this._userSettings[i].Value.toLowerCase() === 'true' ? true : false;
              break;
            case 'email_NewReplyOnFavorite':
              this._userSettingsList.email_NewReplyOnFavorite = this._userSettings[i].Value.toLowerCase() === 'true' ? true : false;
              break;
            case 'email_NewReplyOnCreatedThread':
              this._userSettingsList.email_NewReplyOnCreatedThread = this._userSettings[i].Value.toLowerCase() === 'true' ? true : false;
              break;
            case 'email_groupIsTagged':
              this._userSettingsList.email_groupIsTagged = this._userSettings[i].Value.toLowerCase() === 'true' ? true : false;
              break;
            case 'display_NewQuestionsNotesAnnouncements':
              this._userSettingsList.display_NewQuestionsNotesAnnouncements = Number(this._userSettings[i].Value);
              break;
            case 'display_FollowedQuestionsNotesAnnouncements':
              this._userSettingsList.display_FollowedQuestionsNotesAnnouncements = Number(this._userSettings[i].Value);
              break;
            case 'savedSearches':
              const sSearches = JSON.parse(this._userSettings[i].Value);
              this._userSettingsList.savedSearches = [];
              for (let n = 0; n < sSearches.length; n++) {
                this._userSettingsList.savedSearches.push(sSearches[n]);
              }
              break;
            default:
              break;
          }
        }

        this.userSettingsList.next(this._userSettingsList);
      }
    }));
  }

  isMobile(): boolean {
    this._breakpointObserver.observe(Breakpoints.Handset).subscribe((state: BreakpointState) => {
      if (state.matches) {
        return true;
      } else {
        return false;
      }
    });
    return false;
  }
}
