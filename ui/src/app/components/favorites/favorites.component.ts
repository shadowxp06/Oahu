import {ChangeDetectorRef, Component, OnDestroy, OnInit} from '@angular/core';
import { SidebarService } from '../../services/sidebar/sidebar.service';
import {MessageType} from '../../enums/message-type.enum';
import {UserService} from '../../services/user/user.service';
import {MediaMatcher} from '@angular/cdk/layout';

@Component({
  selector: 'app-favorites',
  templateUrl: './favorites.component.html',
  styleUrls: ['./favorites.component.css']
})
export class FavoritesComponent implements OnInit, OnDestroy {
  showSideBar = false;
  mType = MessageType;


  constructor() {

  }

  ngOnInit() {

  }

  ngOnDestroy(): void {

  }


}
