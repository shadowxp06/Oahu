import {Component, OnDestroy, OnInit, ViewChild} from '@angular/core';
import {FormBuilder, FormGroup, Validators, FormControl} from '@angular/forms';
import { faBook } from '@fortawesome/free-solid-svg-icons/faBook';
import {SidebarService} from '../../services/sidebar/sidebar.service';
import {MatDialog, MatTabGroup} from '@angular/material';
import {APIService} from '../../services/api/api.service';
import {AlertService} from '../../services/alert/alert.service';
import {AuthSystemService} from '../../services/auth-system/auth-system.service';
import {UserService} from '../../services/user/user.service';
import {UserSettings} from '../../interfaces/user-settings';
import {ClassListInterface} from '../../interfaces/class-list';

@Component({
  selector: 'app-settings',
  templateUrl: './settings.component.html',
  styleUrls: ['./settings.component.css']
})
export class SettingsComponent implements OnInit, OnDestroy {
  settings: FormGroup;
  showSideBar = false;

  faBook = faBook;
  currentTabIndex = -1;


  @ViewChild(MatTabGroup) settingsTab: MatTabGroup;

  constructor(private _formBuilder: FormBuilder,
              private _sidebarService: SidebarService,
              public dialog: MatDialog,
              private _api: APIService,
              private _alert: AlertService,
              private _auth: AuthSystemService,
              private _user: UserService) {
  }

  ngOnDestroy(): void {
  }

  ngOnInit() {
    this.settings = this._formBuilder.group({
      basic: this._formBuilder.group({
        displayName: ['', [Validators.required]],
        email: new FormControl({ value: '', disabled: true }),
        timezone: new FormControl({ value: '', disabled: false }),
        threadsShown: new FormControl({ value: '0', disabled: false}),
        useCreatePostWizard: new FormControl(false, [])
      }),

      courses: this._formBuilder.group({

      }),

      notifications: this._formBuilder.group({
        email_NewQuestionsNotesAnnouncements: new FormControl({ value: '', disabled: false }),
        email_FollowedQuestionsNotesAnnouncements: new FormControl({ value: '', disabled: false }),
        email_NewReplyOnFavorite: new FormControl( false),
        email_NewReplyOnCreatedThread: new FormControl(false, []),
        email_groupIsTagged: new FormControl(false, []),
        display_NewQuestionsNotesAnnouncements: new FormControl({ value: 0, disabled: false }),
        display_FollowedQuestionsNotesAnnouncements: new FormControl({ value: 0, disabled: false })
      })
    });

    this.currentTabIndex = 0;

    this.settingsTab.selectedTabChange.subscribe( data => {
      this.currentTabIndex = this.settingsTab.selectedIndex;
    });

    this._user.refreshUserSettings();
    this._user.settings.subscribe((data: UserSettings) => {
      if (data) {
        if (data.displayName !== '') {
          this.settings.controls['basic']['controls']['displayName'].setValue(data.displayName);
        } else {
          this.settings.controls['basic']['controls']['displayName'].setValue(this._auth.userName); /* Set the default to their user name */
        }

        if (data.email !== '') {
          this.settings.controls['basic']['controls']['email'].setValue(data.email);
        } else {
          this.settings.controls['basic']['controls']['email'].setValue(this._auth.userName + '@gatech.edu');
        }

        this.settings.controls['basic']['controls']['timezone'].setValue(data.timezone);
        this.settings.controls['basic']['controls']['threadsShown'].setValue(data.threadsShown);

        this.settings.controls['notifications']['controls']['email_NewQuestionsNotesAnnouncements'].setValue(data.email_NewQuestionsNotesAnnouncements);
        this.settings.controls['notifications']['controls']['email_FollowedQuestionsNotesAnnouncements'].setValue(data.email_FollowedQuestionsNotesAnnouncements);
        this.settings.controls['notifications']['controls']['email_NewReplyOnFavorite'].setValue(data.email_NewReplyOnFavorite);
        this.settings.controls['notifications']['controls']['email_NewReplyOnCreatedThread'].setValue(data.email_NewReplyOnCreatedThread);
        this.settings.controls['notifications']['controls']['email_groupIsTagged'].setValue(data.email_groupIsTagged);

        this.settings.controls['notifications']['controls']['display_NewQuestionsNotesAnnouncements'].setValue(data.display_NewQuestionsNotesAnnouncements);
        this.settings.controls['notifications']['controls']['display_FollowedQuestionsNotesAnnouncements'].setValue(data.display_FollowedQuestionsNotesAnnouncements);
      } else {
        this._alert.showErrorAlert('Failed to get User Settings.  Please try refreshing the page.');
      }
    });
  }


  submit() { /* Future Revision: Attempt to move this into the User Service for posting settings */
    const settings = [];

    let item;

    /* Basic Settings */
    item = { Name: 'displayName', Value: this.settings.controls['basic']['controls']['displayName'].value };
    settings.push(item);

    item = { Name: 'threadsShown', Value: this.settings.controls['basic']['controls']['threadsShown'].value.toString() };
    settings.push(item);

    item = { Name: 'timezone', Value: this.settings.controls['basic']['controls']['timezone'].value };
    settings.push(item);

    item = { Name: 'email', Value: this.settings.controls['basic']['controls']['email'].value };
    settings.push(item);

    /* Notification Settings */
    item = { Name: 'email_NewQuestionsNotesAnnouncements', Value: this.settings.controls['notifications']['controls']['email_NewQuestionsNotesAnnouncements'].value.toString()};
    settings.push(item);

    item = { Name: 'email_FollowedQuestionsNotesAnnouncements', Value: this.settings.controls['notifications']['controls']['email_FollowedQuestionsNotesAnnouncements'].value.toString()};
    settings.push(item);

    item = { Name: 'email_NewReplyOnFavorite', Value: this.settings.controls['notifications']['controls']['email_NewReplyOnFavorite'].value.toString() };
    settings.push(item);

    item = { Name: 'email_NewReplyOnCreatedThread', Value: this.settings.controls['notifications']['controls']['email_NewReplyOnCreatedThread'].value.toString() };
    settings.push(item);

    item = { Name: 'email_groupIsTagged', Value: this.settings.controls['notifications']['controls']['email_groupIsTagged'].value.toString() };
    settings.push(item);

    item = { Name: 'display_NewQuestionsNotesAnnouncements', Value: this.settings.controls['notifications']['controls']['display_NewQuestionsNotesAnnouncements'].value.toString() };
    settings.push(item);

    item = { Name: 'display_FollowedQuestionsNotesAnnouncements', Value: this.settings.controls['notifications']['controls']['display_FollowedQuestionsNotesAnnouncements'].value.toString() };
    settings.push(item);

    item = { Name: 'activeCourses', Value: JSON.stringify(this._user._userSettingsList.activeCourses) };
     settings.push(item);

    this._api.postUserSettings(settings).subscribe((result) => {
      if (result) {
        if (result['ErrNo'] === 0 || result['ErrNo'] === undefined) {
          this._alert.showSuccessAlert('Setting(s) saved');
          this.forceSidebarRefresh();
        } else {
          this._alert.showErrorAlert(result['Description']);
        }
      }
    });
  }

  private forceSidebarRefresh() {
    this._api.getUserCourses().subscribe(( (data: ClassListInterface[]) => {
      if (data) {
        if (data['ErrNo'] === undefined) {
          for (let i = 0; i < data.length; i++) {
            if (!this._user.isCourseActive(data[i].ID)) {
              this._sidebarService.removeItem(data[i]);
            }
          }
          this._sidebarService.updateItems();
        }
      }
    }));
  }
}
