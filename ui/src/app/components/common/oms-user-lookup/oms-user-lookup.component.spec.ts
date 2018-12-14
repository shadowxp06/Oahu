import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { OmsUserLookupComponent } from './oms-user-lookup.component';

describe('OmsUserLookupComponent', () => {
  let component: OmsUserLookupComponent;
  let fixture: ComponentFixture<OmsUserLookupComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ OmsUserLookupComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(OmsUserLookupComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
