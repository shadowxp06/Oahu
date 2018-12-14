import {Component, Input, OnInit} from '@angular/core';
import {FormGroup} from '@angular/forms';
import {Threadsshown} from '../../../enums/threadsshown.enum';
import {DirectionAlignment} from '../../../enums/direction-alignment.enum';

@Component({
  selector: 'app-course-settings-qa',
  templateUrl: './course-settings-qa.component.html',
  styleUrls: ['./course-settings-qa.component.css']
})
export class CourseSettingsQaComponent implements OnInit {
  @Input() parentFormGroup: FormGroup;

  displayedResources = [
    { name: 'Show 10 by default', value: Threadsshown.ShowTenByDefault },
    { name: 'Show 25 by default', value: Threadsshown.ShowTwentyFiveByDefault },
    { name: 'Show 50 by default', value: Threadsshown.ShowFiftyByDefault },
    { name: 'Show all by default', value: Threadsshown.ShowAllByDefault }
  ];

  userDisplayedResources = Threadsshown.ShowTenByDefault;
  color = 'primary';
  DirAlign = DirectionAlignment;
  checked = false;
  disabled = false;

  constructor() {

  }

  ngOnInit() {
    this.userDisplayedResources = this.parentFormGroup.get('threadsShown').value;
    this.onChanges();
  }

  onChanges() {
    this.parentFormGroup.get('threadsShown').valueChanges.subscribe(val => {
      this.userDisplayedResources = val;
    });
  }

  setDisplayedResources($event) {

  }
}
