import {Component, OnInit} from '@angular/core';
import {MessageType} from '../../enums/message-type.enum';

@Component({
  selector: 'app-announcements',
  templateUrl: './announcements.component.html',
  styleUrls: ['./announcements.component.css']
})
export class AnnouncementsComponent implements OnInit {
  mType = MessageType;


  constructor() {
  }

  ngOnInit() {

  }


}
