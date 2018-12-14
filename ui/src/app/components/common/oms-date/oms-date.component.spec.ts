import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { OmsDateComponent } from './oms-date.component';

describe('OmsDateComponent', () => {
  let component: OmsDateComponent;
  let fixture: ComponentFixture<OmsDateComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ OmsDateComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(OmsDateComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
