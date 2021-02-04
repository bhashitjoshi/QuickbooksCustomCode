/**
 * @description       : This class is use in CreateInvoice class
 * @author            : Ashish Sharma
 * @group             : 
 * @last modified on  : 09-14-2020
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   09-14-2020   Ashish Sharma   Initial Version
**/
// This class is use in CreateInvoice class
// It is use to create invoice body
global with sharing class CreateInvoiceWrapper { 
    public List<Line> Line;
    public CustomerRef CustomerRef;
    public class Line {
        public Integer Amount;
        public String DetailType;
        public SalesItemLineDetail SalesItemLineDetail;
    }
    public class SalesItemLineDetail {
        public Integer Qty;
        public ItemRef ItemRef;
        public TaxCodeRef TaxCodeRef;
    }
    public class ItemRef {
        public String value;
        public String name;
    }
    
    public class TaxCodeRef {
        public String value;
    }
    public class CustomerRef {
        public String value;
    }
}