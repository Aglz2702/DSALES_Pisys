@isTest
public class DSALES_CrearParticipanteTest {
    @testSetup
    public static void crearRegistros(){
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Seguro_de_Moto').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName='Sayra';
        acc.LastName='Martinez';
        acc.Suffix='Quiroz';
        acc.CP_WalletCustomerNumber__c=45654;
        acc.DSALES_Clientecoppel__c='90001';
        acc.PersonEmail='saymartinez@deloittemx.com';
        insert acc;
        Account coppel = new Account();
        coppel.FirstName='COPPEL';
        coppel.LastName='SA';
        coppel.Suffix='DE CV';
        //coppel.CP_WalletCustomerNumber__c=45654;
        //coppel.DSALES_Clientecoppel__c='90001';
        //coppel.PersonEmail='saymartinez@deloittemx.com';
        insert coppel;
        Pricebook2 customPB = new Pricebook2();
        customPB.Name='Standard Price Book';
        customPB.isActive=true;
        insert customPB;
        Opportunity oportunidad = new Opportunity(Name='Testoportunidadortunity', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Nuevo', Pricebook2Id=customPB.Id,RecordTypeId=recordTypeId);
        insert oportunidad;
        Tienda__c t = new Tienda__c();
        t.DSales_TiendaID__c =  '1';
        insert t;
        DSALES_InformaciondePago__c pago = new DSALES_InformaciondePago__c(DSALES_Oportunidad__c=oportunidad.id,DSALES_Cliente__c=acc.Id,DSALES_Seguro__c=true);
        insert pago;
        Quote cotizacion = new Quote(opportunityId=oportunidad.Id,Name='test',DSales_Tienda__c=t.Id);
        insert cotizacion;
        InsurancePolicy poliza = new Insurancepolicy();
        poliza.Name='0001';
        poliza.NameInsuredId=acc.Id;
        poliza.DSALES_CorreoElectronico__c='saymartinez@deloittemx.com';
        insert poliza;
        pago.DSALES_Poliza__c=poliza.Id;
        update pago;
    }
    @isTest
    public static void crearConductorTest(){
        Account cliente=[SELECT Id, Name FROM Account LIMIT 1];
        Insurancepolicy poliza=[SELECT Id FROM Insurancepolicy LIMIT 1];
        DSALES_CrearParticipantesPoliza.crearConductor(cliente.Id,poliza.Id);        
    }
    @isTest
    public static void buscarConductorTest(){
        DSALES_CrearParticipantesPoliza.DatosConductor cond= new DSALES_CrearParticipantesPoliza.DatosConductor();
        cond.nombre='Sayra';
        cond.apellidoMaterno='Quiroz';
        cond.apellidoPaterno='Martinez';
        cond.correo='saymartinez@deloittemx.com';
        DSALES_CrearParticipantesPoliza.busquedaCuentaConductor(cond, null);
    } 
    @isTest
    public static void crearParticipantesTest(){
        List<DSALES_VentaSM.DatosParticipante> listaParticipante = new List<DSALES_VentaSM.DatosParticipante>();
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
        part.codigoPostal=22854;
        part.codigoEstado='12';
        part.codigoCiudad='12';
        part.codigoColonia='12';
        part.calle='calle';
        part.numeroExterior='12';
        part.numeroInterior='12';
        DSALES_VentaSM.DatosParticipante part2 = new DSALES_VentaSM.DatosParticipante();
        part2.figura='Beneficiario';
        part2.nombre='Carlos';
        part2.apellidoPaterno='Ramos';
        part2.apellidoMaterno='Cruz';
        part2.relacionConParticipante='Padre';
        part2.porcentaje='0';
        part2.telefono='4325808753';
        part2.correoElectronico='saymartinez@deloittemx.com';
        part2.genero='Masculino';
        part2.fechaNacimiento=Date.today();
        part2.rfc='123678';
        part2.codigoPostal=22854;
        part2.codigoEstado='12';
        part2.codigoCiudad='12';
        part2.codigoColonia='12';
        part2.calle='calle';
        part2.numeroExterior='12';
        part2.numeroInterior='12';
        listaParticipante.add(part);
        listaParticipante.add(part2);
        Insurancepolicy poliza=[SELECT Id FROM Insurancepolicy LIMIT 1];
		DSALES_CrearParticipantesPoliza.crearParticipantes(listaParticipante, poliza.Id, false);
    }
}