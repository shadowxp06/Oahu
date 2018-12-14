import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { OmsNumberComponent } from './oms-number.component';

describe('OmsNumberComponent', () => {
  let component: OmsNumberComponent;
  let fixture: ComponentFixture<OmsNumberComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ OmsNumberComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(OmsNumberComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
