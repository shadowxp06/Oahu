import { Component, OnInit, ViewChild } from '@angular/core';
import {MatPaginator, MatTableDataSource} from '@angular/material';
import { Draftsinterface } from '../../../interfaces/draftsinterface';
import { faTrashAlt, faEdit } from '@fortawesome/free-solid-svg-icons';
import {UserService} from '../../../services/user/user.service';
import {AuthSystemService} from '../../../services/auth-system/auth-system.service';

const Demodata: Draftsinterface[] = [
  {messageId: 1, title: 'This is a draft announcement', lastupdated: '08/01/2018', authorid: 1, coauthors: [{ authorId: 2}]}
];

@Component({
  selector: 'app-drafts-datatable',
  templateUrl: './drafts-datatable.component.html',
  styleUrls: ['./drafts-datatable.component.css']
})
export class DraftsDatatableComponent implements OnInit {
  displayedColumns: string[] = ['title', 'lastupdated', 'quickactions'];

  @ViewChild(MatPaginator) paginator: MatPaginator;

  dataSource = new MatTableDataSource<Draftsinterface>(Demodata);

  faEdit = faEdit;
  faTrashAlt = faTrashAlt;

  userId = 0;
  constructor(private _user: UserService,
              private _auth: AuthSystemService) { }

  ngOnInit() {
    this.dataSource.paginator = this.paginator;
    this.userId = this._auth.userId;
  }

}
