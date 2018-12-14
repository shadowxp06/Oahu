import {Component, OnDestroy, OnInit} from '@angular/core';
import {BreakpointObserver, Breakpoints, BreakpointState} from '@angular/cdk/layout';


@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit, OnDestroy {
  gridlistCols = 3;
  showSideBar = false;


  constructor(private breakpointObserver: BreakpointObserver) {

  }

  ngOnInit() {

    this.breakpointObserver.observe(Breakpoints.Handset).subscribe((state: BreakpointState) => {
      if (state.matches) {
        this.gridlistCols = 1;
      } else {
        this.gridlistCols = 3;
      }
    });

  }

  ngOnDestroy(): void {

  }

}
