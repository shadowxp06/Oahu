import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { GroupAddModalComponent } from './group-add-modal.component';

describe('GroupAddModalComponent', () => {
  let component: GroupAddModalComponent;
  let fixture: ComponentFixture<GroupAddModalComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ GroupAddModalComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(GroupAddModalComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
