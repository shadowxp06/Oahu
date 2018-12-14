import {ChangeDetectorRef, Component, OnDestroy, OnInit} from '@angular/core';
import {MessageType} from '../../enums/message-type.enum';
import {SidebarService} from '../../services/sidebar/sidebar.service';
import {UserService} from '../../services/user/user.service';
import {MediaMatcher} from '@angular/cdk/layout';

@Component({
  selector: 'app-unread',
  templateUrl: './unread.component.html',
  styleUrls: ['./unread.component.css']
})
export class UnreadComponent implements OnInit, OnDestroy {
  showSideBar = false;
  mType = MessageType;


  constructor() {
  }

  ngOnInit() {

  }

  ngOnDestroy(): void {
  }

}
