import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-error',
  templateUrl: './error.component.html',
  styleUrls: ['./error.component.css']
})
export class ErrorComponent implements OnInit {

  _contacts: string[] = ['David Joyner', 'Brandon King'];
  _contactEmails: string[] = ['david.joyner@gatech.edu', 'william.b.king@gatech.edu'];

  constructor() { }

  ngOnInit() {
  }

}
