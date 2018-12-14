import {Component, Inject, OnInit} from '@angular/core';
import { AuthSystemService } from '../../services/auth-system/auth-system.service';
import {Router} from '@angular/router';
import {DOCUMENT} from '@angular/common';

@Component({
  selector: 'app-login-landing',
  templateUrl: './login-landing.component.html',
  styleUrls: ['./login-landing.component.css']
})
export class LoginLandingComponent implements OnInit {
  isCASLogin = false;

  constructor(private Auth: AuthSystemService, private router: Router, @Inject(DOCUMENT) private document: any) { }

  ngOnInit() {
    this.isCASLogin = this.Auth.isCASLogin;

    if (this.Auth.isLoggedIn) {
      this.router.navigate(['/dashboard']);
    }
  }

  goToLogin() {
    this.router.navigate(['/login']);
  }

  goToCASLogin() {
    this.document.location.href = this.Auth.getCASLoginUrl;
  }

}
