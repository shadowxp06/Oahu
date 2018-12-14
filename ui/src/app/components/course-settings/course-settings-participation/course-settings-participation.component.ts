import {Component, Input, OnInit} from '@angular/core';
import {FormGroup} from '@angular/forms';
import { PostsByOptions } from '../../../enums/posts-by-options.enum';
import { DirectionAlignment } from '../../../enums/direction-alignment.enum';
import { ExportOptions } from '../../../enums/export-options.enum';

@Component({
  selector: 'app-course-settings-participation',
  templateUrl: './course-settings-participation.component.html',
  styleUrls: ['./course-settings-participation.component.css']
})
export class CourseSettingsParticipationComponent implements OnInit {
  @Input() parentFormGroup: FormGroup;

  defPostOpt = PostsByOptions.all;
  defExpOpt = ExportOptions.csv;

  placeHolders = ['Choose Start Date', 'Choose End Date'];

  postsByOptions = [
    { name: 'All', value: PostsByOptions.all },
    { name: 'By Date', value: PostsByOptions.byDate }
  ];

  exportOptions = [
    { name: 'CSV', value: ExportOptions.csv },
    { name: 'JSON', value: ExportOptions.json }
  ];

  DirAlign = DirectionAlignment;

  constructor() { }

  ngOnInit() {
  }

  setPostsBy($event) {
    if ($event >= 0) {
      this.defPostOpt = $event;
    }
  }

  setExportOptions($event) {
    if ($event >= 0) {
      this.defExpOpt = $event;
    }
  }
}
