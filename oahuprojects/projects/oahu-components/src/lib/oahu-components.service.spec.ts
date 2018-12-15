import { TestBed } from '@angular/core/testing';

import { OahuComponentsService } from './oahu-components.service';

describe('OahuComponentsService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: OahuComponentsService = TestBed.get(OahuComponentsService);
    expect(service).toBeTruthy();
  });
});
