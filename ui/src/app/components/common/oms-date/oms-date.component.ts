import { Component, OnInit, Output, Input, EventEmitter } from '@angular/core';
import {DirectionAlignment } from '../../../enums/direction-alignment.enum';
import * as _moment from 'moment';
import {FormGroup} from '@angular/forms';

@Component({
  selector: 'app-oms-date',
  templateUrl: './oms-date.component.html',
  styleUrls: ['./oms-date.component.css']
})
export class OmsDateComponent implements OnInit {

  @Input() name: string;
  @Input() formGroup: FormGroup;
  @Input() placeHolder: string;
  @Input() direction: DirectionAlignment;

  @Output()

  DirAlign = DirectionAlignment;

  rOne = '';

  constructor() { }

  ngOnInit() {
  }

  setRangeOne(val) {
    this.rOne = _moment(val.value).format('MM/DD/YYYY');
  }

}
