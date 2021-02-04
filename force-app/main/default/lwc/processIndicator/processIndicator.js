import { LightningElement, track, api, wire } from "lwc";
import getQuoteLineItems from "@salesforce/apex/QuoteLineItemsController.getQuoteLineItems";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getCompanyId from "@salesforce/apex/QuoteLineItemsController.getCompanyId";
import getCustomers from "@salesforce/apex/QuoteLineItemsController.getCustomers";
import create from "@salesforce/apex/CreateCustomer.create";
import createProduct from "@salesforce/apex/CreateInvoice.createProduct";

//Columns for QuoteLineItems
const quoteLineItemColumn = [
  { label: "Product", fieldName: "Product2Name", type: "text" },
  {
    label: "Quantity",
    fieldName: "Quantity",
    type: "number",
    cellAttributes: { alignment: "left" }
  },
  {
    label: "Sales Price",
    fieldName: "UnitPrice",
    type: "currency",
    cellAttributes: { alignment: "left" }
  },
  { label: "Line Item Description", fieldName: "Description", type: "string" }
];

//Change customer to contact
//Columns for Customer list
const existingCustomerColumn = [
  { label: "Name", fieldName: " Display_Name__c" },
  { label: "Email", fieldName: " Email__c" },
  { label: "Environment", fieldName: " Environment__c" }

];
export default class processIndicator extends LightningElement {
  @track selectedStep = "Step1";
  @track step1 = true;
  @track step4 = false;
  @api recordId;
  @track option1 = false;
  @track option2 = false;
  @track accountId;
  @track title;
  @track showspinner = false;
  @track disablesubmit = false;
  @track selectedRows;
  @track CheckBeforeInsert = true;
  quoteLineItemsList;
  quoteLineItemColumn = quoteLineItemColumn;
  existingCustomersList;
  existingCustomerColumn = existingCustomerColumn;
  customerId;
  selectedCustomers;
  selectedCustomerId;
  finishDisabled = true;
  nextDisabled = true;
  preSelectedRows = [];

  get options() {
    return [
      { label: "Create new Contact", value: "option1" },
      { label: "Linked to Existing Contact", value: "option2" }
    ];
  }

  //Get the QuoteLineItems List
  connectedCallback() {
    getQuoteLineItems({ recordId: this.recordId })
      .then((result) => {
        result = JSON.parse(result);
        this.quoteLineItemsList = result.map(record =>
          Object.assign({ "Product2Name": record.Product2.Name }, record)
        );
      })
      .catch((error) => {
        this.error = error;
      });
      
  }

  //Get the AccountId
  @wire(getCompanyId, {
    recordId: "$recordId"
  })
  getaccountId(result) {
    if (result.data != null) {
      this.accountId = result.data;
      console.log('data');
    } else {
       console.log('getCompanyID->',result);
      this.accountId = null;
      const evt = new ShowToastEvent({
        title: "No Account associated with this quote",
        variant: "error",
        mode: "error"
      });
      this.dispatchEvent(evt);
    }
  }

  //Get the selected QuoteLineItems from the datatable
  getSelectedName(event) {
    this.selectedRows = event.detail.selectedRows;
    // Display that fieldName of the selected rows

    if (this.selectedRows.length === 0) {
      this.nextDisabled = true;
    } else {
      this.nextDisabled = false;
    }
  }

  handleNext() {
    var getselectedStep = this.selectedStep;
    this.selectedStep = "Step4";
    this.step1 = false;
    this.step4 = true;
  }

  handlePrev() {
    var getselectedStep = this.selectedStep;

    if (getselectedStep === "Step4") {
      this.selectedStep = "Step1";
      let rows = [];
      for (var i = 0; i < Object.keys(this.selectedRows).length; i++) {
        rows.push(this.selectedRows[i].Id);
      }
      this.preSelectedRows = rows;
      this.finishDisabled = true;
      this.step1 = true;
      this.step4 = false;
      this.option1 = false;
      this.option2 = false;
    }
  }


  // fetch the information of selected customer
  getSelectedCustomer(event) {
    let selectedOption = event.target.value;

    this.selectedCustomerId = selectedOption;
    this.finishDisabled = false;
  }

  handleFinish() {

    if (this.option1 === true) {
      let customerName = this.template.querySelector(
        "lightning-input-field.CustomerName"
      ).value;

      let Email = this.template.querySelector("lightning-input-field.Email")
        .value;

   

      if (customerName === null || Email === null) {
         console.log('customerName->',customerName);
        console.log('Email->',Email);
        const evt = new ShowToastEvent({
          title: "Please fill all the required fields",
          variant: "error",
          mode: "error"
        });
        this.dispatchEvent(evt);


      } else {
        if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(Email)) {
        
          if (this.disablesubmit === false) {
            this.showspinner = true;
           
            this.template.querySelector("lightning-record-edit-form").submit();
            this.disablesubmit = true;
            this.handleSuccess();
          }

        }
        else {
          console.log('in else');
          const evt = new ShowToastEvent({
            title: "Invalid Email",
            variant: "error",
            mode: "error"
          });
          this.dispatchEvent(evt);
          this.closeQuickAction();

        }

      }
    }

    if (this.option2 === true) {
      var selectedProducts = JSON.stringify(this.selectedRows);
      this.showspinner = true;
      console.log('sci',this.selectedCustomerId);
      console.log('sp',selectedProducts);
      console.log('ri',this.recordId);
      createProduct({
        customerId: this.selectedCustomerId,
        selectedProducts: selectedProducts,
        QuoteId: this.recordId
      })
        .then((result) => {
          if (result == 'ok') {
            const evt = new ShowToastEvent({
              title: "New Invoice is Created.",
              variant: "success",
              mode: "success"
            });
            this.dispatchEvent(evt);
            this.closeQuickAction();
          }
          else if (result === 'Select contact of same environment.') {
            const evt1 = new ShowToastEvent({
              title: "Select contact of same environment.",
              variant: "error",
              mode: "error"
            });
            this.dispatchEvent(evt1);
            this.closeQuickAction();
          }
          else {
            const evt = new ShowToastEvent({
              title: "Something is wrong.Please authorize again.",
              variant: "error",
              mode: "error"
            });
            this.dispatchEvent(evt);
            this.closeQuickAction();

          }
        })
        .catch((error) => {
          this.error = error;
        });
    }
  }

  selectStep1() {
    var getselectedStep = this.selectedStep;

    if (getselectedStep === "Step4") {
      this.selectedStep = "Step1";
      let rows = [];
      for (var i = 0; i < Object.keys(this.selectedRows).length; i++) {
        rows.push(this.selectedRows[i].Id);
      }
      this.preSelectedRows = rows;
      this.selectedStep = "Step1";
      this.step1 = true;
      this.step4 = false;
      this.option1 = false;
      this.option2 = false;

    }
  }

  selectStep4() {

    if (this.selectedRows != null) {
      this.selectedStep = "Step4";
      this.step1 = false;
      this.step4 = true;
    } else {
      this.selectedStep = "Step1";
      this.step1 = true;
      this.step4 = false;
      this.option1 = false;
      this.option2 = false;
     
    }
  }

  get isSelectStep4() {
    return this.selectedStep === "Step4";
  }

  handleRadioChange(e) {
    if (e.target.value === "option1") {
      this.option1 = true;
      this.option2 = false;
      this.finishDisabled = false;
    } else {
      this.finishDisabled = true;
      this.ShowCustomers();
    }
  }

  //Get the Customers List
  ShowCustomers() {
    getCustomers({ AccountId: this.accountId })
      .then((result) => {
        this.existingCustomersList = JSON.parse(result);
       
        

        if (Object.keys(this.existingCustomersList).length > 0) {
          this.option2 = true;
          this.option1 = false;
        } else {
          const evt = new ShowToastEvent({
            title: "No Exising Customer",
            variant: "error",
            mode: "error"
          });
          this.dispatchEvent(evt);
          this.option2 = true;
          this.option1 = false;
        }
      })
      .catch((error) => {
        this.error = error;
      });
  }

  handleSuccess(event) {
    this.customerId = event.detail.id;

    this.title = this.template.querySelector("lightning-input-field.Title")
      .value;
    let firstName = this.template.querySelector(
      "lightning-input-field.FirstName"
    ).value;
    let state = this.template.querySelector(
      "lightning-input-field.state"
    ).value;
    let lastName = this.template.querySelector("lightning-input-field.LastName")
      .value;
    let email = this.template.querySelector("lightning-input-field.Email")
      .value;
    let customerName = this.template.querySelector(
      "lightning-input-field.CustomerName"
    ).value;
    let phone = this.template.querySelector("lightning-input-field.Phone")
      .value;
    let street = this.template.querySelector("lightning-input-field.Street")
      .value;
    let city = this.template.querySelector("lightning-input-field.City").value;
    let postalCode = this.template.querySelector(
      "lightning-input-field.PostalCode"
    ).value;
    let country = this.template.querySelector("lightning-input-field.Country")
      .value;
    let Companyname = this.template.querySelector(
      "lightning-input-field.Companyname"
    ).value;

    var customerDetails = {
      Companyname: Companyname,
      title: this.title,
      firstName: firstName,
      lastName: lastName,
      email: email,
      customerName: customerName,
      phone: phone,
      street: street,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
    };
    var detailsOfCustomer = JSON.stringify(customerDetails);

    create({
      detailsOfCustomer: detailsOfCustomer,
      customerId: this.customerId
    })
      .then((result) => {


        var selectedProducts = JSON.stringify(this.selectedRows);
        if (result === 'ok') {
          console.log('status',result);
          console.log('customerId',this.customerId);
          console.log('selectedProducts',selectedProducts);
          console.log('recordId',this.recordId);
          createProduct({
            customerId: this.customerId,
            selectedProducts: selectedProducts,
            QuoteId: this.recordId
          })
            .then((result) => {
              const evt = new ShowToastEvent({
                title: "New Invoice is Created.",
                variant: "success",
                mode: "success"
              });
              this.dispatchEvent(evt);
              this.closeQuickAction();
            })
            .catch((error) => {
              this.error = error;
            });

          const evt = new ShowToastEvent({
            title: "New Customer is Created.",
            variant: "success",
            mode: "success"
          });
          this.dispatchEvent(evt);
        }
        else if (result === 'Duplicate') {
          const evt1 = new ShowToastEvent({
            title: "Duplicate Customer",
            variant: "error",
            mode: "error"
          });
          this.dispatchEvent(evt1);
          this.closeQuickAction();


        }
        else if (result === 'Select contact of same environment.') {
          const evt1 = new ShowToastEvent({
            title: "Select contact of same environment.",
            variant: "error",
            mode: "error"
          });
          this.dispatchEvent(evt1);
          this.closeQuickAction();
        }
        else {
          const evt2 = new ShowToastEvent({
            title: "Please authorize again",
            variant: "error",
            mode: "error"
          });
          this.dispatchEvent(evt2);
          this.closeQuickAction();


        }

      })
      .catch((error) => {
        this.error = error;
      });
  }

  closeQuickAction() {
    const closeQA = new CustomEvent("close");
    // Dispatches the event.
    this.dispatchEvent(closeQA);

     window.location.reload();
  }
}