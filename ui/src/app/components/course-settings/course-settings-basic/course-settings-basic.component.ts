import {Component, Input, OnInit} from '@angular/core';
import {FormBuilder, FormGroup} from '@angular/forms';
import {DirectionAlignment} from '../../../enums/direction-alignment.enum';
import {Threadsshown} from '../../../enums/threadsshown.enum';

@Component({
  selector: 'app-course-settings-basic',
  templateUrl: './course-settings-basic.component.html',
  styleUrls: ['./course-settings-basic.component.css']
})
export class CourseSettingsBasicComponent implements OnInit {
  

  userDisplayedResources = Threadsshown.ShowTenByDefault;
  color = 'primary';

  DirAlign = DirectionAlignment;


  @Input() parentFormGroup: FormGroup;

  constructor() { }

  ngOnInit() {
  }

  setDisplayedResources($event) {
    this.userDisplayedResources = $event;
  }
}
