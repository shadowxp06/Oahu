/* This component is based off of the code found at https://stackblitz.com/angular/kmpgvvjondp?file=app%2Fchips-autocomplete-example.ts */
import {Component, EventEmitter, Input, OnInit, Output, OnChanges, SimpleChanges, ViewChild, ElementRef, ChangeDetectorRef} from '@angular/core';
import {APIService} from '../../../services/api/api.service';
import {User} from '../../../interfaces/user';
import {FormControl, FormGroup} from '@angular/forms';
import {Observable} from 'rxjs';
import {map, startWith} from 'rxjs/operators';
import {UserFilterType} from '../../../enums/user-filter-type.enum';
import {MatAutocompleteSelectedEvent, MatChipInputEvent, MatAutocomplete} from '@angular/material';
import {COMMA, ENTER} from '@angular/cdk/keycodes';
import {Groups} from '../../../interfaces/groups';
import {UserLookupType} from '../../../enums/user-lookup-type.enum';

@Component({
  selector: 'app-oms-user-lookup',
  templateUrl: './oms-user-lookup.component.html',
  styleUrls: ['./oms-user-lookup.component.css']
})
export class OmsUserLookupComponent implements OnInit, OnChanges {
  _users: User[] = [];
  selectedUsers: User[] = [];

  filteredUsers: Observable<User[]>;
  userCtrl = new FormControl();

  separatorKeysCodes: number[] = [ENTER, COMMA];

  @Input() classId: number;
  @Input() formGroup: FormGroup;
  @Input() filterTo?: UserFilterType;
  @Input() placeholder: string;
  @Input() required?: boolean;
  @Input() type: UserLookupType;
  @Output() outputData = new EventEmitter();

  usrFilterType = UserFilterType;
  usrLookupType = UserLookupType;

  @ViewChild('userInput') userInput: ElementRef<HTMLInputElement>;
  @ViewChild('auto') matAutocomplete: MatAutocomplete;

  constructor(private _api: APIService) {

  }

  ngOnInit() {
    if (this.classId > 0) {
      this.doLookup();
    }
  }

  ngOnChanges(changes: SimpleChanges) {
    if (changes.classId.currentValue > 0) {
      this.classId = changes.classId.currentValue;
      this.doLookup();
    }
  }

  private _filterUsers(value: number): User[] {
    const filterValue = value;

    return this._users.filter(user => (user.ID === filterValue));
  }

  private doLookup() {
    if (this.type === this.usrLookupType.user) {
      this._api.getUsersInCourse(this.classId).subscribe(((data: User[]) => {
        this._users = [];
        for (let i = 0; i < data.length; i++) {
          data[i].IsGroup = false;
          if (this.filterTo === undefined || this.filterTo === this.usrFilterType.all) {
            this._users.push(data[i]);
          } else if (this.filterTo === this.usrFilterType.instructors) {
            if (data[i].UserLevel === 'Instructor') {
              this._users.push(data[i]);
            }
          } else if (this.filterTo === this.usrFilterType.students) {
            if (data[i].UserLevel === 'Student') {
              this._users.push(data[i]);
            }
          } else if (this.filterTo === this.usrFilterType.ta) {
            if (data[i].UserLevel === 'Teaching Assistant') {
              this._users.push(data[i]);
            }
          }
        }



        this.filteredUsers = this.userCtrl.valueChanges.pipe(
          startWith(''),
          map(user => user ? this._filterUsers(user) : this._users.slice()));
      }));
    } else {
      this._api.getCourseGroups(this.classId).subscribe(((groups: Groups[]) => {
        if (groups) {
          for (let n = 0; n < groups.length; n++) {
            const item = {ID: 0, IsGroup: true, GroupName: '', FirstName: ''};
            item.ID = groups[n].ID;
            item.GroupName = groups[n].GroupName;
            item.FirstName = groups[n].GroupName;

            this._users.push(item);
          }


          this.filteredUsers = this.userCtrl.valueChanges.pipe(
            startWith(''),
            map(user => user ? this._filterUsers(user) : this._users.slice()));
        }
      }));
    }
  }

  remove(item) {
    const index = this.selectedUsers.indexOf(item);
    if (index >= 0) {
      this.selectedUsers.splice(index, 1);
    }
    this.emit();
  }


  selected(event: MatAutocompleteSelectedEvent): void {
    const arr = event.option.viewValue.split(' ');

    this.selectedUsers.push(this._users.filter(x => x.FirstName === arr[0])[0]);
     this.userInput.nativeElement.value = '';
     this.userCtrl.setValue(null);
     this.emit();
  }

  emit() {
     this.outputData.emit(this.selectedUsers);
  }

}
