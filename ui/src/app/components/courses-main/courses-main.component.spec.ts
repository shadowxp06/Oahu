import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CoursesMainComponent } from './courses-main.component';

describe('CoursesMainComponent', () => {
  let component: CoursesMainComponent;
  let fixture: ComponentFixture<CoursesMainComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CoursesMainComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CoursesMainComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
