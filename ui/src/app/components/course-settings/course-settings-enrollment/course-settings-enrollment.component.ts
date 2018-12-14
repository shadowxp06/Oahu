import {Component, Input, OnInit} from '@angular/core';
import {FormGroup} from '@angular/forms';
import {DirectionAlignment} from '../../../enums/direction-alignment.enum';
import {ActivatedRoute} from '@angular/router';
import {MatDialog} from '@angular/material';
import {CourseEnrollmentDialogComponent} from '../../common/course-enrollment-dialog/course-enrollment-dialog.component';
import {AclInterface} from '../../../interfaces/acl-interface';
import {APIService} from '../../../services/api/api.service';
import {AlertService} from '../../../services/alert/alert.service';

@Component({
  selector: 'app-course-settings-enrollment',
  templateUrl: './course-settings-enrollment.component.html',
  styleUrls: ['./course-settings-enrollment.component.css']
})
export class CourseSettingsEnrollmentComponent implements OnInit {
  @Input() parentFormGroup: FormGroup;

  placeHolders = ['Course Start Date', 'Course End Date'];

  DirAlign = DirectionAlignment;

  courseId = 0;

  aclModel: AclInterface = { ID: 0, LastName: '', LoginName: '', FirstName: '', UserType: '1' };

  constructor(private _activatedRoute: ActivatedRoute,
              public dialog: MatDialog,
              private _api: APIService,
              private _alert: AlertService) { }

  ngOnInit() {
    if (this._activatedRoute.snapshot.params) {
      if (this._activatedRoute.snapshot.params['id'] > 0) {
        this.courseId = this._activatedRoute.snapshot.params['id'];
      }
    }
  }

  openCourseEnrollment() {
    const _dialog = this.dialog.open(CourseEnrollmentDialogComponent, {
      width: '300px',
      data: { accessKey: '', isManualEnrollment: true },
    });

    _dialog.afterClosed().subscribe(result => {
      if (result) {
        this.aclModel.LoginName = result['email'];
        this.aclModel.UserType = result['type'];

        this._api.enrollUser(this.aclModel, this.courseId).subscribe((data => {
          if (data['ErrNo'] === '0') {
            this._alert.showSuccessAlert('User has been enrolled.');
          } else {
            this._alert.showErrorAlert(data['Description']);
          }
        }));

        this.aclModel = { ID: 0, LastName: '', LoginName: '', FirstName: '', UserType: '1' };
      }
    });
  }

}
