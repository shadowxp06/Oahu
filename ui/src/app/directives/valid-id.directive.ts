import { Directive, forwardRef, Input } from '@angular/core';
import { NG_VALIDATORS, Validator, AbstractControl } from '@angular/forms';

/* https://stackblitz.com/edit/mat-select-with-custom-validator?file=app%2Frestrict-keyword-validator.directive.ts */
@Directive({
  selector: '[appValidIDValidator][ngModel],[appValidIDValidator][formControl],[appValidIDValidator][formControlName]',
  providers: [
    { provide: NG_VALIDATORS, useExisting: forwardRef(() => ValidIDDirective), multi: true }
  ]
})
export class ValidIDDirective implements Validator {

  @Input('appValidIDValidator') id: number;
  validate(ctrl: AbstractControl): { [key: string]: boolean } | null {
    return ctrl.value <= 0 ? {'invalidValue': true} : null;
  }
}
