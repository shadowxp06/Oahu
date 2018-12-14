import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { DraftsDatatableComponent } from './drafts-datatable.component';

describe('DraftsDatatableComponent', () => {
  let component: DraftsDatatableComponent;
  let fixture: ComponentFixture<DraftsDatatableComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ DraftsDatatableComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(DraftsDatatableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
