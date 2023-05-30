public without sharing class DSALES_CreateInsurancePolicy {

    public static InsurancePolicy crearPoliza(List<DSALES_VentaSM.DatosParticipante> participantes, DSALES_VentaSMRest.DatosPrepoliza banderas) {
        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Oportunidad__c,DSALES_Motoexterna__c,DSALES_Poliza__c FROM DSALES_InformacionDePago__c WHERE Id=:banderas.idPago WITH SECURITY_ENFORCED];
        Opportunity oportunidad =[SELECT Id,AccountId,SyncedQuoteId FROM Opportunity WHERE Id=:pago.DSALES_Oportunidad__c WITH SECURITY_ENFORCED];
        OpportunityLineItem oliList = [SELECT Id, OpportunityId, Product2.Name FROM OpportunityLineItem WHERE OpportunityId =:oportunidad.Id AND Product2.DSales_Tipo_de_Producto__c ='Seguro' WITH SECURITY_ENFORCED LIMIT 1];
      
        InsurancePolicy poliza = new InsurancePolicy();
        try{
            Account cliente =[SELECT Id,RecordTypeId, Name,FirstName,MiddleName,LastName,Suffix,PersonEmail,Fecha_de_Nacimiento__c,CP_Gender__pc FROM Account WHERE Id=:oportunidad.AccountId WITH SECURITY_ENFORCED];
            Quote cotizacion=[SELECT Id,DSALES_RFC__c FROM Quote WHERE Id=:oportunidad.SyncedQuoteId WITH SECURITY_ENFORCED LIMIT 1 ]; 
            QuoteLineItem partidas =[SELECT Id,DSALES_Tipodeproducto__c,DSALES_NombreProducto__c,dsalesQuoteId__c,dsalesOpcionPago__c FROM QuoteLineItem WHERE QuoteId=:cotizacion.Id AND DSALES_Tipodeproducto__c='Seguro' WITH SECURITY_ENFORCED LIMIT 1 ];
            poliza.DSALES_RFC__c=cotizacion.DSALES_RFC__c;
            //poliza.PolicyName='0001';
            poliza.Name='0001';
            poliza.NameInsuredId=cliente.Id;
            poliza.dsalesEstatusPoliza__c='Prepoliza';
            poliza.DSALES_CorreoElectronico__c=cliente.PersonEmail;
            String recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
            if(cliente.RecordTypeId==recordTypeId){
                poliza.DSALES_Tipodepersona__c='Física';
            }else {
                poliza.DSALES_Tipodepersona__c='Moral';
            }
            poliza.SourceOpportunityId=oportunidad.Id;
            poliza.SourceQuoteId=cotizacion.Id;
            poliza.dsalesFechaDeEmision__c=Date.today();
            poliza.dsalesQuoteId__c=partidas.dsalesQuoteId__c;
            poliza.dsalesBeneficiarioPreferente__c =String.valueOf(banderas.beneficiarioPreferente);
            //poliza.DSALES_Opcionpago__c=partidas.dsalesOpcionPago__c;
            if(oliList!= null){
               poliza.DSALES_Cobertura__c= oliList.Product2.Name;
            }
            if(Schema.sObjectType.InsurancePolicy.isCreateable()) {
                insert poliza;
                DSALES_CrearParticipantesPoliza.crearParticipantes(participantes, poliza.Id,banderas.enviaContratante);
            }else{
                System.debug('Permisos insuficientes para insertar');   
            }
            
        }catch(Exception e){
            System.debug(e.getLineNumber() +':'+ e.getMessage() );
        }
        return poliza;
    }
    
    
    public static void relacionarPolizaAPago(InsurancePolicy poliza){
        try{
            InsurancePolicy polizaActual =[SELECT Id,SourceOpportunityId FROM InsurancePolicy WHERE Id=:poliza.Id WITH SECURITY_ENFORCED];
            List<DSALES_InformacionDePago__c>  pagos =[SELECT Id,DSALES_Oportunidad__c,DSALES_Poliza__c,DSALES_Seguro__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c=:polizaActual.SourceOpportunityId WITH SECURITY_ENFORCED ];
            List<DSALES_InformacionDePago__c> listaParaActualizar = new List<DSALES_InformacionDePago__c>();
            for(DSALES_InformacionDePago__c pago:pagos){
                if(pago.DSALES_Poliza__c==null && pago.DSALES_Seguro__c==true){
                    pago.DSALES_Poliza__c=poliza.Id;
                    listaParaActualizar.add(pago);
                }
            }
            if(DSALES_InformacionDePago__c.SObjectType.getDescribe().isUpdateable()) {
                update listaParaActualizar;
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            }
        }catch(Exception e){
            System.debug(e.getLineNumber()+':'+e.getMessage());
        }
        
    }
    
    public static InsurancePolicy agregarDatosDeActivo(InsurancePolicyAsset activo,String idPoliza){
        InsurancePolicy poliza = new InsurancePolicy();
        if(activo!=null){
            poliza= [SELECT Id,dsalesActivoPolizaSeguro__c,DSALES_Clavevehicular__c,DSALES_Modelo__c,DSALES_Numeroserie__c,	dsalesNumeroDeMotor__c,DSALES_Descripcion__c,
                     DSALES_Servicio__c,DSALES_Placas__c,DSALES_Marca__c,DSALES_Uso__c,DSALES_ClaveAMIS__c
                     FROM InsurancePolicy WHERE Id=:idPoliza WITH SECURITY_ENFORCED];
            
            poliza.dsalesActivoPolizaSeguro__c=activo.Id;
            poliza.DSALES_Clavevehicular__c=activo.DSALES_Clavevehicular__c;
            poliza.DSALES_Modelo__c=activo.DSALES_Modelo__c;
            poliza.DSALES_Numeroserie__c=activo.DSALES_Numeroserie__c;
            poliza.dsalesNumeroDeMotor__c=activo.DSALES_Numeromotor__c;
            poliza.DSALES_Descripcion__c=activo.DSALES_Descripcion__c;
            poliza.DSALES_Servicio__c=activo.DSALES_Servicio__c;
            poliza.DSALES_Placas__c=activo.DSALES_Placas__c;
            poliza.DSALES_Marca__c=activo.DSALES_Marca__c;
            poliza.DSALES_Uso__c=activo.DSALES_Uso__c;
            if(InsurancePolicy.SObjectType.getDescribe().isUpdateable()) {
                update poliza;
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            }
            
            
        }
        return poliza;
    }
    
    public static void cambiarEstatusPoliza(String idPoliza){
        InsurancePolicy poliza=[SELECT Id,DSALES_VigenciacumplidaSM__c,dsalesEstatusPoliza__c,EffectiveDate FROM InsurancePolicy WHERE Id=:idPoliza WITH SECURITY_ENFORCED];
        if(poliza.DSALES_VigenciacumplidaSM__c==true){
            poliza.dsalesEstatusPoliza__c='Vencida';
            if(InsurancePolicy.SObjectType.getDescribe().isUpdateable()) {
                update poliza;
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            }
        }
    }
}