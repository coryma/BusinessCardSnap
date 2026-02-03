import { LightningElement, api } from 'lwc';

export default class CmFlowDivider extends LightningElement {
    @api color = '#d8dde6';
    @api thickness = '1px';
    @api marginTop = '0.75rem';
    @api marginBottom = '0.75rem';
    @api width = '100%';

    get style() {
        return `border-top: ${this.thickness} solid ${this.color}; margin-top: ${this.marginTop}; margin-bottom: ${this.marginBottom}; width: ${this.width};`;
    }
}
