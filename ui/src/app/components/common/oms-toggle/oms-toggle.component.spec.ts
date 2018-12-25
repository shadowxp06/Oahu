import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { OmsToggleComponent } from './oms-toggle.component';

describe('OmsToggleComponent', () => {
  let component: OmsToggleComponent;
  let fixture: ComponentFixture<OmsToggleComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ OmsToggleComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(OmsToggleComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
