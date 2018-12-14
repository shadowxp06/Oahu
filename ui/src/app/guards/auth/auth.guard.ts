import { Inject, Injectable } from '@angular/core';
import { Router, CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import { Observable } from 'rxjs';
import { AuthSystemService } from '../../services/auth-system/auth-system.service';
import { DOCUMENT} from '@angular/common';
import { environment } from '../../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {
  constructor(private authSystem: AuthSystemService, private router: Router, @Inject(DOCUMENT) private document: any) { }
  canActivate(
    next: ActivatedRouteSnapshot,
    state: RouterStateSnapshot): Observable<boolean> | Promise<boolean> | boolean {
    if (this.authSystem.isLoggedIn) {
      return true;
    } else {
      this.router.navigate(['login']);
      return false;
    }
  }
}
