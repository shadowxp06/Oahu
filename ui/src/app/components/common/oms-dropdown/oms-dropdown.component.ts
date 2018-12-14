import {Component, OnInit, Input, Output, EventEmitter, OnChanges, SimpleChanges} from '@angular/core';

import { Dropdownlistiteminterface } from '../../../interfaces/dropdownlistitem';
import {FormGroup} from '@angular/forms';

@Component({
  selector: 'app-oms-dropdown',
  templateUrl: './oms-dropdown.component.html',
  styleUrls: ['./oms-dropdown.component.css']
})
export class OmsDropdownComponent implements OnInit, OnChanges {

  selectItem = 0;

  @Input() required?: boolean;
  @Input() items: Dropdownlistiteminterface[];
  @Input() name: string;
  @Input() invalidId: number;
  @Input() formGroup: FormGroup;
  @Input() placeholder: string;
  @Input() selectedItem?: number;
  @Input() multiselect?: boolean;
  @Input() selectRequiredMessage: string;
  @Input() invalidValueMessage: string;
  @Input() doValidation?: boolean;

  @Output() outputData = new EventEmitter();


  constructor() { }

  ngOnInit() {
    this.selectItem = this.selectedItem;
  }

  ngOnChanges(changes: SimpleChanges) {
    if (changes.selectedItem.currentValue > 0) {
      this.selectItem = changes.selectedItem.currentValue;
    }
  }

  emit() {
    if (!this.formGroup.controls[this.name].pristine) {
      this.outputData.emit(this.selectedItem);
    }
  }
}
