import { Injectable } from '@angular/core';
import {Dialogtype} from '../../enums/dialogtype.enum';
import {DialogAlertComponent} from '../../components/common/dialog-alert/dialog-alert.component';
import {MatDialog} from '@angular/material';

@Injectable({
  providedIn: 'root'
})
export class AlertService {

  _title = '';
  _width = '450px';

  constructor(private dialog: MatDialog) { }

  public showErrorAlert(text: string) {
    this._title = 'Error';

    this.dialog.open(DialogAlertComponent, {
      width: this._width,
      data: { title: this._title, dialogText: text, type: Dialogtype.error }
    });
  }

  public showCustomAlert(text: string) {
    this.dialog.open(DialogAlertComponent, {
      width: this._width,
      data: { title: this._title, dialogText: text, type: Dialogtype.error }
    });
  }

  public showInfoAlert(text: string) {
    this._title = 'Info';

    this.dialog.open(DialogAlertComponent, {
      width: this._width,
      data: { title: this._title, dialogText: text, type: Dialogtype.info }
    });
  }

  public showWarnAlert(text: string) {
    this._title = 'Warning';

    this.dialog.open(DialogAlertComponent, {
      width: this._width,
      data: { title: this._title, dialogText: text, type: Dialogtype.warn }
    });
  }

  public showSuccessAlert(text: string) {
    this._title = 'Success';

    this.dialog.open(DialogAlertComponent, {
      width: this._width,
      data: { title: this._title, dialogText: text, type: Dialogtype.success }
    });
  }

  public set title(title: string) {
    this._title = title;
  }

  public set width(width: string) {
    this._width = width;
  }
}
