import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CourseSettingsBasicComponent } from './course-settings-basic.component';

describe('CourseSettingsBasicComponent', () => {
  let component: CourseSettingsBasicComponent;
  let fixture: ComponentFixture<CourseSettingsBasicComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CourseSettingsBasicComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CourseSettingsBasicComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
