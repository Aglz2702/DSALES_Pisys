@isTest
public class DSALES_PolizaWrapperTest {
	@TestSetup 
    static void configuracionRegistros(){
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Seguro_de_Moto').getRecordTypeId();
        Product2 prodAmp = new Product2(Name ='AMP',dsalesVehiculo__c='23d23d23', StockKeepingUnit='123444',DSales_Tipo_de_Producto__c='Seguro',IsActive=true);
		insert prodAmp;
        
        Product2 prodM = new Product2(Name ='Moto',	dsalesVehiculo__c='lasicndsldicsid',StockKeepingUnit='12121212',DSales_Tipo_de_Producto__c='Producto',IsActive=true);
		insert prodM;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPriceMoto = new PricebookEntry();
        standardPriceMoto.Pricebook2Id = pricebookId;
        standardPriceMoto.Product2Id = prodM.Id;
        standardPriceMoto.UnitPrice = 1000;
        standardPriceMoto.IsActive = true;
        insert standardPriceMoto;

        PricebookEntry standardPriceAMP = new PricebookEntry();
        standardPriceAMP.Pricebook2Id = pricebookId;
        standardPriceAMP.Product2Id = prodAmp.Id;
        standardPriceAMP.UnitPrice = 1000;
        standardPriceAMP.IsActive = true;
        insert standardPriceAMP;

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
        PricebookEntry customPriceAMP = new PricebookEntry();
        customPriceAMP.Pricebook2Id = customPB.Id;
        customPriceAMP.Product2Id = prodM.Id;
        customPriceAMP.UnitPrice = 2000;
        customPriceAMP.IsActive = true;
        insert customPriceAMP;
        
        /*PricebookEntry customPriceMoto = new PricebookEntry();
        customPriceMoto.Pricebook2Id = customPB.Id;
        customPriceMoto.Product2Id = prodM.Id;
        customPriceMoto.UnitPrice = 2000;
        customPriceMoto.IsActive = true;
        insert customPriceMoto;*/
       Account acc = new Account();
        acc.Name='Sayra Martinez Quiroz';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.DSALES_ClienteCoppel__c='90001';
        insert acc;

        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;
        
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  '1';
        insert t;
        
        Quote cotizacion = new Quote(OpportunityId=opp.Id,Name='test',DSales_Tienda__c=t.Id);
        insert cotizacion;
         Plazo__c plazoAMP18 = new Plazo__c(Name='18',Dsales_Plazo__c='18',dsalesSeguro__c=prodAmp.Id,DSALES_Activo__c=true);
        insert plazoAMP18;
        QuoteLineItem seguroAmp = new QuoteLineItem();
        seguroAmp.QuoteId = cotizacion.Id;
        seguroAmp.PricebookEntryId = customPrice.Id;
        seguroAmp.Product2Id = prodAmp.Id;
        seguroAmp.Quantity = 1.0;
        seguroAmp.UnitPrice = customPrice.UnitPrice;
        //seguroAmp.DSALES_Tipodeproducto__c = 'Producto';
        seguroAmp.DSALES_Plazo__c=plazoAMP18.Id;
        seguroAmp.DSALES_Segurogratis__c=false;
        seguroAmp.dsalesQuoteId__c='098765432111';
        insert seguroAmp;

        QuoteLineItem moto = new QuoteLineItem();
        moto.QuoteId = cotizacion.Id;
        moto.PricebookEntryId = customPrice.Id;
        moto.Product2Id = prodM.Id;
        moto.Quantity = 1.0;
        moto.UnitPrice = customPrice.UnitPrice;
        moto.DSALES_Segurogratis__c=false;
        insert moto;
        opp.SyncedQuoteId=cotizacion.Id;
        opp.StageName='Cerrada ganada';
        update opp;

        DSALES_InformaciondePago__c pago = new DSALES_InformaciondePago__c(DSALES_Oportunidad__c=opp.id,DSALES_Cliente__c=acc.Id,DSALES_Seguro__c=true,DSALES_IDUniversal1__c='0000000000000001');
        insert pago;
        InsurancePolicy poliza =new  InsurancePolicy();
        poliza.Name='122345';
        poliza.PolicyName='1234';
        poliza.NameInsuredId=acc.Id;
        poliza.SourceQuoteId=cotizacion.Id;
        poliza.SourceOpportunityId=opp.Id;
        poliza.DSALES_CorreoElectronico__c='saymartinez@deloittemx.com';
        poliza.dsalesQuoteId__c='12345';
        insert poliza;
    }

    @isTest
    public static void actualiarPoliza(){
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Oportunidad__c,DSALES_Poliza__c,DSALES_IDUniversal1__c FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c=:'0000000000000001' WITH SECURITY_ENFORCED];
        InsurancePolicy pol = [SELECT Id,dsalesQuoteId__c FROM Insurancepolicy LIMIT 1];
        System.debug('idUnivesal test:'+pago.DSALES_IDUniversal1__c);
        String body='{"quote":"98765432","quote_id":"'+pol.dsalesQuoteId__c+'","idEmision":"87654321","trackingId":"098765432187654","numeroPoliza":"9999999999","fechaVigencia":"2023-05-02","fechaVencimiento":"2023-05-30","fechaEmision":"2023-05-02","sumaAsegurada":"234.5","primaNeta":"123.5","primaTotal":"324.1","gastosExpedicion":"234.5","iva":12.4,"urlPdf":"www.pruebaurlpoliza.com"}';
        request.requestURI='/apexrest/obternerPoliza'; 
        request.httpMethod='PUT'; 
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_PolizaWrapper.Request poliza=(DSALES_PolizaWrapper.Request)JSON.deserialize (body,DSALES_PolizaWrapper.Request.class);
        Test.startTest();
        DSALES_NuevaPoliza.actualizarPoliza();
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        System.assertNotEquals(200, response.statusCode, 'La llamada no debe devolver un código 200');
    }
}