import {Component, Inject, OnInit} from '@angular/core';
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { GroupAddInterface } from '../../../interfaces/group-add-interface';

@Component({
  selector: 'app-group-add-modal',
  templateUrl: './group-add-modal.component.html',
  styleUrls: ['./group-add-modal.component.css']
})
export class GroupAddModalComponent implements OnInit {
  formGroup: FormGroup;


  constructor(public dialogRef: MatDialogRef<GroupAddModalComponent>,
              private formBuilder: FormBuilder,
              @Inject(MAT_DIALOG_DATA) public data: GroupAddInterface) { }

  ngOnInit() {
    this.formGroup = this.formBuilder.group( {
      groupName: ['', [Validators.required]]
    });
  }

  cancelClick() {
    this.dialogRef.close();
  }
}
