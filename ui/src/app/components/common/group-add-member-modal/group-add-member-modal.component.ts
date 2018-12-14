import {Component, Inject, OnInit} from '@angular/core';
import {MAT_DIALOG_DATA, MatDialogRef} from '@angular/material';
import {FormBuilder, FormGroup} from '@angular/forms';
import {GroupAddMemberModal} from '../../../interfaces/group-add-member-modal';
import {User} from '../../../interfaces/user';
import {UserLookupType} from '../../../enums/user-lookup-type.enum';

@Component({
  selector: 'app-group-add-member-modal',
  templateUrl: './group-add-member-modal.component.html',
  styleUrls: ['./group-add-member-modal.component.css']
})
export class GroupAddMemberModalComponent implements OnInit {

  formGroup: FormGroup;

  classId = 0;
  groupId = 0;

  usrLookupType = UserLookupType;

  members: User[] = [];

  constructor(@Inject(MAT_DIALOG_DATA) public data: GroupAddMemberModal,
              private formBuilder: FormBuilder,
              public dialogRef: MatDialogRef<GroupAddMemberModalComponent>) { }

  ngOnInit() {
    this.formGroup = this.formBuilder.group(
      {

      }
    );

    this.classId = this.data.classId;
  }

  cancelClick() {
    this.dialogRef.close();
  }

  getUsers($event) {
    this.data.members = $event;
  }
}
