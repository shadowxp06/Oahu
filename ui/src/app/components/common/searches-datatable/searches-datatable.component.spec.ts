import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { SearchesDatatableComponent } from './searches-datatable.component';

describe('SearchesDatatableComponent', () => {
  let component: SearchesDatatableComponent;
  let fixture: ComponentFixture<SearchesDatatableComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ SearchesDatatableComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(SearchesDatatableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
