@isTest
public with sharing class DSALES_CreateInsurancePolicyTest {
    @testSetup
    static void creacionRegistros(){
        String tipoProducto = 'Producto';
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Seguro_de_Moto').getRecordTypeId();
        DSALES_Familia__c familia = new DSALES_Familia__c();
        familia.Name = 'test';
        insert familia;
        DSALES_Categoria__c categoria = new DSALES_Categoria__c();
        categoria.Name = 'test';
        insert categoria;
        DSALES_Clase__c clase = new DSALES_Clase__c();
        clase.Name = 'test';
        insert clase;
        Product2 prodRc = new Product2(Name ='RC',dsalesVehiculo__c='sadkncdcs' ,StockKeepingUnit='0000',DSALES_Familia__c=familia.Id,DSALES_Categoria__c=categoria.Id,DSALES_Clase__c=clase.Id,DSales_Tipo_de_Producto__c='Seguro',IsActive=true);
		insert prodRc;
        Product2 prodAmp = new Product2(Name ='AMP',dsalesVehiculo__c='23d23d23', StockKeepingUnit='123444',DSALES_Familia__c=familia.Id,DSALES_Categoria__c=categoria.Id,DSALES_Clase__c=clase.Id,DSales_Tipo_de_Producto__c='Seguro',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,IsActive=true);
		insert prodAmp;
        Product2 prodMoto = new Product2(Name ='Moto',dsalesVehiculo__c='lasicndsldicsid',StockKeepingUnit='12121212',DSales_Tipo_de_Producto__c='Producto',DSales_Aplicaporcentajecobro__c=true, DSales_PorcentajeCobro__c=40,IsActive=true);
		insert prodMoto;
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
        standardPriceMoto.Product2Id = prodMoto.Id;
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
        customPriceMoto.Product2Id = prodMoto.Id;
        customPriceMoto.UnitPrice = 2000;
        customPriceMoto.IsActive = true;
        insert customPriceMoto;
        Account acc = new Account();
        acc.Name='Sayra Martinez Quiroz';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.DSALES_Clientecoppel__c='90001';
        insert acc;
        Opportunity oportunidad = new Opportunity(Name='Testoportunidadortunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert oportunidad;
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  '1';
        insert t;
        DSALES_InformaciondePago__c pago = new DSALES_InformaciondePago__c(DSALES_Oportunidad__c=oportunidad.id,DSALES_Cliente__c=acc.Id,DSALES_Seguro__c=true);
        insert pago;
        Quote cotizacion = new Quote(opportunityId=oportunidad.Id,Name='test',DSales_Tienda__c=t.Id);
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
        Plazo__c plazoAMP12 = new Plazo__c(Name='12',Dsales_Plazo__c='12',dsalesSeguro__c=prodAmp.Id,DSALES_Activo__c=true);
        insert plazoAMP12;
        QuoteLineItem moto = new QuoteLineItem();
        moto.QuoteId = cotizacion.Id;
        moto.PricebookEntryId = customPrice.Id;
        moto.Product2Id = prodMoto.Id;
        moto.Quantity = 1.0;
        moto.UnitPrice = customPrice.UnitPrice;
        moto.DSALES_Segurogratis__c=true;
        insert moto;
        QuoteLineItem seguroAmp = new QuoteLineItem();
        seguroAmp.QuoteId = cotizacion.Id;
        seguroAmp.PricebookEntryId = customPrice.Id;
        seguroAmp.Product2Id = prodAmp.Id;
        seguroAmp.Quantity = 1.0;
        seguroAmp.UnitPrice = customPrice.UnitPrice;
        seguroAmp.DSALES_Plazo__c=plazoAMP12.Id;
        seguroAmp.DSALES_Segurogratis__c=false;
        insert seguroAmp;
        oportunidad.SyncedQuoteId=cotizacion.Id;
        update oportunidad;
        
        DSALES_VentaSM.DatosParticipante part = new DSALES_VentaSM.DatosParticipante();
        part.figura='Conductor';
        part.nombre='Sayra';
        part.apellidoPaterno='Martinez';
        part.apellidoMaterno='Quiroz';
        part.relacionConParticipante='';
        part.porcentaje='0';
        part.telefono='4325808753';
        part.correoElectronico='saymartinez@deloittemx.com';
        part.genero='Femenino';
        part.fechaNacimiento=Date.today();
        part.rfc='123678';
        part.codigoPostal=22945;
        part.codigoEstado='12';
        part.codigoCiudad='12';
        part.codigoColonia='12';
        part.calle='calle';
        part.numeroExterior='12';
        part.numeroInterior='12';
    }

    @isTest
    public static void prepolizaTest(){
        DSALES_InformaciondePago__c pago = [SELECT Id,DSALES_Oportunidad__c FROM DSALES_InformaciondePago__c LIMIT 1];
        DSALES_VentaSM.DatosParticipante part = new DSALES_VentaSM.DatosParticipante();
        part.figura='Conductor';
        part.nombre='Sayra';
        part.apellidoPaterno='Martinez';
        part.apellidoMaterno='Quiroz';
        part.relacionConParticipante='';
        part.porcentaje='0';
        part.telefono='4325808753';
        part.correoElectronico='saymartinez@deloittemx.com';
        part.genero='Femenino';
        part.fechaNacimiento=Date.today();
        part.rfc='123678';
        part.codigoPostal=1224324;
        part.codigoEstado='12';
        part.codigoCiudad='12';
        part.codigoColonia='12';
        part.calle='calle';
        part.numeroExterior='12';
        part.numeroInterior='12';
        List<DSALES_VentaSM.DatosParticipante> listaPart= new List<DSALES_VentaSM.DatosParticipante>();
        listaPart.add(part);
        DSALES_VentaSMRest.DatosPrepoliza banderas = new DSALES_VentaSMRest.DatosPrepoliza();
        banderas.idPago=pago.Id;
        banderas.enviaContratante=false;
        banderas.beneficiarioPreferente=true;
        DSALES_CreateInsurancePolicy.crearPoliza(listaPart,banderas);
        InsurancePolicy poliza = [SELECT Id,SourceopportunityId,ExpirationDate,DSALES_VigenciacumplidaSM__c,dsalesEstatusPoliza__c FROM InsurancePolicy WHERE SourceopportunityId=:pago.DSALES_Oportunidad__c];
		DSALES_CreateInsurancePolicy.relacionarPolizaAPago(poliza);
        InsurancePolicyAsset activo = new InsurancePolicyAsset(
            		InsurancePolicyId=poliza.Id,
                    DSALES_Clavevehicular__c='54321',
            		DSALES_Modelo__c='2023',
            		DSALES_Numeroserie__c='98765432',
            		DSALES_Numeromotor__c='8',
            		DSALES_Descripcion__c='Moto  vento Azul',
            		DSALES_Servicio__c='Particular',
            		DSALES_Placas__c='87654321',
            		DSALES_Marca__c='Vento',
            		DSALES_Uso__c='Personal'
        );
        insert activo;
        Test.startTest();
        DSALES_CreateInsurancePolicy.agregarDatosDeActivo(activo, poliza.Id);
        Test.stopTest();
        System.assertNotEquals(null, activo,'la variable no debe ser null');

    }
    
    @isTest
    public static void estatusTest(){
        DSALES_InformaciondePago__c pago = [SELECT Id,DSALES_Oportunidad__c FROM DSALES_InformaciondePago__c LIMIT 1];
        Test.startTest();
       DSALES_VentaSM.DatosParticipante part = new DSALES_VentaSM.DatosParticipante();
        part.figura='Conductor';
        part.nombre='Sayra';
        part.apellidoPaterno='Martinez';
        part.apellidoMaterno='Quiroz';
        part.relacionConParticipante='';
        part.porcentaje='0';
        part.telefono='4325808753';
        part.correoElectronico='saymartinez@deloittemx.com';
        part.genero='Femenino';
        part.fechaNacimiento=Date.today();
        part.rfc='123678';
        part.codigoPostal=1224324;
        part.codigoEstado='12';
        part.codigoCiudad='12';
        part.codigoColonia='12';
        part.calle='calle';
        part.numeroExterior='12';
        part.numeroInterior='12';
        List<DSALES_VentaSM.DatosParticipante> listaPart= new List<DSALES_VentaSM.DatosParticipante>();
        listaPart.add(part);
        DSALES_VentaSMRest.DatosPrepoliza banderas = new DSALES_VentaSMRest.DatosPrepoliza();
        banderas.idPago=pago.Id;
        banderas.enviaContratante=false;
        banderas.beneficiarioPreferente=true;
        DSALES_CreateInsurancePolicy.crearPoliza(listaPart,banderas);
        InsurancePolicy poliza = [SELECT Id,SourceopportunityId,ExpirationDate,DSALES_VigenciacumplidaSM__c,dsalesEstatusPoliza__c FROM InsurancePolicy WHERE SourceopportunityId=:pago.DSALES_Oportunidad__c];
		poliza.ExpirationDate=DateTime.now();
        update poliza;
        DSALES_CreateInsurancePolicy.cambiarEstatusPoliza(poliza.Id);
        Test.stopTest();
        System.assertNotEquals(null, poliza, 'La variable no debe ser null');
    }
}