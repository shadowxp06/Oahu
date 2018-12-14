import { Component, OnInit, ViewChild, Input, OnChanges, SimpleChanges, OnDestroy, ChangeDetectorRef } from '@angular/core';
import {APIService} from '../../../services/api/api.service';
import {MatPaginator, MatSort, MatTableDataSource} from '@angular/material';
import {AclInterface} from '../../../interfaces/acl-interface';
import {AlertService} from '../../../services/alert/alert.service';
import { faLevelUpAlt, faLevelDownAlt } from '@fortawesome/free-solid-svg-icons';
import {UserService} from '../../../services/user/user.service';
import {UserStatus} from '../../../enums/user-status.enum';
import {Subscription} from 'rxjs';
import {AuthSystemService} from '../../../services/auth-system/auth-system.service';

@Component({
  selector: 'app-acl-datatable',
  templateUrl: './acl-datatable.component.html',
  styleUrls: ['./acl-datatable.component.css']
})
export class AclDatatableComponent implements OnInit, OnChanges, OnDestroy {
  displayedColumns: string[] = ['name', 'email', 'currentStatus', 'promote'];
  matDataSource: MatTableDataSource<AclInterface>;
  data: AclInterface[] = [];

  promote = faLevelUpAlt;
  demote = faLevelDownAlt;
  disablePromote = false;

  isMobile = false;
  userId = 0;

  status = UserStatus;
  _subscription: Subscription;

  @Input() courseId: number;

  @ViewChild(MatPaginator) paginator: MatPaginator;
  @ViewChild(MatSort) sort: MatSort;

  constructor(private _api: APIService,
              private _alert: AlertService,
              private _user: UserService,
              private _detectorRef: ChangeDetectorRef,
              private _auth: AuthSystemService) {
  }

  ngOnInit() {
    this.isMobile = this._user.isMobile();
    this.userId = this._auth.userId;
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (Number(changes.courseId.currentValue) > 0) {
      this._api.getACLInfo(Number(changes.courseId.currentValue)).subscribe((Acldata: AclInterface[]) => {
        if (Acldata) {
          if (Acldata['ErrNo'] === undefined) {
            for (let i = 0; i < Acldata.length; i++) {
              if (Acldata[i].UserType === 'TA') {
                Acldata[i].Demote = true;
              } else {
                Acldata[i].Demote = false;
              }

              if (Acldata[i].ID === this.userId && this.userId > 0 && Acldata[i].UserType !== 'Instructor') {
                console.log('Promote');
                this.disablePromote = true;
              }

              this.data.push(Acldata[i]);
            }
            this.matDataSource = new MatTableDataSource<AclInterface>(this.data);

            this.matDataSource.paginator = this.paginator;
            this.matDataSource.sort = this.sort;
          } else {
            this._alert.showErrorAlert(Acldata['Description']);
          }
        }
      });
    }
  }

  changeStatus(item: AclInterface, type: UserStatus) {
    switch (type) {
      case UserStatus.demote:
        item.Demote = true;
        item.UserType = 'Student';
        break;
      case UserStatus.promote:
        item.Demote = false;
        item.UserType = 'TA';
        break;
    }

    this._api.postACLInfo(item, this.courseId).subscribe((data => {
      if (data) {
        if (data['ErrNo'] === '0') {
          this._alert.showSuccessAlert('Change(s) saved.');
          this.data[this.data.indexOf(item)].Demote = !(item.Demote);
          this.data[this.data.indexOf(item)].UserType = item.UserType;
          this._detectorRef.detectChanges();

        } else {
          this._alert.showErrorAlert(data['Description']);
        }
      }
    }));
  }

  ngOnDestroy() {
    if (this._subscription) {
      this._subscription.unsubscribe();
    }
  }

  applyFilter(filterValue: string) {
    this.matDataSource.filter = filterValue.trim().toLowerCase();

    if (this.matDataSource.paginator) {
      this.matDataSource.paginator.firstPage();
    }
  }
}
