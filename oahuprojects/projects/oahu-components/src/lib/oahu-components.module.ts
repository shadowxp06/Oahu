import { NgModule } from '@angular/core';
import { OahuComponentsComponent } from './oahu-components.component';
import { NumberComponent } from './components/number/number.component';
import {FormsModule, ReactiveFormsModule} from '@angular/forms';
import {HttpClientModule} from '@angular/common/http';
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

@NgModule({
  declarations: [OahuComponentsComponent, NumberComponent],
  imports: [
    ReactiveFormsModule,
    FormsModule,
    MatButtonModule,
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
    MatAutocompleteModule,
    MatDatepickerModule,
    MatChipsModule,
    MatStepperModule,
    HttpClientModule
  ],
  exports: [OahuComponentsComponent, NumberComponent]
})
export class OahuComponentsModule { }
