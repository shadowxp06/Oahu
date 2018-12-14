import { Component, OnInit } from '@angular/core';
import { faSignOutAlt, faQuestion, faCog } from '@fortawesome/free-solid-svg-icons';
import { Router} from '@angular/router';
import { NavigationBarStep } from '../../../enums/navigation-bar-step.enum';
import { AuthSystemService } from '../../../services/auth-system/auth-system.service';

@Component({
  selector: 'app-navigation-menu',
  templateUrl: './navigation-menu.component.html',
  styleUrls: ['./navigation-menu.component.css']
})
export class NavigationMenuComponent implements OnInit {
  faSignout = faSignOutAlt;
  faQuestion = faQuestion;
  faCog = faCog;

  step = NavigationBarStep;
  constructor(private _router: Router, public authSystem: AuthSystemService) { }

  ngOnInit() {
  }

  goToStep(step: NavigationBarStep) {
    switch (step) {
      case NavigationBarStep.help:
        this._router.navigate(['/help']);
        break;
      case NavigationBarStep.logout:
        this.authSystem.logout();
        this._router.navigate(['/login']);
        break;
      case NavigationBarStep.settings:
        this._router.navigate(['/settings']);
        break;
    }
  }
}
