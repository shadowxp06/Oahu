import { Component, OnInit, EventEmitter, Output, Input } from '@angular/core';
import { Timezones } from '../../../interfaces/timezones';
import {HttpClient} from '@angular/common/http';
import {FormGroup} from '@angular/forms';

@Component({
  selector: 'app-oms-timezone-select',
  templateUrl: './oms-timezone-select.component.html',
  styleUrls: ['./oms-timezone-select.component.css']
})
export class OmsTimezoneSelectComponent implements OnInit {

  @Input() name: string;
  @Input() formGroup: FormGroup;
  @Input() selectedItem?: string;
  @Output() outputData = new EventEmitter();

  tzdata: Timezones[] = [];
  constructor(private http: HttpClient) {

  }

  ngOnInit() {
    this.http.get('assets/timezones.json').subscribe((data: Timezones[]) => {
      for (let i = 0; i < data['timezones'].length; i++) {
        this.tzdata.push(data['timezones'][i]);
      }
    });
  }

  emit() {
    if (!this.formGroup.controls[this.name].pristine) {
      this.outputData.emit(this.formGroup.controls[this.name].value);
    }
  }

}
