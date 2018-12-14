import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CourseSettingsQaComponent } from './course-settings-qa.component';

describe('CourseSettingsQaComponent', () => {
  let component: CourseSettingsQaComponent;
  let fixture: ComponentFixture<CourseSettingsQaComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CourseSettingsQaComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CourseSettingsQaComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
