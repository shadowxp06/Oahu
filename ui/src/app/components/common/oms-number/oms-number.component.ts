import {Component, EventEmitter, Input, OnInit, Output} from '@angular/core';
import {FormGroup} from '@angular/forms';

@Component({
  selector: 'app-oms-number',
  templateUrl: './oms-number.component.html',
  styleUrls: ['./oms-number.component.css']
})
export class OmsNumberComponent implements OnInit {
  @Input() formGroup: FormGroup;
  @Input() name: string;
  @Input() placeHolder: string;
  @Input() value?: number;
  @Input() label?: string;

  @Output() outputData = new EventEmitter();

  constructor() { }

  ngOnInit() {
  }

}
