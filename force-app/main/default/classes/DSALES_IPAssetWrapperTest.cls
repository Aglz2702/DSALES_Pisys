@isTest
public with sharing class DSALES_IPAssetWrapperTest {
    @testSetup
    static void setUp(){
        Account ac= new Account(Name='DannyTest',CP_WalletCustomerNumber__c=90229562);  
        insert ac;
        Opportunity op = new Opportunity(Name='Danny',CloseDate=Date.today(),StageName='Nuevo');
        insert op;
         InsurancePolicy ip = new InsurancePolicy(Name='Danny',NameInsuredId=ac.id,DSALES_CorreoElectronico__c='kvothe.sanmiguel@gmail.com');
        insert ip;
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  'CPPL-UGARTE';
        insert t;
        DSALES_InformaciondePago__c pago = new DSALES_InformaciondePago__c(DSALES_Oportunidad__c=op.id,DSALES_Cliente__c=ac.Id,DSALES_Poliza__c=ip.id,DSALES_Seguro__c=true,DSALES_IDUniversal1__c='123456');
        insert pago;
    }
    @isTest static void createRecordTest()
    {
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        DSALES_InformaciondePago__c pago = [SELECT id,DSALES_Poliza__c,DSALES_IDUniversal1__c FROM  DSALES_InformaciondePago__c  LIMIT 1];
        Tienda__c tienda =[SELECT Id FROM Tienda__c LIMIT 1];
        String body='{"emitirPoliza":false,"idUniversal":"'+pago.DSALES_IDUniversal1__c+'","uso":"Personal","claveTienda":"1","servicio":"Particular","numeroSerie":"12345678","numeroMotor":"8","modelo":"2022","placas":"AS-4567","claveVehicular":"098765432","valorFactura":8000,"bajoDemanda":false,"descripcion":"moto Vitalia azul","marca":"VITALIA","nombreActivo":"MOTO VITALIA"}}';
        request.requestURI='/apexrest/insertIPAsset'; 
        request.httpMethod='POST';
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_IPAssetWrapper.IPAssetRequest policyAsset =  (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize (body,DSALES_IPAssetWrapper.IPAssetRequest.class);
        //policyAsset.payment_info=pago.id;
        Test.startTest();
        DSALES_IPAssetWrapperRequest.createIPAsset();
        //Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        System.assertNotEquals(200, response.statusCode, 'La llamada no debe devolver un código 200');
    }
}