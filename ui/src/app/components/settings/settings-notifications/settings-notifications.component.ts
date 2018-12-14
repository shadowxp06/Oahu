import {Component, Input, OnInit} from '@angular/core';
import {FormGroup} from '@angular/forms';
import {Threadsshown} from '../../../enums/threadsshown.enum';
import {DirectionAlignment} from '../../../enums/direction-alignment.enum';

@Component({
  selector: 'app-settings-notifications',
  templateUrl: './settings-notifications.component.html',
  styleUrls: ['./settings-notifications.component.css']
})
export class SettingsNotificationsComponent implements OnInit {
  @Input() parentFormGroup: FormGroup;


  email_NewQuestionsNotesAnnouncements = false;
  email_FollowedQuestionsNotesAnnouncements = false;
  email_NewReplyOnFavorite = false;
  email_NewReplyOnCreatedThread  = false;
  email_groupIsTagged = false;

  display_NewQuestionsNotesAnnouncements = 0;
  display_FollowedQuestionsNotesAnnouncements = 0;

  DirAlign = DirectionAlignment;

  Notifications = [
    { name: 'Use Course Default', value: Threadsshown.courseDefault },
    { name: 'Show 10 by Default', value: Threadsshown.ShowTenByDefault },
    { name: 'Show 25 by Default', value: Threadsshown.ShowTwentyFiveByDefault }
  ];

  constructor() { }

  ngOnInit() {
    this.onChanges();
  }

  onChanges() {
    this.parentFormGroup.get('display_NewQuestionsNotesAnnouncements').valueChanges.subscribe(val => {
      this.setNewAnnouncements(val);
    });

    this.parentFormGroup.get('display_FollowedQuestionsNotesAnnouncements').valueChanges.subscribe(val => {
      this.setFollowing(val);
    });

    this.parentFormGroup.get('email_NewReplyOnFavorite').valueChanges.subscribe(val => {
      this.email_NewReplyOnFavorite = val;
    });

    this.parentFormGroup.get('email_NewReplyOnCreatedThread').valueChanges.subscribe(val => {
      this.email_NewReplyOnCreatedThread = val;
    });

    this.parentFormGroup.get('email_groupIsTagged').valueChanges.subscribe(val => {
      this.email_groupIsTagged = val;
    });

    this.parentFormGroup.get('email_NewQuestionsNotesAnnouncements').valueChanges.subscribe(val => {
      this.email_NewQuestionsNotesAnnouncements = val;
    });

    this.parentFormGroup.get('email_FollowedQuestionsNotesAnnouncements').valueChanges.subscribe(val => {
      this.email_FollowedQuestionsNotesAnnouncements = val;
    });
  }

  setNewAnnouncements($event) {
    if ($event >= 0) {
      this.display_NewQuestionsNotesAnnouncements = $event;
    }
  }

  setFollowing($event) {
    if ($event >= 0) {
      this.display_FollowedQuestionsNotesAnnouncements = $event;
    }
  }

}
