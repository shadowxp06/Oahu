import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { NavTitlebarComponent } from './nav-titlebar.component';

describe('NavTitlebarComponent', () => {
  let component: NavTitlebarComponent;
  let fixture: ComponentFixture<NavTitlebarComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ NavTitlebarComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(NavTitlebarComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
