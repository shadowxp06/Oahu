import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { OmsSlideToggleListComponent } from './oms-slide-toggle-list.component';

describe('OmsSlideToggleListComponent', () => {
  let component: OmsSlideToggleListComponent;
  let fixture: ComponentFixture<OmsSlideToggleListComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ OmsSlideToggleListComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(OmsSlideToggleListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
