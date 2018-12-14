import { Component, OnInit } from '@angular/core';
import {FormBuilder, FormGroup, Validators} from '@angular/forms';
import {APIService} from '../../services/api/api.service';
import {AlertService} from '../../services/alert/alert.service';
import {Router} from '@angular/router';

@Component({
  selector: 'app-user-activation',
  templateUrl: './user-activation.component.html',
  styleUrls: ['./user-activation.component.css']
})
export class UserActivationComponent implements OnInit {

  activationForm: FormGroup;

  constructor(private _formBuilder: FormBuilder,
              private _api: APIService,
              private _alert: AlertService,
              private _route: Router) { }

  ngOnInit() {
    this.activationForm = this._formBuilder.group( {
      activationKey: ['', [Validators.required]]
    });
  }

  doActivation() {
    const key = this.activationForm.get('activationKey').value;
    if (key) {
      this._api.activateAccount(key).subscribe(data => {
        if (data) {
          if (data['ErrNo'] === 0 || data['ErrNo'] === undefined || data['ErrNo'] === '0') {
            this._alert.showSuccessAlert('User account has been activated.');
            this._route.navigate(['/login']);
          }  else {
            this._alert.showErrorAlert(data['Description']);
          }
        }
      });
    }
  }

}
