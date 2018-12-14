import { Component, OnInit, Input, Output, EventEmitter } from '@angular/core';
import {FormGroup} from '@angular/forms';
import {DirectionAlignment } from '../../../enums/direction-alignment.enum';
import * as _moment from 'moment';

import {MAT_MOMENT_DATE_FORMATS, MomentDateAdapter} from '@angular/material-moment-adapter';
import {DateAdapter, MAT_DATE_FORMATS, MAT_DATE_LOCALE} from '@angular/material/core';

@Component({
  selector: 'app-oms-daterange',
  templateUrl: './oms-daterange.component.html',
  styleUrls: ['./oms-daterange.component.css'],
  providers: [
    {provide: DateAdapter, useClass: MomentDateAdapter, deps: [MAT_DATE_LOCALE]},
    {provide: MAT_DATE_FORMATS, useValue: MAT_MOMENT_DATE_FORMATS},
  ]
})
export class OmsDaterangeComponent implements OnInit {

  @Input() name: string;
  @Input() formGroup: FormGroup;
  @Input() placeholder: string[];
  @Input() direction: DirectionAlignment;
  @Input() required?: boolean;
  @Input() rangeOneName: string;
  @Input() rangeTwoName: string;

  @Output() outputData = new EventEmitter();

  DirAlign = DirectionAlignment;

  rOne = '';
  rTwo = '';

  constructor() { }

  ngOnInit() {

  }

  setRangeOne(val) {
    this.rOne = _moment(val.value).format('MM/DD/YYYY');
  }

  setRangeTwo(val) {
    this.rTwo = _moment(val.value).format('MM/DD/YYYY');
  }
}
