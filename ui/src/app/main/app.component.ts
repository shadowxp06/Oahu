import {Component, OnInit, OnDestroy, ChangeDetectorRef} from '@angular/core';
import {BreakpointObserver, MediaMatcher} from '@angular/cdk/layout';
import { AuthSystemService } from '../services/auth-system/auth-system.service';
import { Router } from '@angular/router';
import {Breakpoints, BreakpointState} from '@angular/cdk/layout';
import {AlertService} from '../services/alert/alert.service';
import {Subscription} from 'rxjs';
import {UserService} from '../services/user/user.service';
import {SidebarService} from '../services/sidebar/sidebar.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})

export class AppComponent implements OnInit, OnDestroy {
  showSideBar = false;
  showNavBar = false;
  isHandset = false;

  private _mobileQueryListener: () => void;
  mobileQuery: MediaQueryList;
  sbSubscription: Subscription;

  constructor(private _breakpointObserver: BreakpointObserver,
              public authService: AuthSystemService,
              public router: Router,
              public alert: AlertService,
              private changeDetectorRef: ChangeDetectorRef,
              media: MediaMatcher,
              private _sidebarService: SidebarService) {

    this.mobileQuery = media.matchMedia('(max-width: 600px)');
    this._mobileQueryListener = () => changeDetectorRef.detectChanges();
    this.mobileQuery.addListener(this._mobileQueryListener);
  }

  ngOnDestroy() {
    if (!!this.sbSubscription) {
      this.sbSubscription.unsubscribe();
    }
  }

  ngOnInit() {
    this.showNavBar = this.authService.isLoggedIn;

    this.sbSubscription = this._sidebarService.isVisible.subscribe((value: boolean) => {
      this.showSideBar = value;
    });

    this._breakpointObserver.observe(Breakpoints.Handset).subscribe((state: BreakpointState) => {
      if (state.matches) {
        this.isHandset = true;
      } else {
        this.isHandset = false;
      }
    });
  }

}
