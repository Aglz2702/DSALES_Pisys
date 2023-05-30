@isTest
public with sharing class DSALES_IPAssetWrapperRequestActivoTest {
    @testSetup
    static void setUp(){
        Product2 prodAmp = new Product2(Name ='AMP',	dsalesVehiculo__c='23d23d23', StockKeepingUnit='123444',DSales_Tipo_de_Producto__c='Seguro',IsActive=true);
		insert prodAmp;
         Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPriceGEX = new PricebookEntry();
        standardPriceGEX.Pricebook2Id = pricebookId;
        standardPriceGEX.Product2Id = prodAmp.Id;
        standardPriceGEX.UnitPrice = 1000;
        standardPriceGEX.IsActive = true;
        insert standardPriceGEX;
        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;
        PricebookEntry customPrice = new PricebookEntry();
        customPrice.Pricebook2Id = customPB.Id;
        customPrice.Product2Id = prodAmp.Id;
        customPrice.UnitPrice = 1200;
        customPrice.IsActive = true;
        insert customPrice;
        Account ac= new Account(FirstName='Sayra',LastName='Martinez',Suffix='Quiroz',PersonEmail='saymartinez@deloittemx.com',BillingPostalCode='123');  
        insert ac;
         Account coppel= new Account(BillingPostalCode='123',FirstName='COPPEL',LastName='SA',Suffix='DE CV',PersonEmail='coppel@exe.com');  
        insert coppel;
    	//FirstName,LastName,Suffix,PersonMobilePhone,PersonEmail,CP_Gender__pc,PersonBirthdate,BillingStreet,BillingCity,BillingState,BillingPostalCode,dsalesNumeroInterior__c,dsalesNumeroExterior__c,CP_BillingStateCode__c,dsalesCodigoColonia__
        Opportunity op = new Opportunity(Name='Nelson',CloseDate=Date.today(),StageName='Nuevo',Pricebook2Id=customPB.Id);
        insert op;
        InsurancePolicy ip = new InsurancePolicy(Name='Nelson',NameInsuredId=ac.id,DSALES_CorreoElectronico__c='xnelsonvsx@hotmail.com');
        insert ip;
        
        String recordTypeIdPago=Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_PagosdeVentaenNPVSM_c').getRecordTypeId();
		Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  '1';
        insert t;
        DSALES_InformaciondePago__c pago = new DSALES_InformaciondePago__c(DSALES_Oportunidad__c=op.id,DSALES_Cliente__c=ac.Id,DSALES_Clave_Tienda__c='1',DSALES_Seguro__c=true,DSALES_IDUniversal1__c='2023031400015666634');
        insert pago;
        Quote cotizacion = new Quote(opportunityId=op.Id,Name='test',DSales_Tienda__c=t.Id);
        insert cotizacion;
        Plazo__c plazoAMP12 = new Plazo__c(Name='12',Dsales_Plazo__c='12',	dsalesSeguro__c=prodAmp.Id,DSALES_Activo__c=true);
        insert plazoAMP12;
        QuoteLineItem seguroAmp = new QuoteLineItem();
        seguroAmp.QuoteId = cotizacion.Id;
        seguroAmp.PricebookEntryId = customPrice.Id;
        seguroAmp.Product2Id = prodAmp.Id;
        seguroAmp.Quantity = 1.0;
        seguroAmp.UnitPrice = customPrice.UnitPrice;
        seguroAmp.DSALES_Plazo__c=plazoAMP12.Id;
        seguroAmp.DSALES_Segurogratis__c=false;
        insert seguroAmp;
        InsurancePolicy pol = new InsurancePolicy(
           Name='Sayra test',
           NameInsuredId=ac.id,
           DSALES_CorreoElectronico__c='xnelsonvsx@hotmail.com',
           SourceOpportunityId=op.Id,
           SourceQuoteId=cotizacion.Id
        );
        insert pol;
        pago.DSALES_Poliza__c=pol.Id;
        update pago;
        InsurancePolicyParticipant conductor = new InsurancePolicyParticipant();
        conductor.Role='Conductor';
        conductor.PrimaryParticipantAccountId=ac.Id;
        conductor.InsurancePolicyId=pol.Id;
        insert conductor;
        InsurancePolicyParticipant contratante = new InsurancePolicyParticipant();
        contratante.Role='Contratante';
        contratante.InsurancePolicyId=pol.Id;
        contratante.RelatedParticipantAccountId=coppel.Id;
        insert contratante;
        
    }
    @isTest 
    public static void sinPolizaTest(){
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        DSALES_InformaciondePago__c pago = [SELECT id,DSALES_Poliza__c,DSALES_IDUniversal1__c, DSALES_Motoentregada__c FROM  DSALES_InformaciondePago__c  WHERE  DSALES_IDUniversal1__c='2023031400015666634'];
        InsurancePolicy poliza = [SELECT Id,SourceQuoteId FROM InsurancePolicy WHERE Id=:pago.DSALES_Poliza__c];
        System.debug('poliza rn test activo:'+poliza);
        String body='{"emitirPoliza":true,"idUniversal":"'+pago.DSALES_IDUniversal1__c+'","uso":"Personal","claveTienda":"1","servicio":"Particular","numeroSerie":"12345678","numeroMotor":"8","modelo":"2022","placas":"AS-4567","claveVehicular":"098765432","valorFactura":8000,"bajoDemanda":false,"descripcion":"moto Vitalia azul","marca":"VITALIA","nombreActivo":"MOTO VITALIA"}';
        request.requestURI='/apexrest/insertIPAssetDelivered'; 
        request.httpMethod='POST';
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_IPAssetWrapper.IPAssetRequest policyAsset =  (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize (body,DSALES_IPAssetWrapper.IPAssetRequest.class);
        Test.startTest();
        DSALES_IPAssetWrapperRequestActivo.crearActivo();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        System.assertNotEquals(200, response.statusCode, 'La llamada no debe devolver un código 200');
    }
    
}