import {ChangeDetectorRef, Component, OnDestroy, OnInit} from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { SidebarService } from '../../services/sidebar/sidebar.service';
import {UserService} from '../../services/user/user.service';
import {MediaMatcher} from '@angular/cdk/layout';

@Component({
  selector: 'app-createpost',
  templateUrl: './createpost.component.html',
  styleUrls: ['./createpost.component.css']
})
export class CreatepostComponent implements OnInit, OnDestroy {
  showSideBar = false;
  classId = 0;


  private _mobileQueryListener: () => void;
  mobileQuery: MediaQueryList;


  constructor(private _activatedRoute: ActivatedRoute,
              private sidebarService: SidebarService,
              private changeDetectorRef: ChangeDetectorRef,
              media: MediaMatcher) {
    this.mobileQuery = media.matchMedia('(max-width: 600px)');
    this._mobileQueryListener = () => changeDetectorRef.detectChanges();
    this.mobileQuery.addListener(this._mobileQueryListener);
    this.showSideBar = sidebarService.isSidebarVisible;

    if (_activatedRoute.snapshot.params) {
      if (_activatedRoute.snapshot.params['id'] > 0) {
        this.classId = this._activatedRoute.snapshot.params['id'];
      }
    }
  }

  ngOnInit() {

  }

  ngOnDestroy(): void {
    this.mobileQuery.removeListener(this._mobileQueryListener);
  }

}
