public class OrderPdfPageController {
    
    //controls how many Order Product order are displayed on page 1
    private static Integer FIRST_BREAK = 50;
    //controls how many Order Product line are displayed on subsequent page
    private static Integer SUBSEQ_BREAKS = 80;
    
    //Record Id Order 
    public String orderId{get;set;}
    public List<OrderItem[]> OrderProductListwithPageBreak{get; set; }
    public Order orderRecord{get; set;}
    public List<OrderItem> orderLineItems{get; set;}
    public List<String> contactemaillist;
    public Blob body;
    public OrderPdfPageController(ApexPages.StandardController controller) {
     
     
       OrderId = controller.getId();
       OrderRecord = (Order)controller.getRecord();
       orderLineItems = [Select Id ,AvailableQuantity,EndDate,Description,ListPrice,OrderItemNumber ,Product2.Name ,Quantity,ServiceDate,TotalPrice,UnitPrice ,Order.ShipToContact.Email,Order.Customer_Email__c  from OrderItem where OrderId =:OrderId];
       if(orderLineItems !=null && orderLineItems.size()>0){
       
       contactemaillist = new List<String>();
       if(orderLineItems[0].Order.ShipToContact.Email != null)
       contactemaillist.add(orderLineItems[0].Order.ShipToContact.Email); 
        if(orderLineItems[0].Order.Customer_Email__c != null)
        contactemaillist.add(orderLineItems[0].Order.Customer_Email__c); 
       }
       
       prepareOrderLineForPrinting();
       
    }
    
    
    //splits the OrderItem lines into an approximate number of rows that can be 
    //displayed per page
private void prepareOrderLineForPrinting()
{
    OrderProductListwithPageBreak= new List<OrderItem[]>();
    
    OrderItem[] pageOfOrderItem = new OrderItem[]{};
    Integer counter = 0;
    
       boolean firstBreakFound = false;
       boolean setSubSeqBreak = false;        
       Integer breakPoint = FIRST_BREAK;

    for(OrderItem o : orderLineItems)
    {
      if(counter <= breakPoint)
      {
         pageOfOrderItem.add(o);
         counter++; 
      }
      if(counter == breakPoint)
      {
         if (!firstBreakFound) 
         {
            firstBreakFound = true;
               setSubSeqBreak  = true;
         }
         counter = 0;
         OrderProductListwithPageBreak.add(pageOfOrderItem);
         pageOfOrderItem.clear();
      }
      if(setSubSeqBreak) 
         {
            breakPoint = SUBSEQ_BREAKS;
            setSubSeqBreak = false;
         }
    }
    //if we have finished looping and have some quotes left let's assign them
    if(!pageOfOrderItem.isEmpty())
          OrderProductListwithPageBreak.add(pageOfOrderItem);
  }
  
  
  public PageReference saveAsPDF(){
  
      PageReference pdf = Page.Order_Invoice_PDFpage;
        // add parent id to the parameters for standardcontroller
        pdf.getParameters().put('id',OrderId);
    
        // create the new attachment
        Attachment attach = new Attachment();
        
        
        
        try {
            
            // returns the output of the page as a PDF
            body = pdf.getContent();
            
        // need to pass unit test -- current bug    
        } catch (VisualforceException e) {
            body = Blob.valueOf(''+e.getMessage());
        }
        
        attach.Body = body;
        // add the user entered name
        attach.Name = 'PurchaseOrder_'+OrderRecord.OrderNumber+'.pdf';
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.ParentId = OrderId ;
        insert attach;
        
        // send the user to the Order to view results
        return new PageReference('/'+OrderId);
    
  }
  
  //send email message to contact related to Contact 
  public PageReference sendPdfEmail(){
  
    saveAsPDF();
    
    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
    attach.setContentType('application/pdf');
    attach.setFileName('PurchaseOrder_'+OrderRecord.OrderNumber+'.pdf');
    attach.setInline(false);
    attach.Body = body;

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setUseSignature(false);
    if(contactemaillist  != null && !contactemaillist.isEmpty()){
        mail.setToAddresses( contactemaillist);
        
        mail.setSubject('Purchase Order for '+  'PurchaseOrder_'+OrderRecord.OrderNumber+'.pdf');
        mail.setHtmlBody('Please find purchase order in attachement ! Check the attachment!');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
        
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with Purchase order PDF sent to '+contactemaillist[0]));
     }
     else{
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Email is associated with this Purchase Order, Please update Email'));
     }
  
    return null;
  }
  
  public PageReference returnToOrder(){
  
  // send the user to the Order to view results
        return new PageReference('/'+OrderId);
  }
  
}