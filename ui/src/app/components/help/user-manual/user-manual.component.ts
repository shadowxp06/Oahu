import { Component, OnInit } from '@angular/core';
import {HelpSection} from '../../../interfaces/help-section';
import {HttpClient} from '@angular/common/http';

@Component({
  selector: 'app-user-manual',
  templateUrl: './user-manual.component.html',
  styleUrls: ['./user-manual.component.css']
})
export class UserManualComponent implements OnInit {
  helpItems: HelpSection[] = [];

  newItem: HelpSection = {
    name: '',
    items: []
  };

  constructor(private http: HttpClient) { }
  // <img src="assets/help/images/help.png" />
  ngOnInit() {
    this.newItem = {name: '', items: []};
    this.newItem.name = 'Logging into the system';
    this.newItem.items = [{ filename: 'assets/help/login.html', subtitle: 'test', html: '' }];
    this.helpItems.push(this.newItem);

    this.newItem = {name: '', items: []};
    this.newItem.name = 'Home Page';
    this.newItem.items = [{ filename: 'assets/help/home_page.html', subtitle: 'test', html: '' }];
    this.helpItems.push(this.newItem);

    this.newItem = {name: '', items: []};
    this.newItem.name = 'Enroll In Course';
    this.newItem.items = [{ filename: 'assets/help/enroll_in_course.html', subtitle: 'test', html: '' }];
    this.helpItems.push(this.newItem);

    this.newItem = {name: '', items: []};
    this.newItem.name = 'Basic Settings';
    this.newItem.items = [{ filename: 'assets/help/setup.html', subtitle: 'test', html: '' }];
    this.helpItems.push(this.newItem);

    this.newItem = {name: '', items: []};
    this.newItem.name = 'Post Message';
    this.newItem.items = [{ filename: 'assets/help/post_message.html', subtitle: 'test', html: '' }];
    this.helpItems.push(this.newItem);


    for (let i = 0; i < this.helpItems.length; i++) {
      for (let n = 0; n < this.helpItems[i].items.length; n++) {
        if (this.helpItems[i].items[n].filename !== '') {
          this.http.get(this.helpItems[i].items[n].filename, {responseType: 'text'}).subscribe((data) => {
            this.helpItems[i].items[n].html = data;
          });
        }
      }
    }

  }

}
