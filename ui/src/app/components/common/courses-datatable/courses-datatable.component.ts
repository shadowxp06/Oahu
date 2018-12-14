import {Component, OnInit, Input, ViewChild, OnChanges, SimpleChanges} from '@angular/core';
import {MatPaginator, MatSort, MatTableDataSource} from '@angular/material';
import {SelectionModel} from '@angular/cdk/collections';
import {CourseInterface} from '../../../interfaces/course-interface';
import {APIService} from '../../../services/api/api.service';
import {AlertService} from '../../../services/alert/alert.service';
import {UserService} from '../../../services/user/user.service';
import {UserSettings} from '../../../interfaces/user-settings';
import {ClassListInterface} from '../../../interfaces/class-list';
import {SidebarService} from '../../../services/sidebar/sidebar.service';

@Component({
  selector: 'app-courses-datatable',
  templateUrl: './courses-datatable.component.html',
  styleUrls: ['./courses-datatable.component.css']
})

export class CoursesDatatableComponent implements OnInit, OnChanges {
  @Input() showInactive?: boolean;
  @Input() usePagination?: boolean;
  @Input() showSelect?: boolean;
  @Input() allowHideShow?: boolean;
  @Input() doCourseRefresh?: number;

  @ViewChild(MatPaginator) paginator: MatPaginator;
  @ViewChild(MatSort) sort: MatSort;

  displayedColumns: string[];
  selection = new SelectionModel<CourseInterface>(true, []);
  localDataSource = undefined;
  dataSource: CourseInterface[];

  constructor(private _api: APIService,
              private _alert: AlertService,
              private _user: UserService,
              private _sidebar: SidebarService) {
    this.dataSource = [];
  }

  ngOnInit() {
    if (this.showSelect) {
      if (this.allowHideShow) {
        this.displayedColumns = ['select', 'Name', 'Number', 'active', 'removeFromDB'];
      } else {
        this.displayedColumns = ['select', 'Name', 'Number'];
      }
    } else {
      if (this.allowHideShow) {
        this.displayedColumns = ['Name', 'Number', 'active', 'removeFromDB'];
      } else {
        this.displayedColumns = ['Name', 'Number'];
      }
    }

    this.getCourses();
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes.doCourseRefresh.currentValue > 0) {
      this.getCourses();
    }
  }


  private getCourses() {
    this._api.getUserCourses().subscribe( (data: CourseInterface[]) => {
      if (data) {
        this.dataSource.length = 0;
        this.dataSource = [];
        for (let i = 0; i < data.length; i++) {
          const item = { Name: data[i]['Name'], Number: data[i]['Number'], active: false, ID: data[i]['ID'] };
          this.dataSource.push(item);
        }

        this._user.refreshUserSettings();
        this._user.settings.subscribe( (settings: UserSettings) => {
          if (settings.activeCourses.length === 0) {
            for (let i = 0; i < this.dataSource.length; i++) {
              const courseItem = {id: 0, active: false};
              courseItem.id = this.dataSource[i].ID;
              courseItem.active = true;
              this.dataSource[i].active = true;
              settings.activeCourses.push(courseItem);
            }
          } else {
            for (let n = 0; n < this.dataSource.length; n++) {
              const acItem = settings.activeCourses.filter(course => course.id === this.dataSource[n].ID);
              if (acItem) {
                this.dataSource[n].active = acItem[0].active;
              }
            }
          }

          this._api.getUserCourses().subscribe(((cldata: ClassListInterface[]) => {
            if (cldata) {
              if (cldata['ErrNo'] === undefined) {
                for (let i = 0; i < cldata.length; i++) {
                  if (!this._user.isCourseActive(cldata[i].ID)) {
                    this._sidebar.removeItem(cldata[i]);
                  }
                }
                this._sidebar.updateItems();
              }
            }
          }));
        });



        this.localDataSource = new MatTableDataSource(this.dataSource);
        this.localDataSource.sort = this.sort;

        if (this.usePagination) {
          this.localDataSource.paginator = this.paginator;
        }

        if (this.localDataSource.paginator) {
          this.localDataSource.paginator.firstPage();
        }
      }
    });
  }

  selectedRow(row) {
    this.selection.toggle(row);
  }

  removeFromDB(id) {
    if (id > 0) {
      const dsItem = this.dataSource.filter(course => (course.ID === id));
      if (dsItem[0] && dsItem[0].ID > 0) {
        this.dataSource[this.dataSource.indexOf(dsItem[0])].active = false;
        this._user.removeActiveCourse(dsItem[0].ID);
      }
    }
  }

  addToDB(id) {
    if (id > 0) {
      const dsItem = this.dataSource.filter(course => (course.ID === id));
      if (dsItem[0] && dsItem[0].ID > 0) {
        this.dataSource[this.dataSource.indexOf(dsItem[0])].active = true;
        this._user.addActiveCourse(dsItem[0].ID);
      }
    }
  }

  /* Code taken from Google example - https://stackblitz.com/angular/mdbbjlmbdnk?file=app%2Ftable-selection-example.ts */
  isAllSelected() {
    const numSelected = this.selection.selected.length;
    const numRows = this.localDataSource.data.length;
    return numSelected === numRows;
  }

  masterToggle() {
    this.isAllSelected() ?
      this.selection.clear() :
      this.localDataSource.data.forEach(row => this.selection.select(row));

  }
  /* End of code */
}
