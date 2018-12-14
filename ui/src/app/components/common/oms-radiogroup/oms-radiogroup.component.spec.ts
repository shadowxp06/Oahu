import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { OmsRadiogroupComponent } from './oms-radiogroup.component';

describe('OmsRadiogroupComponent', () => {
  let component: OmsRadiogroupComponent;
  let fixture: ComponentFixture<OmsRadiogroupComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ OmsRadiogroupComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(OmsRadiogroupComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
