import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { OmsDaterangeComponent } from './oms-daterange.component';

describe('OmsDaterangeComponent', () => {
  let component: OmsDaterangeComponent;
  let fixture: ComponentFixture<OmsDaterangeComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ OmsDaterangeComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(OmsDaterangeComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
