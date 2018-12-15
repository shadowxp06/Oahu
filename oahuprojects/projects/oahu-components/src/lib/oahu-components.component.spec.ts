import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { OahuComponentsComponent } from './oahu-components.component';

describe('OahuComponentsComponent', () => {
  let component: OahuComponentsComponent;
  let fixture: ComponentFixture<OahuComponentsComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ OahuComponentsComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(OahuComponentsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
