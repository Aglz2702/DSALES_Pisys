@isTest
public class DSALES_VentaSMRestAuxTest {
   @testSetup 
    static void creacionRegistros(){
        String tipoProducto = 'Producto';
        String message = '';
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Seguro_de_Moto').getRecordTypeId();
        
        DSALES_Familia__c family = new DSALES_Familia__c();
        family.Name = 'test';
        insert family;
        
        DSALES_Categoria__c category = new DSALES_Categoria__c();
        category.Name = 'test';
        insert category;
        
        DSALES_Clase__c classs = new DSALES_Clase__c();
        classs.Name = 'test';
        insert classs;
        
        Product2 prodRc = new Product2(Name ='RC',dsalesVehiculo__c='sadkncdcs' ,StockKeepingUnit='0000',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',IsActive=true);
		insert prodRc;
        
        Product2 prodAmp = new Product2(Name ='PLUS',dsalesVehiculo__c='23d23d23', StockKeepingUnit='123444',DSALES_Familia__c=family.Id,DSALES_Categoria__c=category.Id,DSALES_Clase__c=classs.Id,DSales_Tipo_de_Producto__c='Seguro',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,IsActive=true);
		insert prodAmp;
        
        Product2 prodM = new Product2(Name ='Moto',dsalesVehiculo__c='lasicndsldicsid',StockKeepingUnit='12121212',DSales_Tipo_de_Producto__c='Producto',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,IsActive=true);
		insert prodM;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = prodRc.Id;
        standardPrice.UnitPrice = 1000;
        standardPrice.IsActive = true;
        insert standardPrice;
        
        PricebookEntry standardPriceGEX = new PricebookEntry();
        standardPriceGEX.Pricebook2Id = pricebookId;
        standardPriceGEX.Product2Id = prodAmp.Id;
        standardPriceGEX.UnitPrice = 1000;
        standardPriceGEX.IsActive = true;
        insert standardPriceGEX;
        
        PricebookEntry standardPriceMoto = new PricebookEntry();
        standardPriceMoto.Pricebook2Id = pricebookId;
        standardPriceMoto.Product2Id = prodM.Id;
        standardPriceMoto.UnitPrice = 1000;
        standardPriceMoto.IsActive = true;
        insert standardPriceMoto;    
        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry();
        customPrice.Pricebook2Id = customPB.Id;
        customPrice.Product2Id = prodRc.Id;
        customPrice.UnitPrice = 1200;
        customPrice.IsActive = true;
        insert customPrice;
        
        PricebookEntry customPriceGEX = new PricebookEntry();
        customPriceGEX.Pricebook2Id = customPB.Id;
        customPriceGEX.Product2Id = prodAmp.Id;
        customPriceGEx.UnitPrice = 2000;
        customPriceGEX.IsActive = true;
        insert customPriceGEX;
        
        PricebookEntry customPriceMoto = new PricebookEntry();
        customPriceMoto.Pricebook2Id = customPB.Id;
        customPriceMoto.Product2Id = prodM.Id;
        customPriceMoto.UnitPrice = 2000;
        customPriceMoto.IsActive = true;
        insert customPriceMoto;
        
        Account acc = new Account();
        //acc.Name='Sayra Martinez Quiroz';
        acc.FirstName='Sayra';
        acc.LastName='Martinez';
        acc.Suffix='Quiroz';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.BillingPostalCode='123';
        acc.BillingPostalCode='123';
        //acc.DSALES_ClienteCoppel__c='90001';
        insert acc;
        Account coppel = new Account();
        coppel.FirstName='COPPEL';
        coppel.LastName='SA';
        coppel.Suffix='DE CV';
        coppel.BillingPostalCode='123';
        coppel.dsalesNumeroExterior__c=12;
        coppel.CP_BillingStateCode__c='12';
        insert coppel;
        
        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert opp;
        
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  '1';
        insert t;
        
        Quote cotizacion = new Quote(OpportunityId=opp.Id,Name='test',DSales_Tienda__c=t.Id);
        insert cotizacion;
        
        DSALES_TipodeUso__c tipoUso = new DSALES_TipodeUso__c(Name='Comercial');
        insert tipoUso;
        DSALES_Tipodevehculo__c tipovehiculo = new DSALES_Tipodevehculo__c(Name='Moto');
        insert tipovehiculo;
        
        Plazo__c plazoRC12 = new Plazo__c();
        plazoRC12.Name='12';
        plazoRC12.dsalesSeguro__c=prodRc.Id;
        plazoRC12.Dsales_Plazo__c='12';
        plazoRC12.DSALES_Activo__c=true;
        insert plazoRC12;
        
        Plazo__c plazoRC18 = new Plazo__c();
        plazoRC18.Name='18';
        plazoRC18.dsalesSeguro__c=prodRc.Id;
        plazoRC18.Dsales_Plazo__c='18';
        plazoRC18.DSALES_Activo__c=true;
        insert plazoRC18;
        
        Plazo__c plazoAMP12 = new Plazo__c(Name='12',Dsales_Plazo__c='12',dsalesSeguro__c=prodAmp.Id,DSALES_Activo__c=true);
        insert plazoAMP12;
         Plazo__c plazoAMP18 = new Plazo__c(Name='18',Dsales_Plazo__c='18',dsalesSeguro__c=prodAmp.Id,DSALES_Activo__c=true);
        insert plazoAMP18;
        
        QuoteLineItem seguroRcG = new QuoteLineItem();
        seguroRcG.QuoteId = cotizacion.Id;
        seguroRcG.PricebookEntryId = customPrice.Id;
        seguroRcG.Product2Id = prodRc.Id;
        seguroRcG.Quantity = 1.0;
        seguroRcG.UnitPrice = customPrice.UnitPrice;
        seguroRcG.DSALES_Plazo__c=plazoRC12.Id;
        seguroRcG.DSALES_Segurogratis__c=false;
        insert seguroRcG;
        
        QuoteLineItem seguroAmp = new QuoteLineItem();
        seguroAmp.QuoteId = cotizacion.Id;
        seguroAmp.PricebookEntryId = customPrice.Id;
        seguroAmp.Product2Id = prodAmp.Id;
        seguroAmp.Quantity = 1.0;
        seguroAmp.UnitPrice = customPrice.UnitPrice;
        seguroAmp.DSALES_Plazo__c=plazoAMP12.Id;
        seguroAmp.DSALES_Segurogratis__c=false;
        insert seguroAmp;
    }
    
    @isTest
    public static void errorVentaTest(){
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        Product2 producto =[SELECT Id FROM Product2 WHERE Name='PLUS' LIMIT 1];
        Plazo__c plazo=[SELECT Id FROM Plazo__c WHERE Name='12' LIMIT 1];
        Quote cot =[SELECT Id,OpportunityId,Opportunity.Name FROM Quote WHERE Name ='test' LIMIT 1];
        QuoteLineItem partida =[SELECT Id FROM QuoteLineItem WHERE  DSALES_Plazo__c=:plazo.Id LIMIT 1];
        String idPartida=partida.Id;
       // String body='{"idCotizacion":"","idPartidaPresupuesto":["'+partida.Id+'"],"pagos":{"idUniversal":"000000222222211116","tipoFolio":"01","folioTransaccion":"014564","totalFactura":20000,"Seguro":true,"nombreVendedor":"Nelson Varela","numeroCaja":"1","claveTienda":"1","sku":"","fechaEntrega":null,"fechaVenta":"2023-05-05","plazos":null,"ListaDePagos":[{"metodoPago":"Dinero Electrónico","pago":1}]},"datosParticipantes":[{"contratante":false,"funcion":"Propietario","numeroCliente":"","nombre":"Sayra","apellidoPaterno":"Martinez","apellidoMaterno":"Quiroz","telefono":"123456789","correoElectronico":"saymartinez@deloittemx.com","genero":"F","fechaNacimiento":"1997-09-30","rfc":"SASF8709222EA","codigoPostal":56644,"codigoEstado":"15","codigoCiudad":"025","codigoColonia":"4468","calle":"EJEMPLO DIG-2028","numeroExterior":"2028","numeoroInterior":""},{"contratante":false,"funcion":"Conductor;Beneficiario;","numeroCliente":"","nombre":"Sayra","apellidoPaterno":"Martinez","apellidoMaterno":"Quiroz","telefono":"9993432342","correoElectronico":"demo@inter.mx","genero":"M","fechaNacimiento":"1987-09-22","rfc":"SASF8709222EA","codigoPostal":56644,"codigoEstado":"15","codigoCiudad":"025","codigoColonia":"4468","calle":"EJEMPLO DIG-2028","numeroexterior":"2028","numerointerior":""},{"contratante":false,"funcion":"Beneficiario;","numeroCliente":"","nombre":"Say","apellidoPaterno":"Estrada","apellidoMaterno":"Demo","telefono":"9993432342","correoElectronico":"demo@inter.mx","genero":"M","fechaNacimiento":"1987-09-22","rfc":"SASF8709222EA","codigoPostal":56644,"codigoEstado":"15","codigoCiudad":"025","codigoColonia":"4468","calle":"EJEMPLO DIG-2028","numeroExterior":"2028","numeroInterior":""}],"activo":{"emitirPoliza":true,"uso":"Personal","claveTienda":"1","servicio":"Particular","numeroSerie":"987654321","numeroMotor":"43","modelo":"2023","placas":"98765432fd","claveVehicular":"98765432","valorFactura":3000,"bajoDemanda":true,"descripcion":"prueba","marca":"vento","nombreActivo":"MOTO VENTO"},"acuerdoLegal":[{"acuerdo":"Estoy de acuerdo con la descripción del vehículo seleccionada y misma que  se  muestra  en  la  parte superior de esta pantalla.","aceptado":true},{"acuerdo":"Mi vehículo no es utilizado ni será utilizado para presentar servicios de entrega por paquetería, a domicilio y/o similares.","aceptado":true}],"legal":{"codigoPostal":"43578","codigoEstado":"654","codigoCiudad":"4","codigoColonia":"3","calle":"Venustiano","numeroExterior":"12","numeroInterior":"3"}}';
       	String body='{"idCotizacion":"111111111111","idPartidaPresupuesto":["'+partida.Id+'"],"pagos":{"idUniversal":"000000222222211116","tipoFolio":"01","folioTransaccion":"014564","totalFactura":20000,"Seguro":true,"nombreVendedor":"Nelson Varela","numeroCaja":"1","claveTienda":"1","sku":"","fechaEntrega":null,"fechaVenta":"2023-05-22","plazos":null,"ListaDePagos":[{"metodoPago":"Efectivo","pago":18000}]},"beneficiarioPreferente":true,"contratante":"false","envioContratante":false,"datosParticipantes":[{"figura":"Conductor","numeroCliente":"45654","nombre":"Sayra","apellidoPaterno":"Martinez","apellidoMaterno":"Quiroz","telefono":"123456789","relacionConParticipante":"","porcentaje":"0","correoElectronico":"saymartinez@deloittemx.com","genero":"Femenino","fechaNacimiento":"1997-09-30","rfc":"SASF870922","codigoPostal":56644,"codigoEstado":"15","codigoCiudad":"025","codigoColonia":"4468","calle":"EJEMPLO DIG-2028","numeroExterior":"2028","numeroInterior":"124"},{"figura":"Beneficiario","numeroCliente":"","nombre":"Maria","apellidoPaterno":"Gonzalez","apellidoMaterno":"Rojas","telefono":"123456789","relacionConParticipante":"Hijo","porcentaje":"50","correoElectronico":"saymartinez@deloittemx.com","genero":"Femenino","fechaNacimiento":"1997-09-30","rfc":"SASF870922","codigoPostal":56644,"codigoEstado":"15","codigoCiudad":"025","codigoColonia":"4468","calle":"EJEMPLO DIG-2028","numeroExterior":"2028","numeroInterior":"124"},{"figura":"Beneficiario","numeroCliente":"","nombre":"Maria","apellidoPaterno":"Gonzalez","apellidoMaterno":"Rojas","telefono":"123456789","relacionConParticipante":"Madre","porcentaje":"10","correoElectronico":"saymartinez@deloittemx.com","genero":"Femenino","fechaNacimiento":"1997-09-30","rfc":"SASF870922","codigoPostal":56644,"codigoEstado":"15","codigoCiudad":"025","codigoColonia":"4468","calle":"EJEMPLO DIG-2028","numeroExterior":"2028","numeroInterior":"124"}],"activo":{"emitirPoliza":true,"uso":"Personal","claveTienda":"1","servicio":"Particular","numeroSerie":"8765432","numeroMotor":"865432","modelo":"4","placas":"37687","claveVehicular":"765432","valorFactura":1000,"bajoDemanda":true,"descripcion":"moto","marca":"vento","nombreActivo":"moto vento"}}';
		request.requestURI='/apexrest/ventaSM'; 
        request.httpMethod='POST'; 
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_VentaSM.VentaSMRequest venta =(DSALES_VentaSM.VentaSMRequest)JSON.deserialize (body,DSALES_VentaSM.VentaSMRequest.class);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        DSALES_VentaSMRest.crearVenta();
        Test.stopTest();
        RestContext.request = request; 
        RestContext.response= response;
        System.assertNotEquals(200, response.statusCode, 'La llamada no debe devolver un código 200');

    }
    
     @isTest
    public static void ventaExternaTest(){
        RestRequest request=new RestRequest();
        RestResponse response = new RestResponse();
        Product2 producto =[SELECT Id FROM Product2 WHERE Name='PLUS' LIMIT 1];
        Plazo__c plazo=[SELECT Id FROM Plazo__c WHERE Name='12' LIMIT 1];
        Quote cot =[SELECT Id,OpportunityId,Opportunity.Name FROM Quote WHERE Name ='test' LIMIT 1];
        QuoteLineItem partida =[SELECT Id FROM QuoteLineItem WHERE  DSALES_Plazo__c=:plazo.Id LIMIT 1];
		String idPartida=partida.Id;
        System.debug('TEST COTIZACION:'+cot);
        System.debug('TEST SEGURO:'+partida);
        //String body='{"idCotizacion":"'+cot.Id+'","idPartidaPresupuesto":["'+partida.Id+'"],"pagos":{"idUniversal":"000000222222211116","tipoFolio":"01","folioTransaccion":"014564","totalFactura":20000,"Seguro":true,"nombreVendedor":"Nelson Varela","numeroCaja":"1","claveTienda":"1","sku":"","fechaEntrega":null,"fechaVenta":"2023-05-05","plazos":null,"ListaDePagos":[{"metodoPago":"Dinero Electrónico","pago":1}]},"datosParticipantes":[{"contratante":false,"funcion":"Propietario","numeroCliente":"","nombre":"Sayra","apellidoPaterno":"Martinez","apellidoMaterno":"Quiroz","telefono":"123456789","correoElectronico":"saymartinez@deloittemx.com","genero":"F","fechaNacimiento":"1997-09-30","rfc":"SASF8709222EA","codigoPostal":56644,"codigoEstado":"15","codigoCiudad":"025","codigoColonia":"4468","calle":"EJEMPLO DIG-2028","numeroExterior":"2028","numeoroInterior":""},{"contratante":false,"funcion":"Conductor;Beneficiario;","numeroCliente":"","nombre":"Sayra","apellidoPaterno":"Martinez","apellidoMaterno":"Quiroz","telefono":"9993432342","correoElectronico":"demo@inter.mx","genero":"M","fechaNacimiento":"1987-09-22","rfc":"SASF8709222EA","codigoPostal":56644,"codigoEstado":"15","codigoCiudad":"025","codigoColonia":"4468","calle":"EJEMPLO DIG-2028","numeroexterior":"2028","numerointerior":""},{"contratante":false,"funcion":"Beneficiario;","numeroCliente":"","nombre":"Say","apellidoPaterno":"Estrada","apellidoMaterno":"Demo","telefono":"9993432342","correoElectronico":"demo@inter.mx","genero":"M","fechaNacimiento":"1987-09-22","rfc":"SASF8709222EA","codigoPostal":56644,"codigoEstado":"15","codigoCiudad":"025","codigoColonia":"4468","calle":"EJEMPLO DIG-2028","numeroExterior":"2028","numeroInterior":""}],"activo":{"emitirPoliza":true,"uso":"Personal","claveTienda":"1","servicio":"Particular","numeroSerie":"987654321","numeroMotor":"43","modelo":"2023","placas":"98765432fd","claveVehicular":"98765432","valorFactura":3000,"bajoDemanda":true,"descripcion":"prueba","marca":"vento","nombreActivo":"MOTO VENTO"},"acuerdoLegal":[{"acuerdo":"Estoy de acuerdo con la descripción del vehículo seleccionada y misma que  se  muestra  en  la  parte superior de esta pantalla.","aceptado":true},{"acuerdo":"Mi vehículo no es utilizado ni será utilizado para presentar servicios de entrega por paquetería, a domicilio y/o similares.","aceptado":true}],"legal":{"codigoPostal":"43578","codigoEstado":"654","codigoCiudad":"4","codigoColonia":"3","calle":"Venustiano","numeroExterior":"12","numeroInterior":"3"}}';
        String body='{"idCotizacion":"'+cot.Id+'","idPartidaPresupuesto":["'+partida.Id+'"],"pagos":{"idUniversal":"000000222222211116","tipoFolio":"01","folioTransaccion":"014564","totalFactura":20000,"Seguro":true,"nombreVendedor":"Nelson Varela","numeroCaja":"1","claveTienda":"1","sku":"","fechaEntrega":null,"fechaVenta":"2023-05-22","plazos":null,"ListaDePagos":[{"metodoPago":"Efectivo","pago":18000}]},"beneficiarioPreferente":true,"contratante":"false","envioContratante":false,"datosParticipantes":[{"figura":"Conductor","numeroCliente":"45654","nombre":"Sayra","apellidoPaterno":"Martinez","apellidoMaterno":"Quiroz","telefono":"123456789","relacionConParticipante":"","porcentaje":"0","correoElectronico":"saymartinez@deloittemx.com","genero":"Femenino","fechaNacimiento":"1997-09-30","rfc":"SASF870922","codigoPostal":56644,"codigoEstado":"15","codigoCiudad":"025","codigoColonia":"4468","calle":"EJEMPLO DIG-2028","numeroExterior":"2028","numeroInterior":"124"},{"figura":"Beneficiario","numeroCliente":"","nombre":"Maria","apellidoPaterno":"Gonzalez","apellidoMaterno":"Rojas","telefono":"123456789","relacionConParticipante":"Hijo","porcentaje":"50","correoElectronico":"saymartinez@deloittemx.com","genero":"Femenino","fechaNacimiento":"1997-09-30","rfc":"SASF870922","codigoPostal":56644,"codigoEstado":"15","codigoCiudad":"025","codigoColonia":"4468","calle":"EJEMPLO DIG-2028","numeroExterior":"2028","numeroInterior":"124"},{"figura":"Beneficiario","numeroCliente":"","nombre":"Maria","apellidoPaterno":"Gonzalez","apellidoMaterno":"Rojas","telefono":"123456789","relacionConParticipante":"Madre","porcentaje":"10","correoElectronico":"saymartinez@deloittemx.com","genero":"Femenino","fechaNacimiento":"1997-09-30","rfc":"SASF870922","codigoPostal":56644,"codigoEstado":"15","codigoCiudad":"025","codigoColonia":"4468","calle":"EJEMPLO DIG-2028","numeroExterior":"2028","numeroInterior":"124"}],"activo":{"emitirPoliza":true,"uso":"Personal","claveTienda":"1","servicio":"Particular","numeroSerie":"8765432","numeroMotor":"865432","modelo":"4","placas":"37687","claveVehicular":"765432","valorFactura":1000,"bajoDemanda":true,"descripcion":"moto","marca":"vento","nombreActivo":"moto vento"}}';
        request.requestURI='/apexrest/ventaSM'; 
        request.httpMethod='POST'; 
        RestContext.request=request;
        request.requestBody=Blob.valueOf(body);
        RestContext.response=response;
        DSALES_VentaSM.VentaSMRequest venta =(DSALES_VentaSM.VentaSMRequest)JSON.deserialize (body,DSALES_VentaSM.VentaSMRequest.class);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DSALES_MockHttpResponsePolizaTest());
        DSALES_VentaSMRest.crearVenta();
        Test.stopTest();
        RestContext.request = request;
        RestContext.response= response;
        System.assertNotEquals(200, response.statusCode, 'La llamada no debe devolver un código 200');
    }
}