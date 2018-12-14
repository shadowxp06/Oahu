import { TestBed, inject } from '@angular/core/testing';

import { AuthSystemService } from './auth-system.service';

describe('AuthSystemService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [AuthSystemService]
    });
  });

  it('should be created', inject([AuthSystemService], (service: AuthSystemService) => {
    expect(service).toBeTruthy();
  }));
});
