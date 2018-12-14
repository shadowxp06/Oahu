import { Component, OnInit } from '@angular/core';
import {FormBuilder, FormGroup, Validators} from '@angular/forms';
import {APIService} from '../../services/api/api.service';
import {UserRegistration} from '../../interfaces/user-registration';
import {AlertService} from '../../services/alert/alert.service';
import {Router} from '@angular/router';

@Component({
  selector: 'app-user-registration',
  templateUrl: './user-registration.component.html',
  styleUrls: ['./user-registration.component.css']
})
export class UserRegistrationComponent implements OnInit {

  registrationForm: FormGroup;
  user: UserRegistration = { Email: '', FirstName: '', LastName: '', Password: '', UserName: '' };
  constructor(private _formBuilder: FormBuilder,
              private _api: APIService,
              private _alert: AlertService,
              private _route: Router) { }

  ngOnInit() {

    this.registrationForm = this._formBuilder.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required]],
      fName: ['', [Validators.required]],
      lName: ['', [Validators.required]]
    });

  }

  doRegistration() {
    this.user.Email = this.registrationForm.get('email').value;
    this.user.FirstName = this.registrationForm.get('fName').value;
    this.user.LastName = this.registrationForm.get('lName').value;
    this.user.Password = this.registrationForm.get('password').value;
    this.user.UserName = this.registrationForm.get('email').value;

    this._api.registerAccount(this.user).subscribe( (data => {
      if (data.body['ErrNo'] === 0 || data.body['ErrNo'] === undefined || data.body['ErrNo'] === '0') {
        this._alert.showSuccessAlert('Successfully registered.  You will receive an access code via email.');
        this._route.navigate(['/activation']);
      } else {
        this._alert.showErrorAlert(data.body['Description']);
      }
    }));
  }
}
