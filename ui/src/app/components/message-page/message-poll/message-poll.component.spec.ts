import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { MessagePollComponent } from './message-poll.component';

describe('MessagePollComponent', () => {
  let component: MessagePollComponent;
  let fixture: ComponentFixture<MessagePollComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ MessagePollComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(MessagePollComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
