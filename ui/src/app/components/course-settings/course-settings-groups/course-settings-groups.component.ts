import {Component, Input, OnInit} from '@angular/core';
import {FormGroup} from '@angular/forms';
import {GroupAddModalComponent} from '../../common/group-add-modal/group-add-modal.component';
import {MatDialog} from '@angular/material';
import {ActivatedRoute} from '@angular/router';
import {APIService} from '../../../services/api/api.service';
import {AlertService} from '../../../services/alert/alert.service';

@Component({
  selector: 'app-course-settings-groups',
  templateUrl: './course-settings-groups.component.html',
  styleUrls: ['./course-settings-groups.component.css']
})
export class CourseSettingsGroupsComponent implements OnInit {
  @Input() parentFormGroup: FormGroup;

  classId = 0;
  color = 'primary';

  constructor(public dialog: MatDialog,
              private _activatedRoute: ActivatedRoute,
              private _api: APIService,
              private _alert: AlertService) {
    if (_activatedRoute.snapshot.params) {
      if (_activatedRoute.snapshot.params['id'] > 0) {
        this.classId = this._activatedRoute.snapshot.params['id'];
      }
    }
  }

  ngOnInit() {
  }


  addGroup() {
    const _dialog = this.dialog.open(GroupAddModalComponent, {
      width: '250px',
      data: { groupName: '', classId: this.classId },
    });

    _dialog.afterClosed().subscribe(result => {
      this._api.addNewGroup(this.classId, result['groupName']).subscribe((data => {
        if (data['body']['ErrNo'] === '0') {
          this._alert.showSuccessAlert('Group has been added.');
        }  else {
          this._alert.showErrorAlert(data['body']['Description']);
        }
      }));
    });
  }
}
