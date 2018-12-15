import { NgModule } from '@angular/core';
import { OahuComponentsComponent } from './oahu-components.component';
import { NumberComponent } from './components/number/number.component';

@NgModule({
  declarations: [OahuComponentsComponent, NumberComponent],
  imports: [
  ],
  exports: [OahuComponentsComponent, NumberComponent]
})
export class OahuComponentsModule { }
