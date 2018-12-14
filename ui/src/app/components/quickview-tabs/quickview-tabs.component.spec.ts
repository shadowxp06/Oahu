import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { QuickviewTabsComponent } from './quickview-tabs.component';

describe('QuickviewTabsComponent', () => {
  let component: QuickviewTabsComponent;
  let fixture: ComponentFixture<QuickviewTabsComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ QuickviewTabsComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(QuickviewTabsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
