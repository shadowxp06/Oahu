import { Injectable } from '@angular/core';
import {BehaviorSubject, Subject} from 'rxjs';
import { ClassListInterface } from '../../interfaces/class-list';
import {UserLevels} from '../../enums/user-levels.enum';

@Injectable({
  providedIn: 'root'
})
export class SidebarService {
  /* https://stackoverflow.com/questions/43159090/how-can-i-detect-service-variable-change-when-updated-from-another-component */

  isSidebarVisible: boolean;
  sideBarItems: ClassListInterface[] = [];
  numberOfItems: number;


  private sidebarVisibilityChange: BehaviorSubject<boolean> = new BehaviorSubject(false);

  isVisible = this.sidebarVisibilityChange.asObservable();

  sideBarItemsBS: BehaviorSubject<ClassListInterface[]> = new BehaviorSubject<ClassListInterface[]>(this.sideBarItems);

  constructor()  {
    this.isSidebarVisible = false;
    this.numberOfItems = 0;
  }

  setSidebarVisibility(visible: boolean) {
    this.isSidebarVisible = visible;
    this.sidebarVisibilityChange.next(this.isSidebarVisible);
  }

  toggleSidebarVisibility() {
    this.setSidebarVisibility(!this.isSidebarVisible);
  }

  addItem(item) {
    if (item) {
      this.sideBarItems.push(item);
      this.numberOfItems++;
      this.updateItems();
    }
  }

  updateItems() {
    this.sideBarItemsBS.next(this.sideBarItems);
  }

  clearItems() {
    this.sideBarItems.length = 0;
    this.sideBarItems = [];
    this.updateItems();
  }

  removeItem(itemName) {
    delete this.sideBarItems[itemName];
  }

  classAccessLookup(id): UserLevels { /* I hate removing the type, but in this case it really can be either a String or an Integer */
    if (this.sideBarItems.length === 0) {
      return UserLevels.noAccess;
    }

    for (let i = 0; i < this.sideBarItems.length; i++) {
      if (this.sideBarItems[i].ID === parseInt(id, 0)) {
        return this.sideBarItems[i].UserType;
      }
    }
  }

  getCourseName(id: number): string {
    if (this.sideBarItems.length === 0) {
      return '';
    }

    const myCourse = this.sideBarItems.filter(course => course.ID === id);
    if (myCourse && myCourse.length > 0) {
      return myCourse[0].Name;
    }
  }

}
