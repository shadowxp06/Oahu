import {Component, OnInit, Input, OnChanges, SimpleChanges, OnDestroy, ViewChild, ChangeDetectorRef} from '@angular/core';
import {SearchService} from '../../../services/search/search.service';
import {SearchType} from '../../../enums/search-type.enum';
import {APIService} from '../../../services/api/api.service';
import {MessageType} from '../../../enums/message-type.enum';
import {ActivatedRoute} from '@angular/router';
import {animate, state, style, transition, trigger} from '@angular/animations';
import {faEdit, faStickyNote, faTrashAlt, faHeart, faStar, faBullhorn, faQuestionCircle, faPoll} from '@fortawesome/free-solid-svg-icons';
import {MatPaginator, MatTableDataSource} from '@angular/material';
import {AuthSystemService} from '../../../services/auth-system/auth-system.service';
import {CourseMessageListDashboardInterface} from '../../../interfaces/course-message-list-dashboard';
import {AlertService} from '../../../services/alert/alert.service';
import {Subscription} from 'rxjs';
import {Setting} from '../../../interfaces/setting';
import {SettingLayer} from '../../../enums/setting-layer.enum';
import {SettingVisibility} from '../../../enums/setting-visibility.enum';
import {SearchInterface} from '../../../interfaces/search-interface';

@Component({
  selector: 'app-searches-datatable',
  templateUrl: './searches-datatable.component.html',
  styleUrls: ['./searches-datatable.component.css'],
  animations: [
    trigger('detailExpand', [
      state('collapsed', style({height: '0px', minHeight: '0', display: 'none'})),
      state('expanded', style({height: '*'})),
      transition('expanded <=> collapsed', animate('225ms cubic-bezier(0.4, 0.0, 0.2, 1)')),
    ]),
  ]
})
export class SearchesDatatableComponent implements OnInit, OnChanges, OnDestroy {
  @Input() type: SearchType;
  @Input() messages?: any[] = [];

  @ViewChild(MatPaginator) paginator: MatPaginator;

  userId = 0;

  mType = MessageType;
  sType = SearchType;

  /* Column Setup */
  resultscolumns = ['type', 'course', 'title', 'quickactions'];
  recentcolumns = ['search', 'actions'];
  savedcolumns = ['search', 'actions'];


  /* Datasources */
  resultsExpandedDS: CourseMessageListDashboardInterface;
  resultsDS: MatTableDataSource<CourseMessageListDashboardInterface>;
  recentDS: MatTableDataSource<SearchInterface>;
  savedDS: MatTableDataSource<SearchInterface>;

  /* Data */
  resultsData: CourseMessageListDashboardInterface[] = [];
  recentData: SearchInterface[] = [];
  savedData: SearchInterface[] = [];

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

  constructor(private _search: SearchService,
              private _api: APIService,
              private _alert: AlertService,
              private _auth: AuthSystemService,
              private _activatedRoute: ActivatedRoute,
              private _detectorChange: ChangeDetectorRef) { }

  ngOnInit() {
    this.userId = this._auth.userId;

    if (this.type === this.sType.savedSearch) {
      this.savedDS = new MatTableDataSource<SearchInterface>(this.savedData);
      this.savedDS.paginator = this.paginator;
    } else if (this.type === this.sType.recent) {
      this.recentDS = new MatTableDataSource<SearchInterface>(this.recentData);
      this.recentDS.paginator = this.paginator;
    }
  }

  ngOnDestroy(): void {
    if (this._messagesSubscription) {
      this._messagesSubscription.unsubscribe();
    }
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes.messages) {
      if (this.type === this.sType.results) {
        this.resultsDS = new MatTableDataSource<CourseMessageListDashboardInterface>(this.messages);
        this.resultsDS.paginator = this.paginator;
      } else if (this.type === this.sType.savedSearch) {
        this.savedData = this.messages;
        this.savedDS = new MatTableDataSource<SearchInterface>(this.savedData);
        this.savedDS.paginator = this.paginator;
        this._detectorChange.markForCheck();
        this._detectorChange.detectChanges();
      } else if (this.type === this.sType.recent) {
        this.recentData = this.messages;
        this.recentDS = new MatTableDataSource<SearchInterface>(this.recentData);
        this.recentDS.paginator = this.paginator;
      } else {
        // Do Nothing
      }
    }
  }

  addFavorite(id: number) {
    const setting: Setting = { Name: '', Value: '', Rank: 0, Type: 0, Permission: SettingLayer.user, Visibility: SettingVisibility.user, UserID: this._auth.userId };
    const favorite = id;

    setting.Name = 'favorites';
    setting.Value = favorite;

    this._api.addFavorite(setting).subscribe((data => {
      if (data) {
        if (data.body['ErrNo'] === '0') {
          this._alert.showSuccessAlert('Added to Favorites');
        } else {
          this._alert.showErrorAlert(data.body['Description']);
        }
      }
    }));
  }

}
