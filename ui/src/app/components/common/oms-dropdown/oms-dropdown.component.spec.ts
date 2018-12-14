import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { OmsDropdownComponent } from './oms-dropdown.component';

describe('OmsDropdownComponent', () => {
  let component: OmsDropdownComponent;
  let fixture: ComponentFixture<OmsDropdownComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ OmsDropdownComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(OmsDropdownComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
