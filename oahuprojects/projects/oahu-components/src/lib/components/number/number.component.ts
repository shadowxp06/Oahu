import {Component, EventEmitter, Input, OnInit, Output} from '@angular/core';
import {FormGroup} from '@angular/forms';

@Component({
  selector: 'oahu-number',
  templateUrl: './number.component.html',
  styleUrls: ['./number.component.css']
})
export class NumberComponent implements OnInit {
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
