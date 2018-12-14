import { Component, OnInit } from '@angular/core';
import {HelpSection} from '../../../interfaces/help-section';
import {HttpClient} from '@angular/common/http';

@Component({
  selector: 'app-instructors-manual',
  templateUrl: './instructors-manual.component.html',
  styleUrls: ['./instructors-manual.component.css']
})
export class InstructorsManualComponent implements OnInit {

  helpItems: HelpSection[] = [];
  newItem: HelpSection = {
    name: '',
    items: []
  };

  constructor(private http: HttpClient) { }

  ngOnInit() {

    this.newItem = {name: '', items: []};
    this.newItem.name = 'Setting Up a Course';
    this.newItem.items = [{ filename: 'assets/help/instructor_course_setup.html', subtitle: 'test', html: '' }];
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
