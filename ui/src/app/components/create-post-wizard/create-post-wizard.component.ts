import { Component, OnInit } from '@angular/core';
import {FormBuilder, FormGroup} from '@angular/forms';

@Component({
  selector: 'app-create-post-wizard',
  templateUrl: './create-post-wizard.component.html',
  styleUrls: ['./create-post-wizard.component.css']
})
export class CreatePostWizardComponent implements OnInit {
  postForm: FormGroup;
  generalInfo: FormGroup;

  constructor(private _formBuilder: FormBuilder) { }

  ngOnInit() {
    this.postForm = this._formBuilder.group({
      generalInfo: this._formBuilder.group( {

      })
    });
  }

}
