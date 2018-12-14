import { Injectable } from '@angular/core';
import {SearchInterface} from '../../interfaces/search-interface';

@Injectable({
  providedIn: 'root'
})
export class SearchService {
  _currentSearchObj: SearchInterface = {
      CourseID: 0,
      ChildCountGTE: 0,
      ChildCountLTE: 0,
      CreationTimeGTE: '',
      CreationTimeLTE: '',
      IsThread: false,
      MessageGroupID: 0,
      ScoreGTE: 0,
      ScoreLTE: 0,
      UserGroupID: 0
  };

  _sessionSearches: SearchInterface[] = [];


  constructor() { }

  set CurrentSearchObj(item: SearchInterface) {
    this._currentSearchObj = item;
  }

  get CurrentSearchObj(): SearchInterface {
    return this._currentSearchObj;
  }

  addToSessionSearches(item: SearchInterface) {
    this._sessionSearches.push(item);
  }

  get SessionSearches(): SearchInterface[] {
    return this._sessionSearches;
  }
}
