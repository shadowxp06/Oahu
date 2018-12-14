import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { OmsSimpleInputComponent } from './oms-simple-input.component';

describe('OmsSimpleInputComponent', () => {
  let component: OmsSimpleInputComponent;
  let fixture: ComponentFixture<OmsSimpleInputComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ OmsSimpleInputComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(OmsSimpleInputComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
