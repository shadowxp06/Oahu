import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CourseSettingsParticipationComponent } from './course-settings-participation.component';

describe('CourseSettingsParticipationComponent', () => {
  let component: CourseSettingsParticipationComponent;
  let fixture: ComponentFixture<CourseSettingsParticipationComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CourseSettingsParticipationComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CourseSettingsParticipationComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
