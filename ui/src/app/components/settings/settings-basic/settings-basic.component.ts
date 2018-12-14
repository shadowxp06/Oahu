import {Component, Input, OnInit} from '@angular/core';
import {FormGroup} from '@angular/forms';
import {Threadsshown} from '../../../enums/threadsshown.enum';
import {DirectionAlignment} from '../../../enums/direction-alignment.enum';
import {Setting} from '../../../interfaces/setting';


@Component({
  selector: 'app-settings-basic',
  templateUrl: './settings-basic.component.html',
  styleUrls: ['./settings-basic.component.css']
})
export class SettingsBasicComponent implements OnInit {

  @Input() parentFormGroup: FormGroup;
  @Input() settings: Setting[];

  threadsShown = Threadsshown.courseDefault;

  threadShownOptions = [
    { name: 'Use Course Default', value: Threadsshown.courseDefault },
    { name: 'Show 10 by Default', value: Threadsshown.ShowTenByDefault },
    { name: 'Show 25 by Default', value: Threadsshown.ShowTwentyFiveByDefault }
  ];

  color = 'primary';
  timezoneSelectedItem = '';

  DirAlign = DirectionAlignment;

  constructor() {

  }

  ngOnInit() {
    this.onChanges();
  }

  onChanges() {
    this.parentFormGroup.get('threadsShown').valueChanges.subscribe(val => {
      this.setThreadsShown(val);
    });

    this.parentFormGroup.get('timezone').valueChanges.subscribe(val => {
      this.setTimezone(val);
    });
  }

  setTimezone($event) {
    this.timezoneSelectedItem = $event;
  }

  setThreadsShown($event) {
    if ($event >= 0) {
      this.threadsShown = $event;
    }
  }

}
