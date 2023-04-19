@isTest
public class DSALES_siniestroTest {
    @testSetup
    static void testSetup(){
        String accountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account acc = new Account();
        acc.firstName='albert';
        acc.lastName='procopio';
        acc.PersonEmail= 'asa@as.co';
        acc.Phone = '93617359';
        insert acc;
        
        InsurancePolicy poli = new InsurancePolicy();
        poli.NameInsuredId=acc.Id;
        poli.DSALES_CorreoElectronico__c='asa@as.co';
        poli.DSALES_Estatusdepliza__c = 'Vigente';
        poli.Name = '2345';
        insert poli;
        
        Claim siniestro = new Claim();
        siniestro.Name='covertura';
        siniestro.PolicyNumberId = poli.Id;
        siniestro.P_liza__c = poli.Id;
        siniestro.DSALES_SiniestroUid__c = 'iszxxzxaxa';
        siniestro.DSALES_Estatus__c = 'En trámite';
        siniestro.ClaimType ='Robo total';
        siniestro.ClaimReason='sdsvs';       
        insert siniestro;    
    }
    @isTest 
    static void siniestroRequest(){ 
        RestRequest req = new RestRequest();
        String body = '{"business":"serviciosPoliza","company":"coppel","uid":"454545","reporte":"000002","numeroSiniestro":"Asistencia","tipoSiniestro":"Robo Total","fechaSiniestro":"28/07/2022 16:40:23","nombreConductor":"José Juan Resendiz Calavera ","causa":"choque","vehiculo":{"descripcion":"MOTOCICLETA VENTO WORKMAN 125 CC","anio":"2022","placa":"123HDF","serie":"1234DFGERS92871WD"},"poliza":{"numeroPoliza":"2345","inciso":"0001","fechaInicioVigencia":"23/03/2022","fechaFinVigencia":"22/03/2023","nombreAsegurado":"Graciela Guzmán Arreola"},"comoOcurrio":"Se cayó y chocó","ubicacion":"Calle Orquideas 27","municipio":"Tampico","estado":"Tamaulipas","estatus":"Pagado","solucionDevolucion":"sol","motivoDevolucion":"moti","saldoinsoluto":"12.12","motivoRechazo":"rechazadooo","salesforceid":""}';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(body);
        
        RestRequest req2 = new RestRequest();
        String body2 = '{"business":"serviciosPoliza","listSiniestro":[{"payment_amount":"660000","claimpayment_name":"Coppel","payment_type":"Pago a cuenta Coppel","payment_date":"2022-10-11"}],"company":"coppel","uid":"454545","reporte":"000002","numeroSiniestro":"Asistencia","tipoSiniestro":"Robo Total","fechaSiniestro":"28/07/2022 16:40:23","nombreConductor":"José Juan Resendiz Calavera ","causa":"choque","vehiculo":{"descripcion":"MOTOCICLETA VENTO WORKMAN 125 CC","anio":"2022","placa":"123HDF","serie":"1234DFGERS92871WD"},"poliza":{"numeroPoliza":"2345","inciso":"0001","fechaInicioVigencia":"23/03/2022","fechaFinVigencia":"22/03/2023","nombreAsegurado":"Graciela Guzmán Arreola"},"comoOcurrio":"Se cayó y chocó","ubicacion":"Calle Orquideas 27","municipio":"Tampico","estado":"Tamaulipas","estatus":"En requerimiento de información","solucionDevolucion":"sol","motivoDevolucion":"moti","saldoinsoluto":"12.12","motivoRechazo":"rechazadooo","salesforceid":""}';
        req2.httpMethod = 'POST';
        
        Test.startTest();
        DSALES_SiniestroWrapper.siniestroPostResponse response = DSALES_Siniestro.siniestroUpsert();
        //Fin del Caso uno con llamdo body
        
        //Dando nuevo valores context request pasa nuevo caso(2)
        RestContext.request = req2;
        req2.requestBody = Blob.valueof(body2);
        DSALES_SiniestroWrapper.siniestroPostResponse response2 = DSALES_Siniestro.siniestroUpsert();
        //Fin caso 2
        
        //nuevos valore caso 3
        body = '{"business":"serviciosPoliza","listSiniestro":[{"payment_amount":"660000","claimpayment_name":"Coppel","payment_type":"Pago a cuenta Coppel","payment_date":"2022-10-11"}],"company":"coppel","uid":"iszxxzxaxa","reporte":"000002","numeroSiniestro":"Asistencia","tipoSiniestro":"Robo Total","fechaSiniestro":"28/07/2022 16:40:23","nombreConductor":"José Juan Resendiz Calavera ","causa":"choque","vehiculo":{"descripcion":"MOTOCICLETA VENTO WORKMAN 125 CC","anio":"2022","placa":"123HDF","serie":"1234DFGERS92871WD"},"poliza":{"numeroPoliza":"2345","inciso":"0001","fechaInicioVigencia":"23/03/2022","fechaFinVigencia":"22/03/2023","nombreAsegurado":"Graciela Guzmán Arreola"},"comoOcurrio":"Se cayó y chocó","ubicacion":"Calle Orquideas 27","municipio":"Tampico","estado":"Tamaulipas","estatus":"Pagado","solucionDevolucion":"sol","motivoDevolucion":"moti","saldoinsoluto":"12.12","motivoRechazo":"rechazadooo","salesforceid":""}';
        RestContext.request = req2;
        req2.requestBody = Blob.valueof(body);
        DSALES_SiniestroWrapper.siniestroPostResponse response3 = DSALES_Siniestro.siniestroUpsert();
        Test.stopTest();
    }

}