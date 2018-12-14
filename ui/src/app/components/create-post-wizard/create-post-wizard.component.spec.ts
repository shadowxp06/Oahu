import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CreatePostWizardComponent } from './create-post-wizard.component';

describe('CreatePostWizardComponent', () => {
  let component: CreatePostWizardComponent;
  let fixture: ComponentFixture<CreatePostWizardComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CreatePostWizardComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CreatePostWizardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
