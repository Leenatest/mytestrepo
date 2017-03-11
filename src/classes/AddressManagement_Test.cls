//**************************************************************************/
// (c) 2013 Appirio, Inc.
//
// Description : Test class for AddressManagement.
//                  
// Original August 22, 2013  : KapiL Choudhary(JDC) Created for the Task T-175201
// Updated :August 26, 2013  : KapiL Choudhary(JDC) Updated with TestClassUtility functions.
// Updated :Sep,20 2013  : Urminder(JDC) Updated with TestMockUp
// ***************************************************************************/

@isTest
global class AddressManagement_Test {
    
    static testMethod void blockedAddressTest() {
        
      Address__c add = TestClassUtility.createAddress(1, true).get(0);
        add.Block_Address__c = true;
        update add;

       Address__c add1 = TestClassUtility.createAddress(1, false).get(0);
        add1.Block_Address__c = true;
        insert add1; 
    }
     static testMethod void blockedAddressTest_exception() {
        Address__c add = TestClassUtility.createAddress(1, true).get(0);
        add.Block_Address__c = true;
        AddressManagement.isTestException = true;
        update add;
    }

    static testMethod void addressManagementUnitTest() {
    	OSB__c osbSettings = new OSB__c();
    	osbSettings.Create_Address_Enabled__c = true;
    	insert osbSettings;
    	
    	Test.startTest();
    	Test.setMock(WebServiceMock.class, new WebServiceMockCreateAddress());
        list<Address__c>addressList    = TestClassUtility.createAddress(2, true);
        if(!addressList.isempty() && addressList.size() == 2){
        	addressList[0].Country__c = 'USA';
        	addressList[1].Country__c = 'Canada';
        	
        	update addressList;
        	
        }
        Address__c add = TestClassUtility.createAddress(1, true).get(0);
        list<contact>contactMdmList = [select contact.MDM_ID__c from contact where id =:addressList[0].Consumer__c];
        system.assertNotEquals(null, contactMdmList);
        add.MDM_ID__c = null;
        update add;
        list<Staging_Address__c>  sTAddList= [SELECT Address_3__c,Address__c,MDM_Address_ID__c,MDM_Contact_ID__c,Zip_Code__c FROM Staging_Address__c where MDM_Contact_ID__c=:contactMdmList[0].MDM_ID__c];
        if(!sTAddList.isEmpty()){
        	sTAddList[0].Address_3__c = 'Add 3';
        	update sTAddList;
        }
        system.debug('sTAddList >>>> '+sTAddList);
		list<Country__c> countrySeetingList = new list<Country__c>();
        Country__c coun1 = new Country__c(name='Canada',X2_Letter_Code__c = 'CA', X3_Letter_Code__c ='CAN');
        countrySeetingList.add(coun1);
        
        Country__c coun2 = new Country__c(name='United States',X2_Letter_Code__c = 'US', X3_Letter_Code__c ='USA');
        countrySeetingList.add(coun2);
        
        insert countrySeetingList;
        //list<Account>personAccountList = TestClassUtility.createPersonAccount(2, true);
        
        // Must Creates records in Staging_Address__c for null MDM_ID__c Id.
        system.assertEquals(3, [select id from Staging_Address__c where Zip_Code__c =: addressList[0].Postal_Code__c].size());
        	
        if(!addressList.isEmpty()){ 
        	addressList[0].MDM_ID__c = 'NEWMDM';
        	addressList[0].Address_Line_1__c = 'Updated Address Line1';
        	
        	update addressList;
        // Must Creates a recod in Staging_Address__c with MDM_ID__c Id.
        // system.assertEquals(1, [select id from Staging_Address__c where MDM_Address_ID__c =: addressList[0].MDM_ID__c].size());
          Test.stopTest();	
        }
    }
   global class WebServiceMockCreateAddress implements WebServiceMock {
	   global void doInvoke(
	           Object stub,
	           Object request,
	           Map<String, Object> response,	
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {
	      		Sony_MiddlewareUpdateInsertAddress2.PSUpdateInsertAddress_Output_element responseElm = 
	      		  	new Sony_MiddlewareUpdateInsertAddress2.PSUpdateInsertAddress_Output_element();
	       		
	       		
	       		    Sony_MiddlewareUpdateInsertAddress2.Address add =  new Sony_MiddlewareUpdateInsertAddress2.Address();
					add.city='test';
					add.state='test';
					
					//prepare list of addresses
					
					Sony_MiddlewareUpdateInsertAddress2.ListOfAddress ladd = new Sony_MiddlewareUpdateInsertAddress2.ListOfAddress();
					ladd.Address = new list<Sony_MiddlewareUpdateInsertAddress2.Address>{add};
					
					//Assing that address to contact
					
					Sony_MiddlewareUpdateInsertAddress2.Contact cnt = new Sony_MiddlewareUpdateInsertAddress2.Contact();
					cnt.MDMRowId = '1-4EB-1';
					cnt.ListOfAddress = ladd;
					
					//Create list of contact
					
					Sony_MiddlewareUpdateInsertAddress2.ListOfContact lcnt = new Sony_MiddlewareUpdateInsertAddress2.ListOfContact();
					lcnt.Contact = new list<Sony_MiddlewareUpdateInsertAddress2.Contact>{cnt};
				  
				  responseElm.ListOfContact = lcnt;
				       		 
	       		  response.put('response_x', responseElm); 
	   		   }
    }
    
}