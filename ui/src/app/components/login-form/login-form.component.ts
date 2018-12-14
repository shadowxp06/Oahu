/* Based off of http://jasonwatmore.com/post/2018/05/16/angular-6-user-registration-and-login-example-tutorial */
/* Some code based around OMS Central's code */
import {Component, Inject, OnInit} from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { DOCUMENT } from '@angular/common';
import { AuthSystemService } from '../../services/auth-system/auth-system.service';
import { AlertService } from '../../services/alert/alert.service';
import { Router } from '@angular/router';
import { first } from 'rxjs/operators';

@Component({
  selector: 'app-login-form',
  templateUrl: './login-form.component.html',
  styleUrls: ['./login-form.component.css']
})
export class LoginFormComponent implements OnInit {
  loginForm: FormGroup;
  public email: string;
  public password: string;
  public error: string;

  constructor(private formBuilder: FormBuilder,
              public authService: AuthSystemService,
              private _router: Router,
              @Inject(DOCUMENT) private document: any) {

  }

  ngOnInit() {
    this.loginForm = this.formBuilder.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', Validators.required]
    });

    if (this.authService.isLoggedIn) {
      this._router.navigate(['/dashboard']);
    }

    if (this.authService.doRedirect) {
      this.document.location.href = this.authService.getCASLoginUrl;
    }
  }

  submitLogin() {
    this.authService.login(this.loginForm.controls['email'].value, this.loginForm.controls['password'].value);
  }

  get f() { return this.loginForm.controls; }
}
