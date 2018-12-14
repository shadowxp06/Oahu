import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { AuthSystemService } from '../auth-system/auth-system.service';
import { Setting } from '../../interfaces/setting';
import { MessageReply } from '../../interfaces/message-reply';
import {Post} from '../../interfaces/post';
import {MessageVote} from '../../interfaces/message-vote';
import {PollVoteItem} from '../../interfaces/poll-vote-item';
import {UserRegistration} from '../../interfaces/user-registration';
import {AclInterface} from '../../interfaces/acl-interface';
import {SearchInterface} from '../../interfaces/search-interface';
import {FilterLookup} from '../../interfaces/filter-lookup';

@Injectable({
  providedIn: 'root'
})
export class APIService {
  constructor(private http: HttpClient, private _AuthSystem: AuthSystemService) { }

  private getHeaders() {
    return new HttpHeaders({
      'authorization': 'Bearer ' + this._AuthSystem.authToken,
      'Content-Type': 'application/json'
    });
  }

  public getUserCourses() {
    return this.http.get(environment.apiUrl + 'course', { headers: this.getHeaders() });
  }

  /* User Settings */
  public selfEnrollCourse(accessCode: string) {
    return this.http.get(environment.apiUrl + 'course/enroll/' + accessCode, { headers: this.getHeaders() });
  }

  public getUserSettings() {
    return this.http.get(environment.apiUrl + 'user/settings', { headers:  this.getHeaders() });
  }

  public postUserSettings(settings: Setting[]) {
    return this.http.post(environment.apiUrl + 'user/settings', settings, { headers: this.getHeaders(), observe: 'response' });
  }


  public addFavorite(setting: Setting)  {
    return this.http.post(environment.apiUrl + 'user/favorites', setting, { headers: this.getHeaders(), observe: 'response' });
  }
  public getFavorites(userId: number) {
    return this.http.get(environment.apiUrl + 'user/favorites/' + userId, { headers: this.getHeaders(), observe: 'body' });
  }
  /* End of User Settings */

  /* Course Settings */
  public getCourseSettings(id: number) {
    return this.http.get(environment.apiUrl + 'course/' + id + '/settings', { headers: this.getHeaders() });
  }
  public postCourseSettings(settings: Setting[], courseId: number) {
    return this.http.post(environment.apiUrl + 'course/' + courseId + '/settings', settings,{ headers: this.getHeaders(), observe: 'response' });
  }
  /* End of Course settings */

  /* Groups */
  public getCourseGroups(courseId: number) {
    return this.http.get(environment.apiUrl  + 'course/' + courseId + '/groups', { headers: this.getHeaders() });
  }
  public getGroupMembers(groupId: number) {
    return this.http.get(environment.apiUrl + 'groups/' + groupId + '/members', { headers: this.getHeaders() });
  }
  public addNewGroup(courseId: number, groupName: string) {
    const item = { NewGroupName: groupName, NewGroupVisibility: 2};
    return this.http.post(environment.apiUrl + 'groups/' + courseId, item, { headers: this.getHeaders(), observe: 'response' });
  }
  public addGroupMember(groupId: number, username: string) {
    const item = { NewMemberUsername: username,  NewUserType: 4};
    return this.http.post(environment.apiUrl + 'groups/' + groupId + '/members/add', item, { headers: this.getHeaders(), observe: 'response' });
  }
  public deleteGroup(groupId: number) {
    return this.http.delete(environment.apiUrl + 'groups/' + groupId, { headers: this.getHeaders() });
  }
  public deleteGroupMember(groupId: number, memberId: number) {
    return this.http.delete(environment.apiUrl + 'groups/' + groupId + '/' + memberId, { headers: this.getHeaders() });
  }
  /* End of Groups */

  /* Threads */
  public updateThread(threadId: number, post: Post) {
    return this.http.post(environment.apiUrl + 'message/post/' + threadId, post, { headers: this.getHeaders(), observe: 'response' });
  }
  public postThread(courseId: number, post: Post) {
    return this.http.post(environment.apiUrl + 'message/' + courseId + '/createthread', post, { headers: this.getHeaders(), observe: 'response'});
  }

  public getThread(threadId: number) {
    return this.http.get(environment.apiUrl + 'message/post/' + threadId, { headers: this.getHeaders() });
  }

  public postReply(post: MessageReply) {
    return this.http.post(environment.apiUrl + 'message/createreply', post, { headers: this.getHeaders(), observe: 'response'});
  }

  public getUsersInCourse(courseId: number) {
    return this.http.get(environment.apiUrl + 'course/' + courseId + '/users', { headers: this.getHeaders() });
  }

  public getThreadReplies(threadId: number) {
    return this.http.get(environment.apiUrl + 'message/posts/' + threadId, { headers: this.getHeaders() });
  }

  public getMessageVotes(postid: number) {
    return this.http.get(environment.apiUrl + 'message/votes/' + postid, { headers: this.getHeaders() });
  }

  public updateVote(vote: MessageVote) {
    return this.http.post(environment.apiUrl + 'message/vote', vote, { headers: this.getHeaders(), observe: 'response'});
  }
  /* End of threads */

  /* Thread Polls */
  public voteOnItem(PollId: number, item: PollVoteItem) {
    return this.http.post(environment.apiUrl + 'message/pollvote/' + PollId, item, { headers: this.getHeaders(), observe: 'response'});
  }
  /* End of Thread Polls */

  /* User Login */
  public activateAccount(id) {
    return this.http.get(environment.apiUrl + 'auth/validate/' + id, { headers: this.getHeaders() });
  }
  public registerAccount(user: UserRegistration) {
    return this.http.post(environment.apiUrl + 'auth/register', user, { headers: this.getHeaders(), observe: 'response' });
  }
  /* End of user login */

  /* Dashboard */
  public getMessagesFromCourses(userId: number) {
    return this.http.get(environment.apiUrl + 'message/all/' + userId, { headers: this.getHeaders(), observe: 'body'});
  }
  public getMessageForCourse(id: number) {
    return this.http.get(environment.apiUrl + 'message/' + id, { headers: this.getHeaders() });
  }

  /* ACL */
  public getACLInfo(courseId: number) {
    return this.http.get(environment.apiUrl + 'course/' + courseId + '/users', { headers: this.getHeaders()});
  }

  public postACLInfo(item: AclInterface, courseId: number) {
    return this.http.post(environment.apiUrl + 'acl/' + courseId, item, { headers: this.getHeaders(), observe: 'body'});
  }

  public enrollUser(item: AclInterface, courseId: number) {
    return this.http.post(environment.apiUrl + 'acl/enroll/' + courseId, item, { headers: this.getHeaders(), observe: 'body'});
  }
  /* End of ACL */

  /* Search */
  public postSearch(item: SearchInterface) {
    return this.http.post(environment.apiUrl + 'search', item, { headers: this.getHeaders(), observe: 'body' });
  }
  public addSearch(item: SearchInterface, userId: number) {
    return this.http.post(environment.apiUrl + 'search/save/' + userId, item, { observe: 'body', headers: this.getHeaders() });
  }
  public getFilter(item: FilterLookup) {
    return this.http.post(environment.apiUrl + 'search/lookup', item, { observe: 'body', headers: this.getHeaders() });
  }
  /* End of Search */


  public getAllCourses() {
    return this.http.get(environment.apiUrl + 'course/courselist', { observe: 'body', headers: this.getHeaders() });
  }
}
