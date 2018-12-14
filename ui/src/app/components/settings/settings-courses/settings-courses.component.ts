import {Component, EventEmitter, Input, OnInit, Output} from '@angular/core';
import {FormBuilder, FormGroup} from '@angular/forms';
import {MatDialog} from '@angular/material';
import {CourseInterface} from '../../../interfaces/course-interface';
import {CourseEnrollmentDialogComponent} from '../../common/course-enrollment-dialog/course-enrollment-dialog.component';
import {APIService} from '../../../services/api/api.service';
import {AlertService} from '../../../services/alert/alert.service';

@Component({
  selector: 'app-settings-courses',
  templateUrl: './settings-courses.component.html',
  styleUrls: ['./settings-courses.component.css']
})
export class SettingsCoursesComponent implements OnInit {
  doRefreshes: number = 0;

  settings: FormGroup;
  courses: CourseInterface[];

  @Input() parentFormGroup: FormGroup;
  @Output() coursesDT = new EventEmitter();

  constructor(private _formBuilder: FormBuilder,
              public dialog: MatDialog,
              private _api: APIService,
              private _alert: AlertService) {
  }

  ngOnInit() {
    this.settings = this._formBuilder.group({
    });
  }

  openEnrollmentDialog() {
    const _dialog = this.dialog.open(CourseEnrollmentDialogComponent, {
      width: '300px',
      data: { accessKey: '', isManualEnrollment: false },
    });

    _dialog.afterClosed().subscribe(result => {
      if (result) {
        this._api.selfEnrollCourse(result).subscribe((data => {
            if (data['ErrNo']) {
              if (data['ErrNo'] === '0') {
                this._alert.showSuccessAlert('Successfully enrolled.');
                this.doRefreshes += 1;
                /* Need to Refresh Course Datatable */
              } else if (data['ErrNo'] === '6') { /* Course has not started yet */
                this._alert.showErrorAlert('Cannot enroll in course:  Course has not started yet.');
              } else if (data['ErrNo'] === '7') { /* Course has already ended */
                this._alert.showErrorAlert('Cannot enroll in course: Course has already ended.');
              } else {
                this._alert.showErrorAlert(data['Description']);
              }
            }
          }),
          error => {
            this._alert.showErrorAlert(error['message']);
          });
      }
    });
  }
}


