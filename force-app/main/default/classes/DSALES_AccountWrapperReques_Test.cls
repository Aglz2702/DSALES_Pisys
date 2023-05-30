@isTest 
public class DSALES_AccountWrapperReques_Test{
    
    @testSetup
    static void setUp(){
        Account acc = new Account();
        acc.Name='test';
        acc.CP_WalletCustomerNumber__c=87654;
        acc.DSALES_ClienteCoppel__c='90001';
        insert acc;
        
        Account accContado = new Account();
        accContado.FirstName = 'Emmanuel';
        accContado.LastName = 'Gonzalez';
        accContado.PersonEmail = 'egl@deloittemx.com';
        accContado.PersonBirthdate = date.today();
        accContado.Suffix = 'Lopez';
        insert accContado;
    }
    
    @isTest 
    static void createRecordTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"numeroDeCliente":"87654","nombre":"Test","apellidoPaterno":"Test","apellidoMaterno":"Prueba","telefono":"89017829","correoElectronico":"dsanmiguel@deloittemx.com","genero":"M","fechaNacimiento":"1992-08-02","codigoPostal":"06030","nombreEstado":"12","numeroInterior":"12","numeroExterior":"12","colonia":"12"}';
        req.requestURI = '/apexrest/insertAccount';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        RestContext.response = res;
        DSALES_AccountWrapper.AccountRequest cliente = (DSALES_AccountWrapper.AccountRequest)JSON.deserialize(body, DSALES_AccountWrapper.AccountRequest.class);
        Test.startTest();
        DSALES_AccountWrapperRequest.createAccount();
        Test.stopTest();
        RestContext.request = req;
        RestContext.response= res;
        System.assertNotEquals(200, res.statusCode, 'The API call should not return a 200 status code');
    }
     @isTest 
    static void createRecordTest2(){
        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        String body2 = '{"numeroDeCliente":"","nombre":"Test","apellidoPaterno":"Test","apellidoMaterno":"Prueba","telefono":"89017829","correoElectronico":"dsanmiguel@deloittemx.com","genero":"M","fechaNacimiento":"1992-08-02","codigoPostal":"06030"}';
        req2.requestURI = '/apexrest/insertAccount';
        req2.httpMethod = 'POST';
        RestContext.request = req2;
        req2.requestBody = Blob.valueof(body2);
        RestContext.response = res2;
        DSALES_AccountWrapper.AccountRequest cliente2 = (DSALES_AccountWrapper.AccountRequest)JSON.deserialize(body2, DSALES_AccountWrapper.AccountRequest.class);
        Test.startTest();
        DSALES_AccountWrapperRequest.createAccount();
        Test.stopTest();
        RestContext.request = req2;
        RestContext.response= res2;
        System.assertNotEquals(200, res2.statusCode, 'The API call should not return a 200 status code');
    }
     @isTest 
    static void createRecordTest3(){
        RestRequest req3 = new RestRequest();
        RestResponse res3 = new RestResponse();
        String body3 = '{"numeroDeCliente":"","nombre":"Emmanuel","apellidoPaterno":"Gonzalez","apellidoMaterno":"Lopez","telefono":"89017829","correoElectronico":"egl@deloittemx.com","genero":"M","fechaNacimiento":"1992-08-02","codigoPostal":"06030"}';
        req3.requestURI = '/apexrest/insertAccount';
        req3.httpMethod = 'POST';
        RestContext.request = req3;
        req3.requestBody = Blob.valueof(body3);
        RestContext.response = res3;
        DSALES_AccountWrapper.AccountRequest cliente3 = (DSALES_AccountWrapper.AccountRequest)JSON.deserialize(body3, DSALES_AccountWrapper.AccountRequest.class);
        Test.startTest();
        DSALES_AccountWrapperRequest.createAccount();
        Test.stopTest();
        RestContext.request = req3;
        RestContext.response= res3;
        System.assertNotEquals(200, res3.statusCode, 'The API call should not return a 200 status code');
    }
}