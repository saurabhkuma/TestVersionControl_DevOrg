/*
 * Class to Handle post Request from WebServices 
 * Description : It will create a record in salesforce based on request and respose the result to requester 
 * 
 */
@RestResource(urlMapping='/createOrderRecord/*')
global class HttpIntegrationPoc {
    
 /*
  *  Http Post method to handle request and reply with success and failure 
  * 
  */
 @HttpPost 
 global static String createNewOrder() {
    String response ;
     String request = RestContext.request.requestBody.toString();
     System.debug( request );
    //added a comment today ......  ......
    try{
   system.debug((OrderWrapper) System.JSON.deserialize(request, OrderWrapper.class));
   OrderWrapper owrapper = (OrderWrapper) System.JSON.deserialize(request, OrderWrapper.class);
   Account account = new Account();
     account.Name = owrapper.FullName;
     account.BillingStreet = owrapper.ShippingAddress1 + '  '+owrapper.ShippingAddress2;
     account.BillingCity = owrapper.ShippingCity;
     account.BillingState = owrapper.ShippingState;
     account.Wrapper_Class_Data__c = request;
     
         insert account ;
         response = 'Record Created Succesfully';
     }catch(Exception e){
         response = 'Error ' +e.getMessage() ;
     }

   return response;
 }
    
   
   /*
    * Wrapper class to parse Json  
    */ 
    public class OrderWrapper {
        
        public Integer WebOrderID;
        public String DateOrdered;
        public String FullName;
        public String ShippingAddressName;
        public String ShippingAddress1;
        public String ShippingAddress2;
        public String ShippingCity;
        public String ShippingState;
        public String ShippingPostalCode;
        public String ShippingCountry;
        public List<Item> items;
        
        
    }   

    public  class Item {
        
        
        public Integer WebOrderID ;

        public Integer LineNumber ;

        public Integer LineQtyNumber;

        public String OptionHardware;

        public String OptionImage;

        public String TrainingStartDate;

        public String TrainingEndDate;

        public String EUFirstName;

        public String EULastName;

        public String EUPhoneNum;

        public String EUEmailAddr;

        public String EUMgrEmailAddr;

        public String Department;
    }
    
    /*{

    "WebOrderID": 21940140,

    "DateOrdered": "2018-06-22T13:53:15.063",

    "FullName": "Mockingbird Lane",

    "ShippingAddressName": "Cityline",

    "ShippingAddress1": "12441 State Street, Ste 5000",

    "ShippingAddress2": "CITYLINE 1",

    "ShippingCity": "RICHARDSON",

    "ShippingState": "TX",

    "ShippingPostalCode": "74082-2147",

    "ShippingCountry": "United States",

    "Items": [{

        "WebOrderID": 21940140,

        "LineNumber": 1,

        "LineQtyNumber": 1,

        "OptionHardware": "Training Laptop: HP 255 G6 - 15.6\" 8 GB RAM - 256 GB SSD",

        "OptionImage": "Developer",

        "TrainingStartDate": "6/25/2018",

        "TrainingEndDate": "8/27/2018",

        "EUFirstName": "James",

        "EULastName": "Bond",

        "EUPhoneNum": "(111) 555-1212",

        "EUEmailAddr": "james.bond@aaa.com",

        "EUMgrEmailAddr": "M@aaa.com",

        "Department": "Enterprise Technology"

    }]

} */
}