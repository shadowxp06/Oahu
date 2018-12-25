import {Component, OnInit, Input, Output, EventEmitter} from '@angular/core';
import {FormGroup} from '@angular/forms';

@Component({
  selector: 'app-oms-toggle',
  templateUrl: './oms-toggle.component.html',
  styleUrls: ['./oms-toggle.component.css']
})
export class OmsToggleComponent implements OnInit {
  @Input() name: string;
  @Input() formGroup: FormGroup;
  @Input() label: string;
  @Input() value?: boolean;

  @Output() outputData = new EventEmitter();

  checkValue = false;

  constructor() { }

  ngOnInit() {
    if (this.value === undefined) {
      this.checkValue = false;
    } else {
      this.checkValue = this.value;
    }

    this.formGroup.get(this.name).valueChanges.subscribe(val => {
      this.checkValue = val;
    });
  }

  emit() {
    if (!this.formGroup.controls[this.name].pristine) {
      this.outputData.emit(this.checkValue);
    }
  }

}
