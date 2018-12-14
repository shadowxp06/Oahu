import {Component, OnInit, Input, Output, EventEmitter} from '@angular/core';
import {FormGroup} from '@angular/forms';
import {DirectionAlignment} from '../../../enums/direction-alignment.enum';
import { faPlus, faMinus } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-oms-list',
  templateUrl: './oms-list.component.html',
  styleUrls: ['./oms-list.component.css']
})
export class OmsListComponent implements OnInit {
  @Input() name: string;
  @Input() items?: string[];
  @Input() showAddButton: boolean;
  @Input() AddItemCaption?: string;
  @Input() formGroup: FormGroup;
  @Input() direction: DirectionAlignment;
  @Input() title: string;
  @Input() isMultiSelect?: boolean;
  @Input() showItemDelete?: boolean;
  @Input() checkboxPosition?: string;

  @Output() dataOutput = new EventEmitter();

  add = faPlus;
  del = faMinus;

  DirAlign = DirectionAlignment;


  constructor() { }

  ngOnInit() {
    if (this.items === undefined) {
      this.items = [];
    }

    if (this.AddItemCaption === '' || this.AddItemCaption === undefined) {
      this.AddItemCaption = 'Add Item';
    }

    if (this.checkboxPosition === '' || this.checkboxPosition === undefined)
    {
      this.checkboxPosition = 'after';
    }
  }

  addItem() {
    if (this.formGroup.controls[this.name].value !== '' && this.formGroup.controls[this.name].value !== undefined) {
      this.items.push(this.formGroup.controls[this.name].value);
      this.emit();
    }
  }

  emit() {
    this.dataOutput.emit(this.items);
  }

}
