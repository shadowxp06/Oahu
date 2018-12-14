import {Component, Inject, OnInit} from '@angular/core';
import { CourseEnrollmentInterface } from '../../../interfaces/course-enrollment';
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { UserLevels } from '../../../enums/user-levels.enum';
import { Dropdownlistiteminterface } from '../../../interfaces/dropdownlistitem';

@Component({
  selector: 'app-course-enrollment-dialog',
  templateUrl: './course-enrollment-dialog.component.html',
  styleUrls: ['./course-enrollment-dialog.component.css']
})
export class CourseEnrollmentDialogComponent implements OnInit {
  accessKeyForm: FormGroup;
  ManualEnrollmentForm: FormGroup;
  isManualEnrollment = false;

  types: Dropdownlistiteminterface[] = [
    { name: 'Teaching Assistant', value: UserLevels.teachingAssistant.toString(), selected: false},
    { name: 'Student', value: UserLevels.student.toString(), selected: false }
  ];

  constructor(public dialogRef: MatDialogRef<CourseEnrollmentDialogComponent>,
              @Inject(MAT_DIALOG_DATA) public data: CourseEnrollmentInterface,
              private formBuilder: FormBuilder) { }

  ngOnInit() {
    this.accessKeyForm = this.formBuilder.group( {
      email: ['', [Validators.required, Validators.email]],
      accessType: ['', [Validators.required]]
    });

    this.ManualEnrollmentForm = this.formBuilder.group( {

    });

    this.isManualEnrollment = this.data.isManualEnrollment;
  }

  cancelClick() {
    this.dialogRef.close();
  }

}
