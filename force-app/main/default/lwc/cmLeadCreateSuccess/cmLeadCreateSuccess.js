import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import LABEL_SUCCESS_TITLE from '@salesforce/label/c.CM_BC_Success_Title';
import LABEL_SUCCESS_LINE_PREFIX from '@salesforce/label/c.CM_BC_Success_Line_Prefix';
import LABEL_SUCCESS_LINE_SUFFIX from '@salesforce/label/c.CM_BC_Success_Line_Suffix';
import LABEL_SUCCESS_LINE_SUFFIX_SINGULAR from '@salesforce/label/c.CM_BC_Success_Line_Suffix_Singular';
import LABEL_SUCCESS_BUTTON from '@salesforce/label/c.CM_BC_Success_Button';

const LABELS = {
  successTitle: LABEL_SUCCESS_TITLE,
  successLinePrefix: LABEL_SUCCESS_LINE_PREFIX,
  successLineSuffix: LABEL_SUCCESS_LINE_SUFFIX,
  successLineSuffixSingular: LABEL_SUCCESS_LINE_SUFFIX_SINGULAR,
  successButton: LABEL_SUCCESS_BUTTON
};

export default class CmLeadCreateSuccess extends NavigationMixin(LightningElement) {
  /** Flow / external inputs **/
  @api recordId;                 // New Lead Id (show "Open" only if provided)
  @api title;                    // Card title (optional override)
  @api subtitle;                 // Subtitle (e.g., name/company)
  @api buttonLabel;
  @api showConfetti;     // ✅ Public boolean defaults to false to avoid LWC1503
  @api showOpenButton;   // ✅ Same as above
  @api count;                    // Success count (Number or String)

  get computedTitle() {
    return this.title || LABELS.successTitle;
  }
  get successLinePrefix() {
    return LABELS.successLinePrefix;
  }
  get successLineSuffix() {
    return this.countNumber === 1 ? LABELS.successLineSuffixSingular : LABELS.successLineSuffix;
  }
  get computedButtonLabel() {
    return this.buttonLabel || LABELS.successButton;
  }
  get countNumber() {
    const n = Number(this.count);
    return Number.isFinite(n) && n > 0 ? Math.floor(n) : 1;
  }
  get countLabel() {
    return String(this.countNumber);
  }

  openRecord = () => {
    if (!this.recordId) return;
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: { recordId: this.recordId, actionName: 'view' }
    });
  };
}
