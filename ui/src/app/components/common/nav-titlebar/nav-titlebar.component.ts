import { Component, OnInit } from '@angular/core';
import {SidebarService} from '../../../services/sidebar/sidebar.service';
import {AuthSystemService} from '../../../services/auth-system/auth-system.service';
import {Router} from '@angular/router';

@Component({
  selector: 'app-nav-titlebar',
  templateUrl: './nav-titlebar.component.html',
  styleUrls: ['./nav-titlebar.component.css']
})
export class NavTitlebarComponent implements OnInit {
  title = 'Oahu';
  isLoginPage = false;

  constructor(private _sidebarService: SidebarService,
              public authService: AuthSystemService,
              private _router: Router) { }

  ngOnInit() {
  }

  setSideBarVar() {
    this._sidebarService.toggleSidebarVisibility();
  }

  goToDashboard() {
    this._sidebarService.setSidebarVisibility(false);
    this._router.navigate(['/dashboard']);
  }
}
