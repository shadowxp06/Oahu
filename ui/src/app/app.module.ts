import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { NgbModule} from '@ng-bootstrap/ng-bootstrap';

import { AppComponent } from './main/app.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import {
  MatButtonModule,
  MatToolbarModule,
  MatSidenavModule,
  MatTableModule,
  MatIconModule,
  MatListModule,
  MatTabsModule,
  MatCardModule,
  MatExpansionModule,
  MatFormFieldModule,
  MatInputModule,
  MatSelectModule,
  MatGridListModule,
  MatMenuModule,
  MatCheckboxModule,
  MatBadgeModule,
  MatPaginatorModule,
  MatSortModule,
  MatRadioModule,
  MatDialogModule,
  MatSlideToggleModule,
  MatIconRegistry,
  MatAutocompleteModule,
  MatDatepickerModule,
  MatChipsModule,
  MatStepperModule

} from '@angular/material';
import { LayoutModule } from '@angular/cdk/layout';
import { LoginFormComponent } from './components/login-form/login-form.component';
import { ReactiveFormsModule, FormsModule } from '@angular/forms';
import { AuthSystemService } from './services/auth-system/auth-system.service';
import { AlertService } from './services/alert/alert.service';
import { JwtModule } from '@auth0/angular-jwt';
import {AuthGuard} from './guards/auth/auth.guard';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { HttpClientModule } from '@angular/common/http';
import { routing } from './app.routing';
import { SettingsComponent } from './components/settings/settings.component';
import { HelpComponent } from './components/help/help.component';
import { CourseSettingsComponent } from './components/course-settings/course-settings.component';
import { CoursesMainComponent } from './components/courses-main/courses-main.component';
import { NavigationMenuComponent } from './components/common/navigation-menu/navigation-menu.component';
import { SettingsBasicComponent } from './components/settings/settings-basic/settings-basic.component';
import { SettingsCoursesComponent } from './components/settings/settings-courses/settings-courses.component';
import { SettingsNotificationsComponent } from './components/settings/settings-notifications/settings-notifications.component';
import { CoursesDatatableComponent } from './components/common/courses-datatable/courses-datatable.component';
import { CourseEnrollmentDialogComponent } from './components/common/course-enrollment-dialog/course-enrollment-dialog.component';
import { CourseSettingsBasicComponent } from './components/course-settings/course-settings-basic/course-settings-basic.component';
import { CourseSettingsQaComponent } from './components/course-settings/course-settings-qa/course-settings-qa.component';
import { CourseSettingsParticipationComponent } from './components/course-settings/course-settings-participation/course-settings-participation.component';
import { CourseSettingsEnrollmentComponent } from './components/course-settings/course-settings-enrollment/course-settings-enrollment.component';
import { CourseSettingsGroupsComponent } from './components/course-settings/course-settings-groups/course-settings-groups.component';
import { MessagePageComponent } from './components/message-page/message-page.component';
import { MessageThreadComponent } from './components/message-page/message-thread/message-thread.component';
import { ThreadReplyComponent } from './components/message-page/thread-reply/thread-reply.component';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import { CreatepostComponent } from './components/createpost/createpost.component';
import { CKEditorModule } from 'ng2-ckeditor';
import { MasterSidebarComponent } from './components/common/master-sidebar/master-sidebar.component';
import { InfiniteScrollModule } from 'ngx-infinite-scroll';
import { QuickviewTabsComponent } from './components/quickview-tabs/quickview-tabs.component';
import { FavoritesComponent } from './components/favorites/favorites.component';
import { DraftsComponent } from './components/drafts/drafts.component';
import { FlexLayoutModule } from '@angular/flex-layout';
import { ErrorComponent } from './components/error/error.component';
import { DraftsDatatableComponent } from './components/drafts/drafts-datatable/drafts-datatable.component';
import { PostComponent } from './components/post/post.component';
import { ValidIDDirective } from './directives/valid-id.directive';
import { OmsDropdownComponent } from './components/common/oms-dropdown/oms-dropdown.component';
import { OmsRadiogroupComponent } from './components/common/oms-radiogroup/oms-radiogroup.component';
import { DialogAlertComponent } from './components/common/dialog-alert/dialog-alert.component';
import { MatNativeDateModule } from '@angular/material';
import { MatMomentDateModule} from '@angular/material-moment-adapter';
import { GroupsDatatableComponent } from './components/common/groups-datatable/groups-datatable.component';
import { OmsDaterangeComponent } from './components/common/oms-daterange/oms-daterange.component';
import { OmsDateComponent } from './components/common/oms-date/oms-date.component';
import { OmsListComponent } from './components/common/oms-list/oms-list.component';
import { OmsTimezoneSelectComponent } from './components/common/oms-timezone-select/oms-timezone-select.component';
import { AdminpanelComponent } from './components/adminpanel/adminpanel.component';
import { LoginLandingComponent } from './components/login-landing/login-landing.component';
import { GroupAddModalComponent } from './components/common/group-add-modal/group-add-modal.component';
import { EditpostComponent } from './components/editpost/editpost.component';
import { OmsSlideToggleListComponent } from './components/common/oms-slide-toggle-list/oms-slide-toggle-list.component';
import { OmsUserLookupComponent } from './components/common/oms-user-lookup/oms-user-lookup.component';
import { CreatePostWizardComponent } from './components/create-post-wizard/create-post-wizard.component';
import { GroupAddMemberModalComponent } from './components/common/group-add-member-modal/group-add-member-modal.component';
import { MessagePollComponent } from './components/message-page/message-poll/message-poll.component';
import { PlotlyModule } from 'angular-plotly.js';
import { UserRegistrationComponent } from './components/user-registration/user-registration.component';
import { UserActivationComponent } from './components/user-activation/user-activation.component';
import { MessagesDatatableComponent } from './components/common/messages-datatable/messages-datatable.component';
import { AnnouncementsComponent } from './components/announcements/announcements.component';
import { UnreadComponent } from './components/unread/unread.component';
import { SearchComponent } from './components/search/search.component';
import { AclDatatableComponent } from './components/common/acl-datatable/acl-datatable.component';
import { SearchesDatatableComponent } from './components/common/searches-datatable/searches-datatable.component';
import { OmsNumberComponent } from './components/common/oms-number/oms-number.component';
import { OmsSimpleInputComponent } from './components/common/oms-simple-input/oms-simple-input.component';
import { FilterMessageDatatableComponent } from './components/common/filter-message-datatable/filter-message-datatable.component';
import { NavTitlebarComponent } from './components/common/nav-titlebar/nav-titlebar.component';
import { UserManualComponent } from './components/help/user-manual/user-manual.component';
import { InstructorsManualComponent } from './components/help/instructors-manual/instructors-manual.component';
import { OmsToggleComponent } from './components/common/oms-toggle/oms-toggle.component';

export function tokenGetter() {
  return localStorage.getItem('access_token');
}


@NgModule({
  exports: [
    MatAutocompleteModule,
    MatChipsModule
  ],
  declarations: [
    AppComponent,
    LoginFormComponent,
    DashboardComponent,
    SettingsComponent,
    HelpComponent,
    CourseSettingsComponent,
    CoursesMainComponent,
    NavigationMenuComponent,
    SettingsBasicComponent,
    SettingsCoursesComponent,
    SettingsNotificationsComponent,
    CoursesDatatableComponent,
    CourseEnrollmentDialogComponent,
    CourseSettingsBasicComponent,
    CourseSettingsQaComponent,
    CourseSettingsParticipationComponent,
    CourseSettingsEnrollmentComponent,
    CourseSettingsGroupsComponent,
    MessagePageComponent,
    MessageThreadComponent,
    ThreadReplyComponent,
    CreatepostComponent,
    MasterSidebarComponent,
    QuickviewTabsComponent,
    FavoritesComponent,
    DraftsComponent,
    ErrorComponent,
    DraftsDatatableComponent,
    PostComponent,
    ValidIDDirective,
    OmsDropdownComponent,
    OmsRadiogroupComponent,
    DialogAlertComponent,
    GroupsDatatableComponent,
    OmsDaterangeComponent,
    OmsDateComponent,
    OmsListComponent,
    OmsTimezoneSelectComponent,
    AdminpanelComponent,
    LoginLandingComponent,
    GroupAddModalComponent,
    EditpostComponent,
    OmsSlideToggleListComponent,
    OmsUserLookupComponent,
    CreatePostWizardComponent,
    GroupAddMemberModalComponent,
    MessagePollComponent,
    UserRegistrationComponent,
    UserActivationComponent,
    MessagesDatatableComponent,
    AnnouncementsComponent,
    UnreadComponent,
    SearchComponent,
    AclDatatableComponent,
    SearchesDatatableComponent,
    OmsNumberComponent,
    OmsSimpleInputComponent,
    FilterMessageDatatableComponent,
    NavTitlebarComponent,
    UserManualComponent,
    InstructorsManualComponent,
    OmsToggleComponent
  ],
  imports: [
    BrowserModule,
    NgbModule.forRoot(),
    BrowserAnimationsModule,
    MatButtonModule,
    LayoutModule,
    MatToolbarModule,
    MatSidenavModule,
    MatIconModule,
    MatListModule,
    MatTabsModule,
    MatCardModule,
    MatExpansionModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    ReactiveFormsModule,
    FormsModule,
    JwtModule.forRoot({
      config: {
        tokenGetter: tokenGetter,
        whitelistedDomains: ['localhost:8085', 'api.cs8903.williambrandonking.com', 'api.cs8903.dev.williambrandonking.com']
      }
    }),
    HttpClientModule,
    routing,
    MatGridListModule,
    MatMenuModule,
    MatTableModule,
    MatCheckboxModule,
    MatBadgeModule,
    MatPaginatorModule,
    MatSortModule,
    MatRadioModule,
    MatDialogModule,
    MatSlideToggleModule,
    FontAwesomeModule,
    CKEditorModule,
    MatAutocompleteModule,
    InfiniteScrollModule,
    FlexLayoutModule,
    MatDatepickerModule,
    MatNativeDateModule,
    MatMomentDateModule,
    MatChipsModule,
    MatStepperModule,
    PlotlyModule
  ],
  providers: [
    AuthSystemService,
    AlertService,
    AuthGuard,
    MatIconRegistry],
  bootstrap: [AppComponent],
  entryComponents: [
    CourseEnrollmentDialogComponent,
    DialogAlertComponent,
    GroupAddModalComponent,
    GroupAddMemberModalComponent,
    OmsSimpleInputComponent]
})

export class AppModule {
  constructor(public matIconRegistry: MatIconRegistry) {
    matIconRegistry.registerFontClassAlias('fontawesome', 'fa');
  }
}
