import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CourseSettingsEnrollmentComponent } from './course-settings-enrollment.component';

describe('CourseSettingsEnrollmentComponent', () => {
  let component: CourseSettingsEnrollmentComponent;
  let fixture: ComponentFixture<CourseSettingsEnrollmentComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CourseSettingsEnrollmentComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CourseSettingsEnrollmentComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
