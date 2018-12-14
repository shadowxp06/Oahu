import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { OmsListComponent } from './oms-list.component';

describe('OmsListComponent', () => {
  let component: OmsListComponent;
  let fixture: ComponentFixture<OmsListComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ OmsListComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(OmsListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
