/* Tutorial: https://www.toptal.com/angular/angular-6-jwt-authentication */
import { Injectable } from '@angular/core';
import { environment } from '../../../environments/environment';
import {Observable} from 'rxjs';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { map } from 'rxjs/operators';
import { AlertService } from '../alert/alert.service';
import {Router} from '@angular/router';
import {SessionKey} from '../../interfaces/session-key';

@Injectable({
  providedIn: 'root'
})
export class AuthSystemService {
  _isCASLogin = false;
  CASLoginUrl = 'https://login.gatech.edu/';
  _authToken = '';
  _userName = '';
  _id = 0;
  _tokenName = 'omsDiscussionsJWT';
  _invalidSessionMessage = 'Invalid Session.';

  _headers = new HttpHeaders({
    'Content-Type': 'application/json'
  });

  _authHeaders = new HttpHeaders({
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + this.authToken
  });

  sessionKey: SessionKey = { token: '', id: 0 };

  constructor(private http: HttpClient, private _alertService: AlertService, private _router: Router) {
    this.loadJWT();
  }

  public login(username: string, password: string) {
    const login = {
      UserName: username,
      Password: password
    };

    this.http.post(environment.apiUrl + 'auth', login, { headers: this._headers, observe: 'response' }).subscribe(
      (result) => {
        if (result) {
          if (result.body['ErrNo'] === '0' || result.body['ErrNo'] === 0) {
            this._authToken = result.body['SessionKey'];
            this._userName = result.body['LoginName'];
            const userNameArray = this._userName.split('@');
            this._userName = userNameArray[0];
            this._id = result.body['userId'];
            this._router.navigate(['/dashboard']);
            this.sessionKey.id = this._id;
            this.sessionKey.token = result.body['SessionKey'];
            localStorage.setItem(this._tokenName, JSON.stringify(this.sessionKey));
          } else {
            this._alertService.showErrorAlert(result.body['Description']);
          }
        }
      }
    );
  }

  casLogin(token: string): Observable<boolean> {
    return this.http.get<{token: string, IsCASLogin: boolean, CASToken: string}>('/api/v1/auth/caslogin/' + token).pipe(
      map(result => {
        if (result.IsCASLogin && !result.CASToken) {
          return true;
        } else {
          /* Need to call Alert */
          return false;
        }
      })
    );
  }

  logout() {
    this._authToken = '';
    this._userName = '';
    localStorage.removeItem(this._tokenName);
  }

  public get doRedirect(): boolean {
    this._isCASLogin = environment.enable_cas_redirect;
    return this.isCASLogin;
  }

  public get getCASLoginUrl(): string {
    return this.CASLoginUrl;
  }


  public get isCASLogin(): boolean {
    return this._isCASLogin;
  }


  public get authToken(): string {
    return this._authToken;
  }

  public get isLoggedIn(): boolean {
    return (this._authToken !== null && this._authToken !== '') && localStorage.getItem(this._tokenName) !== null;
  }

  public get authHeaders(): HttpHeaders {
    return this._authHeaders;
  }

  public get userId(): number {
    return this._id;
  }

  public get invalidSessionMessage(): string {
    return this._invalidSessionMessage;
  }

  public get userName(): string {
    return this._userName;
  }

  private loadJWT() {
    if (localStorage.getItem(this._tokenName) !== null && (this._authToken === null || this._authToken === '')) {
      const sk = JSON.parse(localStorage.getItem(this._tokenName));
      this._authToken = sk['token'];
      this._id = sk['id'];
    }
  }

}

