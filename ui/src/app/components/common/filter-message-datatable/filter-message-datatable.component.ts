import {Component, Input, OnDestroy, OnInit, ViewChild} from '@angular/core';
import {animate, state, style, transition, trigger} from '@angular/animations';
import {faEdit, faStickyNote, faTrashAlt, faHeart, faStar, faBullhorn, faQuestionCircle, faPoll} from '@fortawesome/free-solid-svg-icons';
import {MatPaginator, MatTableDataSource} from '@angular/material';
import {AuthSystemService} from '../../../services/auth-system/auth-system.service';
import {APIService} from '../../../services/api/api.service';
import {Subscription} from 'rxjs';
import {FilterLookup} from '../../../interfaces/filter-lookup';
import {Post} from '../../../interfaces/post';
import {MessageType} from '../../../enums/message-type.enum';
import {CourseMessageListDashboardInterface} from '../../../interfaces/course-message-list-dashboard';
import {SidebarService} from '../../../services/sidebar/sidebar.service';

@Component({
  selector: 'app-filter-message-datatable',
  templateUrl: './filter-message-datatable.component.html',
  styleUrls: ['./filter-message-datatable.component.css'],
  animations: [
    trigger('detailExpand', [
      state('collapsed', style({height: '0px', minHeight: '0', display: 'none'})),
      state('expanded', style({height: '*'})),
      transition('expanded <=> collapsed', animate('225ms cubic-bezier(0.4, 0.0, 0.2, 1)')),
    ]),
  ]
})
export class FilterMessageDatatableComponent implements OnInit, OnDestroy {
  @Input() filterName: string;

  @ViewChild(MatPaginator) paginator: MatPaginator;

  userId = 0;

  item: FilterLookup;
  mType = MessageType;
  resultsDS: MatTableDataSource<CourseMessageListDashboardInterface>;
  resultsExpandedDS: CourseMessageListDashboardInterface;
  resultsData: CourseMessageListDashboardInterface[] = [];

  resultscolumns = ['type', 'course', 'title', 'quickactions'];

  /* FA Icons */
  faNote = faStickyNote;
  faEdit = faEdit;
  faDelete = faTrashAlt;
  faFavorite = faStar;
  faAnnouncement = faBullhorn;
  faQuestion = faQuestionCircle;
  faPoll = faPoll;

  /* Subscriptions */
  _messagesSubscription: Subscription;

  constructor(private _auth: AuthSystemService,
              private _api: APIService,
              private _sidebar: SidebarService) { }

  ngOnInit() {
    this.userId = this._auth.userId;

    if (this.userId > 0 && this.filterName !== '') {
      this.item = {
        userId: this.userId,
        name: this.filterName
      };

      this._messagesSubscription = this._api.getFilter(this.item).subscribe(((data: Post[]) => {
        for (let i = 0; i < data.length; i++) {
          const CMItem = {
            messageId: 0,
            title: '',
            author: '',
            authorId: 0,
            lastUpdate: '',
            type: MessageType.all,
            message: '',
            selected: false,
            courseId: 0,
            courseName: ''
          };

          CMItem.messageId  = data[i].ID;
          CMItem.courseId = data[i].CourseID;
          CMItem.title = data[i].Title;
          CMItem.message = data[i].Message;
          CMItem.author = data[i].FirstName + ' ' + data[i].LastName;
          CMItem.authorId = data[i].UserID;
          CMItem.lastUpdate = data[i].TimeCreated;
          CMItem.type = data[i].Type;
          CMItem.courseName = this._sidebar.getCourseName(CMItem.courseId);

          this.resultsData.push(CMItem);
        }

        this.resultsDS = new MatTableDataSource<CourseMessageListDashboardInterface>(this.resultsData);
        this.resultsDS.paginator = this.paginator;
      }));
    }
  }

  ngOnDestroy(): void {
    if (this._messagesSubscription) {
      this._messagesSubscription.unsubscribe();
    }
  }
}
