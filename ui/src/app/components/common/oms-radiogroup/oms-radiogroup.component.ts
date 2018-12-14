import {Component, EventEmitter, Input, OnInit, Output} from '@angular/core';
import {Dropdownlistiteminterface} from '../../../interfaces/dropdownlistitem';
import {FormGroup} from '@angular/forms';
import {DirectionAlignment} from '../../../enums/direction-alignment.enum';

@Component({
  selector: 'app-oms-radiogroup',
  templateUrl: './oms-radiogroup.component.html',
  styleUrls: ['./oms-radiogroup.component.css']
})
export class OmsRadiogroupComponent implements OnInit {
  @Input() required?: boolean;
  @Input() items: Dropdownlistiteminterface[];
  @Input() name: string;
  @Input() formGroup?: FormGroup;
  @Input() direction: DirectionAlignment;
  @Input() title: string;
  @Input() selectedItem?: string;

  @Output() outputData = new EventEmitter();


  DirAlign = DirectionAlignment;

  constructor() { }

  ngOnInit() {

  }

  emit() {
    if (!this.formGroup.controls[this.name].pristine) {
      this.outputData.emit(this.formGroup.controls[this.name].value);
    }
  }

}
