import {Component, Input, OnInit, ViewChild} from '@angular/core';
import {MatDialog, MatPaginator, MatTableDataSource} from '@angular/material';
import {Groups} from '../../../interfaces/groups';
import {faPlus, faTrashAlt} from '@fortawesome/free-solid-svg-icons';
import {animate, state, style, transition, trigger} from '@angular/animations';
import {APIService} from '../../../services/api/api.service';
import {SidebarService} from '../../../services/sidebar/sidebar.service';
import {UserLevels} from '../../../enums/user-levels.enum';
import {GroupMembers} from '../../../interfaces/group-members';
import {AlertService} from '../../../services/alert/alert.service';
import {GroupAddMemberModalComponent} from '../group-add-member-modal/group-add-member-modal.component';
import {GroupAddModalComponent} from '../group-add-modal/group-add-modal.component';

@Component({
  selector: 'app-groups-datatable',
  templateUrl: './groups-datatable.component.html',
  styleUrls: ['./groups-datatable.component.css'],
  animations: [
    trigger('detailExpand', [
      state('collapsed', style({height: '0px', minHeight: '0', display: 'none'})),
      state('expanded', style({height: '*'})),
      transition('expanded <=> collapsed', animate('225ms cubic-bezier(0.4, 0.0, 0.2, 1)')),
    ]),
  ]
})
export class GroupsDatatableComponent implements OnInit {
  @Input() classId: number;

  UsrLevel: UserLevels = UserLevels.noAccess;

  add = faPlus;
  del = faTrashAlt;

  displayedColumns = ['groupName'];
  dataSource = null;
  isTA = false;

  expandedElement: Groups;
  groups: Groups[] = [];

  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(public dialog: MatDialog,
              private _api: APIService,
              private _sideBar: SidebarService,
              private _alert: AlertService) {

  }

  ngOnInit() {
    this.UsrLevel = this._sideBar.classAccessLookup(this.classId);
    this.isTA = (this.UsrLevel === UserLevels.teachingAssistant) || (this.UsrLevel === UserLevels.admin) || (this.UsrLevel === UserLevels.instructor);

    if (this.isTA) {
      this.displayedColumns.push('add');
      this.displayedColumns.push('delete');
    }

    this._api.getCourseGroups(this.classId).subscribe(((data: Groups[]) => {
      for (let i = 0; i < data.length; i++) {
        if (data[i].GroupName.toString().indexOf('MessageAttachedUsergroup') === -1) {
          data[i].members = [];

          this._api.getGroupMembers(data[i].ID).subscribe( (groupMemberData: GroupMembers[]) => {
            data[i].members = groupMemberData;
          });

          this.groups.push(data[i]);
        }
      }
      this.dataSource =  new MatTableDataSource<Groups>(this.groups);
      this.dataSource.paginator = this.paginator;
    }));

  }

  applyFilter(filterValue: string) {
    this.dataSource.filter = filterValue.trim().toLowerCase();

    if (this.dataSource.paginator) {
      this.dataSource.paginator.firstPage();
    }
  }

  deleteMember(groupId: number, userId: number) {
    if (groupId > 0 && userId > 0) {
      this._api.deleteGroupMember(groupId, userId).subscribe( (data => {
        if (data) {
          if (data['ErrNo'] === '0') {
            const myGroup = this.groups.filter(group => group.ID === groupId);
            if (myGroup && myGroup.length > 0) {
              const mbrItem = this.groups[this.groups.indexOf(myGroup[0])].members.filter(member => member.userId === userId);
              if (mbrItem && mbrItem.length > 0) {
                const indexOfMbr = this.groups[this.groups.indexOf(myGroup[0])].members.indexOf(mbrItem[0]);
                if (indexOfMbr >= 0) {
                  this.groups[this.groups.indexOf(myGroup[0])].members.splice(indexOfMbr, 1);
                }
              }
            }
            this._alert.showSuccessAlert('User deleted from group.');
          } else {
            this._alert.showErrorAlert(data['Description']);
          }
        }
      }));
    } else {
      this._alert.showErrorAlert('Missing Group ID or User ID');
    }
  }

  addGroup() {
    const _dialog = this.dialog.open(GroupAddModalComponent, {
      width: '250px',
      data: { groupName: '', classId: this.classId },
    });

    _dialog.afterClosed().subscribe(result => {
      this._api.addNewGroup(this.classId, result['groupName']).subscribe((data => {
        if (data) {
        }
      }));
    });
  }

  addGroupMember(id: number) {
    const _dialog = this.dialog.open(GroupAddMemberModalComponent, {
      width: '250px',
      data: { members: [], classId: this.classId }
    });

    _dialog.afterClosed().subscribe(result => {
      if (result) {
        for (let i = 0; i < result.length; i++) {
          let hasErrors = false;
           this._api.addGroupMember(id, result[i]['LoginName']).subscribe( (data => {
             if (data) {
               const myGroup = this.groups.filter(group => group.ID === id);
               if (data['body']['ErrNo'] !== '0') {
                 hasErrors = true;
                 this._alert.showInfoAlert(result[i]['FirstName'] + ' ' + result[i]['LastName'] + ' has not been added to the group for the following reason(s): ' + data['body']['Description']);
               } else {
                 const item = { id: 0, name: '', userId: 0 };
                  item.id = id;
                  item.name = result[i]['FirstName'] + ' ' + result[i]['LastName'];
                  item.userId = result[i]['ID'];
                 this.groups[this.groups.indexOf(myGroup[0])].members.push(item);
               }
             }
             if (!hasErrors) {
               this._alert.showSuccessAlert('User(s) have been added.');
             }
           }));

        }
      }
    });
  }

}
