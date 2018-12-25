import {Component, OnDestroy, OnInit, ViewChild} from '@angular/core';
import {FormBuilder, FormGroup, Validators, FormControl} from '@angular/forms';
import { SidebarService } from '../../services/sidebar/sidebar.service';
import {MatTabGroup} from '@angular/material';
import {APIService} from '../../services/api/api.service';
import {ActivatedRoute} from '@angular/router';
import {Course} from '../../interfaces/course';
import {AlertService} from '../../services/alert/alert.service';
import * as moment from 'moment';

@Component({
  selector: 'app-course-settings',
  templateUrl: './course-settings.component.html',
  styleUrls: ['./course-settings.component.css']
})
export class CourseSettingsComponent implements OnInit, OnDestroy {
  courseSettings: FormGroup;
  showSideBar = false;

  color = 'primary';
  currentTabIndex = -1;

  classId = 0;


  @ViewChild(MatTabGroup) settingsTab: MatTabGroup;

  constructor(private _formBuilder: FormBuilder,
              private _sidebarService: SidebarService,
              private _api: APIService,
              private _activatedRoute: ActivatedRoute,
              private _alert: AlertService) {


    this.showSideBar = _sidebarService.isSidebarVisible;

    if (_activatedRoute.snapshot.params) {
      if (_activatedRoute.snapshot.params['id'] > 0) {
        this.classId = this._activatedRoute.snapshot.params['id'];
      }
    }
  }

  ngOnInit() {
    this.courseSettings = this._formBuilder.group({
      basic: this._formBuilder.group({
        courseName: new FormControl({ value: '', disabled: true}, [Validators.required]),
        courseSection: new FormControl({ value: '', disabled: true}, [Validators.required]),
        courseDescription: new FormControl({ value: '', disabled: false}, [Validators.required])
      }),
      enrollment: this._formBuilder.group({
        courseStart: new FormControl({ value: '', disabled: false}, [Validators.required]),
        courseEnd: new FormControl({ value: '', disabled: false}, [Validators.required]),
        enrollKey: new FormControl( { value: '', disabled: true })
      }),
      groups: this._formBuilder.group({

      }),
      participation: this._formBuilder.group(
        {
          participationStart: new FormControl({ value: '', disabled: false}),
          participationEnd: new FormControl({ value: '', disabled: false}),
          postsBy: new FormControl({ value: '', disabled: false }),
          exportOptions: new FormControl({ value: '', disabled: false })
        }
      ),
      qa: this._formBuilder.group({
        allowStudentsToTagInstructors: new FormControl({ value: '', disabled: false }),
        TaggingInQAPosts: new FormControl({ value: '', disabled: false }),
        AllowAnonymousPosts: new FormControl({ value: '', disabled: false }),
        allowStudentsToCreateGroups: new FormControl({ value: '', disabled: false }),
        threadsShown: new FormControl({value: '0', disabled: false}),
        disallowLikes: new FormControl({value: '', disabled: false})
      })
    });

    this.currentTabIndex = 0;

    this.settingsTab.selectedTabChange.subscribe( data => {
      this.currentTabIndex = this.settingsTab.selectedIndex;
    });

    this._api.getCourseSettings(this.classId).subscribe( ((data: Course) => {
      if (data) {
        this.courseSettings.controls['basic']['controls']['courseName'].setValue(data.Name);
        this.courseSettings.controls['basic']['controls']['courseSection'].setValue(data.Number);
        this.courseSettings.controls['basic']['controls']['courseDescription'].setValue(data.Description);
        this.courseSettings.controls['qa']['controls']['AllowAnonymousPosts'].setValue(data.allowAnonymousPosts);
        this.courseSettings.controls['qa']['controls']['allowStudentsToTagInstructors'].setValue(data.allowStudentsToTagTAInstructors);
        this.courseSettings.controls['qa']['controls']['TaggingInQAPosts'].setValue(data.allowStudentsToTagInQAPosts);
        this.courseSettings.controls['qa']['controls']['allowStudentsToCreateGroups'].setValue(data.allowStudentsToCreateGroups);
        this.courseSettings.controls['qa']['controls']['threadsShown'].setValue(Number(data.threadsShown));
        this.courseSettings.controls['qa']['controls']['disallowLikes'].setValue(data.disallowLikes);
        this.courseSettings.controls['enrollment']['controls']['courseStart'].setValue(data.StartDate);
        this.courseSettings.controls['enrollment']['controls']['courseEnd'].setValue(data.EndDate);
        this.courseSettings.controls['enrollment']['controls']['enrollKey'].setValue(data.SetupKey);
      } else {
        this._alert.showErrorAlert('Cannot get Course Settings.  Please contact a System Administrator for help.');
      }
    }));
  }

  submit() {
    if (this.currentTabIndex === 2) {

    } else {
      const settings = [];

      /* Basic Settings */
      let item;

      item = { Name: 'courseDescription', Value: this.courseSettings.controls['basic']['controls']['courseDescription'].value };
      settings.push(item);


      /* Groups */
      item = { Name: 'allowStudentsToCreateGroups', Value: this.courseSettings.controls['qa']['controls']['allowStudentsToCreateGroups'].value.toString() };
      settings.push(item);

      /* QA */
      item = { Name: 'allowStudentsToTagInstructors', Value: this.courseSettings.controls['qa']['controls']['allowStudentsToTagInstructors'].value.toString() };
      settings.push(item);


      item = { Name: 'allowAnonymousPosts', Value: this.courseSettings.controls['qa']['controls']['AllowAnonymousPosts'].value.toString() };
      settings.push(item);

      item = { Name: 'allowStudentsToTagInQAPosts', Value: this.courseSettings.controls['qa']['controls']['TaggingInQAPosts'].value.toString() };
      settings.push(item);

      item = { Name: 'threadsShown', Value: this.courseSettings.controls['qa']['controls']['threadsShown'].value.toString() };
      settings.push(item);

      if (this.courseSettings.controls['qa']['controls']['disallowLikes'].value) {
        item = { Name: 'disallowLikes', Value: this.courseSettings.controls['qa']['controls']['disallowLikes'].value.toString() };
        settings.push(item);
      }


      let momentFormat = moment(this.courseSettings.controls['enrollment']['controls']['courseStart'].value).format('MM/DD/YYYY');

      item = { Name: 'courseStart', Value: momentFormat };
      settings.push(item);

      momentFormat = moment(this.courseSettings.controls['enrollment']['controls']['courseEnd'].value).format('MM/DD/YYYY');
      item = { Name: 'courseEnd', Value: momentFormat };
      settings.push(item);

      this._api.postCourseSettings(settings, this.classId).subscribe((result) => {
        if (result['ErrNo'] === 0 || result['ErrNo'] === undefined) {
          this._alert.showSuccessAlert('Setting(s) saved');
        } else {
          this._alert.showErrorAlert(result['Description']);
        }
      });
    }
  }

  ngOnDestroy(): void {

  }

}
