import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CoursesDatatableComponent } from './courses-datatable.component';

describe('CoursesDatatableComponent', () => {
  let component: CoursesDatatableComponent;
  let fixture: ComponentFixture<CoursesDatatableComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CoursesDatatableComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CoursesDatatableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
