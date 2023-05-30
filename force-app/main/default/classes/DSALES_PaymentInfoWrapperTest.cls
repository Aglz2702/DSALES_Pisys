@isTest
public class DSALES_PaymentInfoWrapperTest {
    @testSetup
    public static void creacionRegistros(){
    	Account cuenta = new Account();
        cuenta.Name='testL';
        cuenta.BillingCity = 'test';
        cuenta.BillingStreet = 'calle 3 test';
        cuenta.BillingState = 'CDMX';
        cuenta.BillingPostalCode = '666666';
        cuenta.BillingCountry='México';
        insert cuenta;
        String recordTypeId = Schema.SObjectType.DSALES_InformacionDePago__c.getRecordTypeInfosByDeveloperName().get('DSALES_PagosdeVentaenNPVSM_c').getRecordTypeId();
        Opportunity oportunidad = new Opportunity();
        oportunidad.Name = 'testL';
        oportunidad.AccountId = cuenta.Id;
        oportunidad.CloseDate = Date.Today();
        oportunidad.StageName = 'Nuevo';
        insert oportunidad;
        
        Tienda__c tienda = new Tienda__c();
        tienda.DSales_TiendaID__c =  '1';
        insert tienda;
    }
    
    @isTest 
       	static void registrarPagoTest(){
        Account cuenta =[SELECT Id,FinServ__BillingAddress__pc FROM Account];
        Opportunity oportunidad = [SELECT Id FROM Opportunity LIMIT 1];
        Tienda__c tienda =[SELECT Id FROM Tienda__c LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse respuesta = new RestResponse();
        String body='{"idUniversal":"111111111111","idOportunidad":"'+oportunidad.Id+'","tipoFolio":"01","folioTransaccion":"014564","totalFactura":20000,"Seguro":true,"nombreVendedor":"Nelson Varela","numeroCaja":"1","claveTienda":"1","sku":"984376","fechaEntrega":"2023-05-19","fechaVenta":"2023-05-17","plazos":18,"ListaDePagos":[{"metodoPago":"Efectivo","pago":1000}]}';
        request.requestURI = '/insertPaymentInformationSM/*';
        request.httpMethod = 'POST';
        RestContext.request = request;
        request.requestBody = Blob.valueof(body);
        RestContext.response = respuesta;
        DSALES_PaymentInfoWrapper.PaymentRequest pago = (DSALES_PaymentInfoWrapper.PaymentRequest)JSON.deserialize(body, DSALES_PaymentInfoWrapper.PaymentRequest.class);            
        System.debug('PAGO TEST:'+pago);
        Test.startTest();
		DSALES_PaymentInfoWrapperRequest.crearPago();
		Test.stopTest();
        RestContext.request = request;
        RestContext.response= respuesta;
        System.assertNotEquals(200, respuesta.statusCode, 'La llamada no debe devolver un código 200');
    }
    @isTest 
    static void registrarPagoErrorTest(){
        Opportunity oportunidad = [SELECT Id FROM Opportunity LIMIT 1];
        Tienda__c tienda =[SELECT Id FROM Tienda__c LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse respuesta = new RestResponse();
        String body='{"idUniversal":"111111111111","idOportunidad":"00000000000000000","tipoFolio":"01","folioTransaccion":"014564","totalFactura":20000,"Seguro":true,"nombreVendedor":"Nelson Varela","numeroCaja":"1","claveTienda":"1","sku":"984376","fechaEntrega":"2023-05-19","fechaVenta":"2023-05-17","plazos":18,"ListaDePagos":[{"metodoPago":"Efectivo","pago":1000}]}';
        request.requestURI = '/insertPaymentInformationSM/*';
        request.httpMethod = 'POST';
        RestContext.request = request;
        request.requestBody = Blob.valueof(body);
        RestContext.response = respuesta;
        DSALES_PaymentInfoWrapper.PaymentRequest pago = (DSALES_PaymentInfoWrapper.PaymentRequest)JSON.deserialize(body, DSALES_PaymentInfoWrapper.PaymentRequest.class);            
        Test.startTest();
		DSALES_PaymentInfoWrapperRequest.crearPago();
		Test.stopTest();
        RestContext.request = request;
        RestContext.response= respuesta;
        System.assertNotEquals(200, respuesta.statusCode, 'La llamada no debe devolver un código 200');
    }
}