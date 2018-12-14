import {Injectable} from '@angular/core';
import {BehaviorSubject} from 'rxjs';
import {MessageCounts} from '../../interfaces/message-counts';

@Injectable({
  providedIn: 'root'
})
export class MessagesService {
  _counts: MessageCounts =
    { all: 0,
      announcements: 0,
      unread: 0,
      globalAll: 0,
      globalAnnouncements: 0,
      globalUnread: 0,
      globalDrafts: 0,
      globalStarred: 0};

  countsBS: BehaviorSubject<MessageCounts> = new BehaviorSubject<MessageCounts>(this._counts);

  constructor() {
  }

  clearGlobalItems() {
    this._counts.globalAll = 0;
    this._counts.globalAnnouncements = 0;
    this._counts.globalUnread = 0;
    this._counts.globalDrafts = 0;
    this._counts.globalStarred = 0;
    this._counts.unread = 0;
    this.updateItems();
  }

  clearClassItems() {
    this._counts.unread = 0;
    this._counts.announcements = 0;
    this._counts.all = 0;
    this.updateItems();
  }

  clearAllItems() {
    this._counts = { all: 0,
      announcements: 0,
      unread: 0,
      globalAll: 0,
      globalAnnouncements: 0,
      globalUnread: 0,
      globalDrafts: 0,
      globalStarred: 0};

    this.updateItems();
  }

  updateItems() {
    this.countsBS.next(this._counts);
  }

  get all(): number {
    return this._counts.all;
  }

  set all(count: number) {
    this._counts.all = count;
  }

  get announcements(): number {
    return this._counts.announcements;
  }

  set announcements(count: number) {
     this._counts.announcements = count;
  }

  get unread(): number {
    return this._counts.unread;
  }

  set unread(count: number) {
    this._counts.unread = count;
  }

  get globalAll(): number {
    return this._counts.globalAll;
  }

  set globalAll(count: number) {
     this._counts.globalAll = count;
  }

  get globalAnnouncements() {
    return this._counts.globalAnnouncements;
  }

  set globalAnnouncements(count: number) {
    this._counts.globalAnnouncements = count;
  }

  get globalStarred() {
    return this._counts.globalStarred;
  }

  set globalStarred(count: number) {
    this._counts.globalStarred = count;
  }
}
