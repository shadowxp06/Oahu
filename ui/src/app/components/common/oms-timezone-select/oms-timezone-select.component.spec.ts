import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { OmsTimezoneSelectComponent } from './oms-timezone-select.component';

describe('OmsTimezoneSelectComponent', () => {
  let component: OmsTimezoneSelectComponent;
  let fixture: ComponentFixture<OmsTimezoneSelectComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ OmsTimezoneSelectComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(OmsTimezoneSelectComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
