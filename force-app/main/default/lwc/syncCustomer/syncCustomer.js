import { LightningElement } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchQbCustomers from "@salesforce/apex/QbAccountController.fetchQbCustomers";
import fetchSyncAccount from "@salesforce/apex/QbAccountController.fetchSyncAccount";

export default class SyncCustomer extends LightningElement {
  loaded = false;
  isSelected = false;
  visible = false;
  connectedCallback() {
    fetchSyncAccount()
      .then((result) => {
        this.isSelected = result;
        this.loaded = result;
      })
      .catch((error) => {
        this.error = error;
      });
  }
  handleClick(event) {
    this.isSelected = event.target.checked;
    this.loaded = !this.loaded;
    if (this.isSelected) {
      fetchQbCustomers()
        .then((result) => {
          const evt = new ShowToastEvent({
            title: 'Syncing Started',
            message: 'It will take 5 - 10 minutes to sync!!',
            variant: 'info',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        this.visible = true;
        let delay = 5000
        setTimeout(() => {
            this.visible = false;
        }, delay );
        })
        .catch((error) => {
        });
    }
  }
}