import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { FilterMessageDatatableComponent } from './filter-message-datatable.component';

describe('FilterMessageDatatableComponent', () => {
  let component: FilterMessageDatatableComponent;
  let fixture: ComponentFixture<FilterMessageDatatableComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ FilterMessageDatatableComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(FilterMessageDatatableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
