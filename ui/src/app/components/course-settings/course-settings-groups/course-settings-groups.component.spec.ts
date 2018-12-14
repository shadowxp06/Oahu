import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CourseSettingsGroupsComponent } from './course-settings-groups.component';

describe('CourseSettingsGroupsComponent', () => {
  let component: CourseSettingsGroupsComponent;
  let fixture: ComponentFixture<CourseSettingsGroupsComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CourseSettingsGroupsComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CourseSettingsGroupsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
