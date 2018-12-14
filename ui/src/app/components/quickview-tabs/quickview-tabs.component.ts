import { Component, OnInit} from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { faBook, faFilter } from '@fortawesome/free-solid-svg-icons';
import {MessageType} from '../../enums/message-type.enum';
import {MessagesService} from '../../services/messages/messages.service';
import {MessageCounts} from '../../interfaces/message-counts';
import {UserService} from '../../services/user/user.service';
import {UserSettings} from '../../interfaces/user-settings';
import {Subscription} from 'rxjs';
import {FilterLookup} from '../../interfaces/filter-lookup';

@Component({
  selector: 'app-quickview-tabs',
  templateUrl: './quickview-tabs.component.html',
  styleUrls: ['./quickview-tabs.component.css']
})
export class QuickviewTabsComponent implements OnInit {
  courseId = 0;

  faBook = faBook;
  faFilter = faFilter;

  messageType = MessageType;

  _settingsSubscription: Subscription;

  filterData: FilterLookup[] = [];

  BadgeCount: MessageCounts = {
    all: 0,
    unread: 0,
    announcements: 0,
    globalUnread: 0,
    globalAnnouncements: 0,
    globalAll: 0,
    globalStarred: 0,
    globalDrafts: 0
  };

  constructor(private _route: ActivatedRoute,
              private _messages: MessagesService,
              private _user: UserService) {
  }

  ngOnInit() {
    if (this._route.snapshot.params['id']) {
      if (this._route.snapshot.params['id'] > 0) {
        this.courseId = this._route.snapshot.params['id'];
      }
    }

    this.BadgeCount = this._messages.countsBS.value;

    this._user.refreshUserSettings();
    this._settingsSubscription = this._user.settings.subscribe((settings: UserSettings) => {
      if (settings.savedSearches.length > 0) {
        this.filterData = [];
        for (let i = 0; i < settings.savedSearches.length; i++) {
          const item = { name: settings.savedSearches[i].name };
          this.filterData.push(item);
        }
      }
    });
  }

}
