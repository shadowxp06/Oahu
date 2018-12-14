import {Component, Inject, OnInit} from '@angular/core';
import { SimpleInputTypes } from '../../../enums/simple-input-types.enum';
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material';
import {SimpleInputInterface} from '../../../interfaces/simple-input-interface';

@Component({
  selector: 'app-oms-simple-input',
  templateUrl: './oms-simple-input.component.html',
  styleUrls: ['./oms-simple-input.component.css']
})
export class OmsSimpleInputComponent implements OnInit {

  type = SimpleInputTypes;

  constructor(@Inject(MAT_DIALOG_DATA) public data: SimpleInputInterface,
              public dialogRef: MatDialogRef<OmsSimpleInputComponent>) { }

  ngOnInit() {
    if (this.data.result !== '') {
      this.data.result = '';
    }
  }

  cancelClick() {
    this.dialogRef.close();
  }

}
