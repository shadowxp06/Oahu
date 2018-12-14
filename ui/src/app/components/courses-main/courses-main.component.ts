import { Component, OnInit } from '@angular/core';

export interface Tags {
  tagName: string;
}

export interface Message {
  messageTitle: string;
  messageTag: string;
  lastUpdated: string;
  lastUpdatedBy: string;
}
@Component({
  selector: 'app-courses-main',
  templateUrl: './courses-main.component.html',
  styleUrls: ['./courses-main.component.css']
})
export class CoursesMainComponent implements OnInit {
  cards = [{ title: 'Latest Announcements', cols: '1', rows: '1' },
    {title: 'Latest Posts', cols: '1', rows: '1'}
  ];

  ourTags: Tags[] = [
    { tagName: 'test' },
    { tagName: 'test2' },
    { tagName: 'test3' },
    { tagName: 'test4' }
  ];

  ourMessages: Message[] = [
    { messageTitle: 'Testing', messageTag: 'Discussions', lastUpdated: '08/01/2018', lastUpdatedBy: 'David Joyner'},
    { messageTitle: 'Testing2', messageTag: 'Discussions', lastUpdated: '08/01/2018', lastUpdatedBy: 'David Joyner'},
    { messageTitle: 'Testing3', messageTag: 'Discussions', lastUpdated: '08/01/2018', lastUpdatedBy: 'David Joyner'},
    { messageTitle: 'Testing4', messageTag: 'Discussions', lastUpdated: '08/01/2018', lastUpdatedBy: 'David Joyner'}
  ];

  displayedColumns: string[] = ['messageTitle', 'messageTag', 'lastUpdated'];

  latestAnnouncements: Message[] = [{ messageTitle: 'Announcement 1', messageTag: 'Discussions', lastUpdated: '08/01/2018',
    lastUpdatedBy: 'David Joyner'},
    { messageTitle: 'Announcement 2', messageTag: 'Announcement', lastUpdated: '08/01/2018', lastUpdatedBy: 'David Joyner'},
    { messageTitle: 'Announcement 3', messageTag: 'Announcement', lastUpdated: '08/01/2018', lastUpdatedBy: 'David Joyner'},
    { messageTitle: 'Announcement 4', messageTag: 'Announcement', lastUpdated: '08/01/2018', lastUpdatedBy: 'David Joyner'}];

  latestAnnouncements_displayedColumns: string[] = ['messageTitle', 'lastUpdated'];

  latestPosts: Message[] = [{ messageTitle: 'Testing', messageTag: 'Discussions', lastUpdated: '08/01/2018',
    lastUpdatedBy: 'David Joyner'},
    { messageTitle: 'Testing2', messageTag: 'Discussions', lastUpdated: '08/01/2018', lastUpdatedBy: 'David Joyner'},
    { messageTitle: 'Testing3', messageTag: 'Discussions', lastUpdated: '08/01/2018', lastUpdatedBy: 'David Joyner'},
    { messageTitle: 'Testing4', messageTag: 'Discussions', lastUpdated: '08/01/2018', lastUpdatedBy: 'David Joyner'}];

  myDataSource = this.ourMessages;
  latestPosts_DataSource = this.latestPosts;
  latestAnnouncements_DataSource = this.latestAnnouncements;

  constructor() { }

  ngOnInit() {

  }
}
