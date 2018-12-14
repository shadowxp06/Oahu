import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CourseEnrollmentDialogComponent } from './course-enrollment-dialog.component';

describe('CourseEnrollmentDialogComponent', () => {
  let component: CourseEnrollmentDialogComponent;
  let fixture: ComponentFixture<CourseEnrollmentDialogComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CourseEnrollmentDialogComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CourseEnrollmentDialogComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
