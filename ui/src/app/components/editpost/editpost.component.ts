import {ChangeDetectorRef, Component, OnDestroy, OnInit} from '@angular/core';
import {ActivatedRoute} from '@angular/router';
import {SidebarService} from '../../services/sidebar/sidebar.service';
import {UserService} from '../../services/user/user.service';
import {MediaMatcher} from '@angular/cdk/layout';

@Component({
  selector: 'app-editpost',
  templateUrl: './editpost.component.html',
  styleUrls: ['./editpost.component.css']
})
export class EditpostComponent implements OnInit, OnDestroy {

  postid = 0;


  private _mobileQueryListener: () => void;
  mobileQuery: MediaQueryList;


  constructor(private _activatedRoute: ActivatedRoute,
              private sidebarService: SidebarService) {


    if (_activatedRoute.snapshot.params) {
      if (_activatedRoute.snapshot.params['id'] > 0) {
        this.postid = this._activatedRoute.snapshot.params['id'];
      }
    }
  }

  ngOnInit() {

  }

  ngOnDestroy(): void {

  }

}
