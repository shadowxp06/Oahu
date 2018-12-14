import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { SettingsCoursesComponent } from './settings-courses.component';

describe('SettingsCoursesComponent', () => {
  let component: SettingsCoursesComponent;
  let fixture: ComponentFixture<SettingsCoursesComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ SettingsCoursesComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(SettingsCoursesComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
