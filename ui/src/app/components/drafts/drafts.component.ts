import { Component, OnInit } from '@angular/core';
import { SidebarService } from '../../services/sidebar/sidebar.service';

@Component({
  selector: 'app-drafts',
  templateUrl: './drafts.component.html',
  styleUrls: ['./drafts.component.css']
})
export class DraftsComponent implements OnInit {
  showSideBar = false;

  constructor(private sidebarService: SidebarService) {
    this.showSideBar = sidebarService.isSidebarVisible;
  }

  ngOnInit() {

  }

}
