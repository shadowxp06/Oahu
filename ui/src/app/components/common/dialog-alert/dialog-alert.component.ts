import { Component, OnInit, Inject } from '@angular/core';
import { Dialogtype } from '../../../enums/dialogtype.enum';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material';
import { faExclamationTriangle, faInfo, faTimes, faCheckCircle } from '@fortawesome/free-solid-svg-icons';
import { Dialogdata } from '../../../interfaces/dialogdata';

@Component({
  selector: 'app-dialog-alert',
  templateUrl: './dialog-alert.component.html',
  styleUrls: ['./dialog-alert.component.css']
})
export class DialogAlertComponent implements OnInit {

  warn = faExclamationTriangle;
  info = faInfo;
  err = faTimes;
  success = faCheckCircle;

  dialogType = Dialogtype;

  constructor(public dialogRef: MatDialogRef<DialogAlertComponent>, @Inject(MAT_DIALOG_DATA) public data: Dialogdata) { }

  ngOnInit() {
  }

}
