import {ChangeDetectorRef, Component, OnDestroy, OnInit} from '@angular/core';
import {MessageType} from '../../enums/message-type.enum';
import {SidebarService} from '../../services/sidebar/sidebar.service';
import {UserService} from '../../services/user/user.service';
import {MediaMatcher} from '@angular/cdk/layout';
import {Observable, Subscription} from 'rxjs';

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
