import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { MessagesDatatableComponent } from './messages-datatable.component';

describe('MessagesDatatableComponent', () => {
  let component: MessagesDatatableComponent;
  let fixture: ComponentFixture<MessagesDatatableComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ MessagesDatatableComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(MessagesDatatableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
