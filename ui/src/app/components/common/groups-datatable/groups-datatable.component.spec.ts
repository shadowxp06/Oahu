import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { GroupsDatatableComponent } from './groups-datatable.component';

describe('GroupsDatatableComponent', () => {
  let component: GroupsDatatableComponent;
  let fixture: ComponentFixture<GroupsDatatableComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ GroupsDatatableComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(GroupsDatatableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
