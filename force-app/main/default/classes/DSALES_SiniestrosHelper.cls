public with sharing class DSALES_SiniestrosHelper {
    //public static final String NOMBRE_SERVICIO = 'DSALES_ActualizarEstadoSiniestro';
    
    //@future(callout=true)
    public static void actualizarDatos(String jsonString){//recibo datos de pago
        try{
            System.debug('Actualizar datos1');
            List<ClaimPaymentSummary> listPagos = (List<ClaimPaymentSummary>) JSON.deserialize(jsonString, List<ClaimPaymentSummary>.class);
            System.debug('Actualizar json:'+listPagos);
            List<String> siniestrosId = new List<String>();
            List<String> polizasId = new List<String>();
            for(ClaimPaymentSummary pagos:listPagos){ 
                System.debug('Actualizar datos2');
                siniestrosId.add(pagos.ClaimId);
                //polizasId.add(pagos.Claim.PolicyNumberId);
            }
             
            //se actualiza el siniestro a Pagado
            String query = 'SELECT Id, Name,PolicyNumberId,P_liza__c, DSALES_SiniestroUid__c,DSALES_Reporte__c,IncidentSiteStreet,IncidentSiteState,IncidentSiteCountry, ClaimType, CreatedDate, DSALES_Nombre_conductor__c, DSALES_Causa__c, DSALES_Descripcion__c, DSALES_Ano__c, DSALES_Marca__c, DSALES_Serie__c, InitiationDate, FinalizedDate, Cliente__r.Name, P_liza__r.Name, ClaimReason, DSALES_Estatus__c FROM Claim WHERE Id IN:siniestrosId';       
            List<Claim> listSiniestros = DataBase.query(query);
            //List<String> sss= new List<String>();
            for(Claim c:listSiniestros){
                System.debug('Actualizar datos3');
               	c.DSALES_Estatus__c='Pagado';
                polizasId.add(c.PolicyNumberId);
            }
            List<InsurancePolicy> listToUpdatePoliza = [SELECT Id,ChangeSubtype,DSALES_Estatusdepliza__c,DSALES_Activodeplizadeseguro__c FROM InsurancePolicy WHERE Id IN:polizasId]; 
            System.debug('listToUpdatePoliza :'+listToUpdatePoliza);
            System.debug('listToUpdatePoliza size:'+listToUpdatePoliza.size());
            if(listToUpdatePoliza.size()>0){ 
                for(InsurancePolicy p: listToUpdatePoliza){
                    p.ChangeSubtype='Siniestrada';
                    p.DSALES_Estatusdepliza__c='Cancelada';
                    //p.DSALES_Activodeplizadeseguro__c=null;
                    System.debug('se asignaron los datos');
                }
            }
            
           System.debug('poliza:'+listToUpdatePoliza);
            update listToUpdatePoliza;
            update listSiniestros;
        }catch(Exception e){
            System.debug('Error en linea :'+e.getLineNumber());
            System.debug('mensaje:'+e.getMessage());
        }
    }
    
   
}