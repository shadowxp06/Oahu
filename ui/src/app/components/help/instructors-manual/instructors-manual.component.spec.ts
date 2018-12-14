import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { InstructorsManualComponent } from './instructors-manual.component';

describe('InstructorsManualComponent', () => {
  let component: InstructorsManualComponent;
  let fixture: ComponentFixture<InstructorsManualComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ InstructorsManualComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(InstructorsManualComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
