import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { AclDatatableComponent } from './acl-datatable.component';

describe('AclDatatableComponent', () => {
  let component: AclDatatableComponent;
  let fixture: ComponentFixture<AclDatatableComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ AclDatatableComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(AclDatatableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
