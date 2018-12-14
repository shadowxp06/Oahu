import { Routes, RouterModule } from '@angular/router';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { LoginFormComponent } from './components/login-form/login-form.component';
import { AuthGuard } from './guards/auth/auth.guard';
import { SettingsComponent } from './components/settings/settings.component';
import { CourseSettingsComponent } from './components/course-settings/course-settings.component';
import { HelpComponent } from './components/help/help.component';
import { MessagePageComponent } from './components/message-page/message-page.component';
import { CreatepostComponent } from './components/createpost/createpost.component';
import { FavoritesComponent } from './components/favorites/favorites.component';
import { DraftsComponent } from './components/drafts/drafts.component';
import { ErrorComponent } from './components/error/error.component';
import { LoginLandingComponent } from './components/login-landing/login-landing.component';
import { EditpostComponent} from './components/editpost/editpost.component';
import {CreatePostWizardComponent} from './components/create-post-wizard/create-post-wizard.component';
import {UserRegistrationComponent} from './components/user-registration/user-registration.component';
import {UserActivationComponent} from './components/user-activation/user-activation.component';
import {AnnouncementsComponent} from './components/announcements/announcements.component';
import {UnreadComponent} from './components/unread/unread.component';
import {SearchComponent} from './components/search/search.component';
import {InstructorsManualComponent} from './components/help/instructors-manual/instructors-manual.component';
import {UserManualComponent} from './components/help/user-manual/user-manual.component';

const appRoutes: Routes = [
  { path: '', component: LoginLandingComponent },
  { path: 'login', component: LoginFormComponent },
  { path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuard]},
  { path: 'dashboard/:id', component: DashboardComponent, canActivate: [AuthGuard]},
  { path: 'settings', component: SettingsComponent, canActivate: [AuthGuard]},
  { path: 'help', component: HelpComponent },
  { path: 'help/instructors', component: InstructorsManualComponent },
  { path: 'help/users', component: UserManualComponent },
  { path: 'coursesettings', component: ErrorComponent, canActivate: [AuthGuard] },
  { path: 'coursesettings/:id', component: CourseSettingsComponent, canActivate: [AuthGuard]},
  { path: 'createpost', component: CreatepostComponent, canActivate: [AuthGuard] },
  { path: 'createpost/:id', component: CreatepostComponent, canActivate: [AuthGuard] },
  { path: 'favorites', component: FavoritesComponent, canActivate: [AuthGuard] },
  { path: 'drafts', component: DraftsComponent, canActivate: [AuthGuard] },
  { path: 'editpost', component: ErrorComponent, canActivate: [AuthGuard] },
  { path: 'editpost/:id', component: EditpostComponent, canActivate: [AuthGuard] },
  { path: 'message/:id', component: MessagePageComponent, canActivate: [AuthGuard] },
  { path: 'message', component: ErrorComponent, canActivate: [AuthGuard] },
  { path: 'createreply/:id', component: MessagePageComponent, canActivate: [AuthGuard] },
  { path: 'createpostwizard', component: CreatePostWizardComponent, canActivate: [AuthGuard]},
  { path: 'registration', component: UserRegistrationComponent },
  { path: 'activation', component: UserActivationComponent },
  { path: 'announcements', component: AnnouncementsComponent, canActivate: [AuthGuard] },
  { path: 'unread', component: UnreadComponent, canActivate: [AuthGuard] },
  { path: 'search', component: SearchComponent, canActivateChild: [AuthGuard] },
  { path: '**', redirectTo: ''}
];

export const routing = RouterModule.forRoot(appRoutes);
