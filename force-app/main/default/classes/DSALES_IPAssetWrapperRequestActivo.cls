@RestResource(urlMapping='/insertIPAssetDelivered/*')
global with sharing class DSALES_IPAssetWrapperRequestActivo {
    public static final String NOMBRE_CONTRATANTE =DSALES_Utility.getNombreContratante('dsalesNombre');
    @HttpPost
    global static DSALES_IPAssetWrapper.IPAssetResponse crearActivo(){
        Boolean exito=false;
        String mensaje='';
        Integer codigo;
        String idActivo='';
        final String ProdutoName='Producto';
        DSALES_IPAssetWrapper.IPAssetResponse policyAssetRes= new DSALES_IPAssetWrapper.IPAssetResponse();
        DSALES_IPAssetWrapper.IPAssetResponse response = new DSALES_IPAssetWrapper.IPAssetResponse();
        List<DSALES_IPAssetWrapper.ListaPartidasOportunidad> listaPartidas = new List<DSALES_IPAssetWrapper.ListaPartidasOportunidad>();
        List<DSALES_VentaSMRest.WrapperDatosProductos> productosSincronisados = new List<DSALES_VentaSMRest.WrapperDatosProductos>();
        DSALES_IPAssetWrapper.Seguro seguro = new DSALES_IPAssetWrapper.Seguro();
        DSALES_VentaSM.DatosParaEmitir datos = new  DSALES_VentaSM.DatosParaEmitir();
        List<DSALES_VentaSM.DatosParticipante> participante = new List<DSALES_VentaSM.DatosParticipante>();
        //DSALES_VentaSM.DatosSeguro seguro = new DSALES_VentaSM.DatosSeguro();
        DSALES_VentaSM.DatosVehiculo vehiculo = new DSALES_VentaSM.DatosVehiculo();
        DSALES_VentaSM.DatosParaEmitir responseEmision = new  DSALES_VentaSM.DatosParaEmitir();
        String contratante='';
        Boolean beneficiarioPreferente=false;
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    DSALES_IPAssetWrapper.IPAssetRequest policyAsset = (DSALES_IPAssetWrapper.IPAssetRequest)JSON.deserialize(body, DSALES_IPAssetWrapper.IPAssetRequest.class);
                        insertarActivo(policyAsset);
                        DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Oportunidad__c,DSALES_IDUniversal1__c,DSALES_Poliza__c,DSALES_Poliza__r.Name FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c=:policyAsset.idUniversal WITH SECURITY_ENFORCED];
                        productosSincronisados=DSALES_VentaSMRest.obtenerProductosEnPartidasOportunidad(pago.DSALES_Oportunidad__c);
                        Boolean emitir=condicionesParaEmitir(pago.DSALES_Poliza__c,productosSincronisados);
                        System.debug('Emitir?: '+emitir );
                        if(emitir==true && pago.DSALES_Poliza__r.Name!=DSALES_Utility.SEGURO_PREDETERMINADO){
                            datos=responseEmitir(pago.DSALES_Poliza__c);
                            System.debug('datos principal: '+datos);
                        }
                        
                        exito=true;
                }catch(Exception.JSONException e)
                {
                    exito = false;
                    mensaje = DSALES_Utility.BAD_REQUEST_MSJ;
                    codigo=DSALES_Utility.BAD_REQUEST_CODE;
                    
                }
                catch(Exception e){
                    System.debug('**ERROR**'+e.getLineNumber()+ ': '+e.getMessage());
                    exito = false;
                    mensaje = DSALES_Utility.INTERNAL_ERROR_MSJ;
                    codigo=DSALES_Utility.INTERNAL_ERROR_CODE;
                    
                    
                }
            }
        }

        policyAssetRes.exito=exito;
        policyAssetRes.codigoError=codigo;
        policyAssetRes.mensajeError=mensaje;
        policyAssetRes.listaPartidasOportunidad=productosSincronisados;
        policyAssetRes.datosParaEmitir=datos;
        return policyAssetRes;
       
    }	 
    
    
    global static void insertarActivo(DSALES_IPAssetWrapper.IPAssetRequest policyAsset){
        System.debug('Metodo insertarActivo');
        InsurancePolicyAsset activo  = new InsurancePolicyAsset();
        if(String.isNotEmpty(policyAsset.numeroSerie)){
            DSALES_InformacionDePago__c pago=[SELECT Id,DSALES_Poliza__c,DSALES_Poliza__r.Name,DSALES_Nombre_del_Vendedor__c,DSALES_Motoentregada__c, DSALES_Motoexterna__c,DSALES_Seguro__c,DSALES_Cliente__c FROM DSALES_InformacionDePago__c WHERE DSALES_IDUniversal1__c=:policyAsset.idUniversal WITH SECURITY_ENFORCED LIMIT 1 ];
            asignarDatos(policyAsset,pago,pago.DSALES_Poliza__c);  
            pago.DSALES_Motoentregada__c=true;
            if(DSALES_InformacionDePago__c.SObjectType.getDescribe().isUpdateable()) {
                update pago; 
            }else{
                System.debug('Permisos insuficientes para actualizar');   
            } 
        }
        
    }

    private static InsurancePolicyAsset asignarDatos(DSALES_IPAssetWrapper.IPAssetRequest policyAsset,DSALES_InformacionDePago__c pago, String idPoliza){
        System.debug('Metodo asignarDatos');
        InsurancePolicyAsset activo = new InsurancePolicyAsset();
        activo.DSALES_InformacionPago__c=pago.Id;
        activo.dsalesCliente__c=pago.DSALES_Cliente__c;
        activo.DSALES_Tienda__c=policyAsset.claveTienda;
        activo.DSALES_Colaborador__c=pago.DSALES_Nombre_del_Vendedor__c;
        activo.DSALES_Motoexterna__c=policyAsset.bajoDemanda; 
        activo.DSALES_Valorfactura__c=policyAsset.valorFactura;
        activo.InsurancePolicyId=idPoliza; //póliza
        activo.dsalesEstatus__c='Activo';
        activo.DSALES_Clavevehicular__c=policyAsset.claveVehicular;
        activo.DSALES_Descripcion__c=policyAsset.descripcion;
        activo.DSALES_Modelo__c=policyAsset.modelo;
        activo.DSALES_Marca__c=policyAsset.marca;
        activo.DSALES_Numeromotor__c=policyAsset.numeroMotor;
        activo.DSALES_Numeroserie__c=policyAsset.numeroSerie;
        activo.DSALES_Placas__c=policyAsset.placas;
        activo.DSALES_Servicio__c=policyAsset.servicio;
        activo.DSALES_Uso__c  =policyAsset.uso;
        activo.AssetName=policyAsset.nombreActivo;
        activo.DSALES_emitir_poliza__c=policyAsset.emitirPoliza;   //verificar cuando acntivar para emitir
        if(Schema.sObjectType.InsurancePolicyAsset.isCreateable()) {
            insert activo;
            System.debug('activo creado: '+activo);
            System.debug('pago creado: '+pago.DSALES_Poliza__r.Name);
            if(pago.DSALES_Poliza__r.Name!=DSALES_Utility.SEGURO_PREDETERMINADO){
                DSALES_CreateInsurancePolicy.agregarDatosDeActivo(activo,idPoliza);
            }
            
        }else{
            System.debug('Permisos insuficientes para insertar');
        }
        return activo;
    }   
    
    public static Boolean condicionesParaEmitir(String idPoliza, List<DSALES_VentaSMRest.WrapperDatosProductos> listaIds){
        System.debug('Metodo condicionesParaEmitir');
        List<String> idsPartidas = new List<String>();
        Boolean condicion=true;
        Boolean seMandaEmitir=false;
        InsurancePolicyAsset activo =[SELECT Id,DSALES_emitir_poliza__c,InsurancePolicy.Name FROM InsurancePolicyAsset WHERE InsurancePolicyId=:idPoliza WITH SECURITY_ENFORCED LIMIT 1];
        for(DSALES_VentaSMRest.WrapperDatosProductos prod:listaIds){
            idsPartidas.add(prod.oliId);
        }
        for(OpportunityLineItem partidasSeguro: [SELECT Id,Name, Product2Id, Product2.DSales_Tipo_de_Producto__c, DSALES_Estatus__c
                                FROM OpportunityLineItem WHERE Id IN:idsPartidas AND Product2.DSales_Tipo_de_Producto__c=:'Seguro' WITH SECURITY_ENFORCED]){
            if(partidasSeguro.DSALES_Estatus__c=='Devuelto' || partidasSeguro.DSALES_Estatus__c=='Cancelado' ){
                condicion=false;                    
            }                                             
        }
        if(activo!=null && activo.InsurancePolicy.Name!=DSALES_Utility.SEGURO_PREDETERMINADO){
            if(activo.DSALES_emitir_poliza__c==true && condicion==true){
                seMandaEmitir=true;
            }
        }
    
        return seMandaEmitir;  
    }

    public static DSALES_VentaSM.DatosParaEmitir responseEmitir(String polizaId){
        DSALES_VentaSM.DatosParticipante participante = new DSALES_VentaSM.DatosParticipante();
        DSALES_VentaSM.DatosSeguro seguro = new DSALES_VentaSM.DatosSeguro();
        DSALES_VentaSM.DatosVehiculo vehiculo = new DSALES_VentaSM.DatosVehiculo();
        DSALES_VentaSM.DatosParaEmitir datos = new DSALES_VentaSM.DatosParaEmitir();
        DSALES_InformacionDePago__c pago= [SELECT Id,dsalesContratante__c FROM DSALES_InformacionDePago__c WHERE DSALES_Poliza__c=:polizaId  WITH SECURITY_ENFORCED LIMIT 1];
        Insurancepolicy poliza =[SELECT Id,DSALES_Modelo__c,dsalesQuoteId__c,DSALES_Uso__c,PlanType,DSALES_Tipovehiculo__c,DSALES_Servicio__c,DSALES_Placas__c,DSALES_Numeroserie__c,SourceQuoteId,
                                DSALES_Aseguradora__c,DSALES_Cobertura__c,dsalesFechaDeEmision__c,EffectiveDate,DSALES_Negocio__c,DSALES_Opcionpago__c,dsalesBeneficiarioPreferente__c FROM Insurancepolicy WHERE Id=:polizaId WITH SECURITY_ENFORCED LIMIT 1];
        System.debug('poliza en activo w:'+poliza);
        Quote cotizacion =[SELECT Id,dsalesIdDeVehiculo__c,dsalesCodigoDePromocion__c,DSALES_IDdelasociado__c,DSALES_RFC__c,dsalesFechaDeComienzoDePoliza__c FROM Quote WHERE Id=:poliza.SourceQuoteId WITH SECURITY_ENFORCED LIMIT 1];
         System.debug('cot en activo w:'+cotizacion);
        QuoteLineItem partida =[SELECT Id,dsalesQuoteId__c,Product2.Name,	DSALES_TrackingID__c,dsalesOpcionPago__c FROM QuoteLineItem WHERE QuoteId=:cotizacion.Id AND DSALES_Tipodeproducto__c=:'Seguro' WITH SECURITY_ENFORCED LIMIT 1];   
        QuoteLineItem moto =[SELECT Id,UnitPrice FROM QuoteLineItem WHERE QuoteId=:cotizacion.Id AND DSALES_Tipodeproducto__c=:'Producto' WITH SECURITY_ENFORCED LIMIT 1];   
        DSALES_VentaSM.DatosContratante contratante = new DSALES_VentaSM.DatosContratante();
        DSALES_VentaSM.DatosConductor conductor = new DSALES_VentaSM.DatosConductor();
        List<InsurancePolicyParticipant> participantesAgregados= [SELECT Id,PrimaryParticipantAccountId,RelatedParticipantAccountId,Role,dsalesNombre__c,dsalesPrimerApellido__c,dsalesSegundoApellido__c,dsalesNumeroTelefono__c,dsalesCorreoElectronico__c,dsalesGenero__c,
                                                                dsalesFechaNacimiento__c,dsalesRfc__c,dsalesCodigoPostal__c,dsalesClaveEstado__c,dsalesCalle__c,dsalesNumeroExterior__c,InsurancePolicyId FROM InsurancePolicyParticipant 
                                                                WHERE InsurancePolicyId=:polizaId WITH SECURITY_ENFORCED];
        if(participantesAgregados!=null){
            contratante=buscarContratante(participantesAgregados);
            conductor=buscarConductor(participantesAgregados);
        }
        if(moto!=null){
            if(partida!=null && partida.Product2.Name!=Label.dsalesSeguro_RC){
                seguro.sumaAsegurada=Integer.valueOf(moto.UnitPrice);
                seguro.valorFactura='true';
            } 
            else{
                seguro.sumaAsegurada=0;
                seguro.valorFactura='true';
            }  
        }
        
        //listaParticipantes.add(contratante);
        //System.debug('lista Participantes:'+listaParticipantes);
        seguro.aseguradora=poliza.DSALES_Aseguradora__c;
        seguro.codigoPromocion=cotizacion.dsalesCodigoDePromocion__c;
        seguro.fechaEmision=poliza.dsalesFechaDeEmision__c;
        seguro.fechaInicio=cotizacion.dsalesFechaDeComienzoDePoliza__c;
        seguro.idAsociado=cotizacion.DSALES_IDdelasociado__c;
        seguro.negocio=poliza.DSALES_Negocio__c;
        seguro.opcionPago=partida.dsalesOpcionPago__c;
        seguro.paquete=poliza.DSALES_Cobertura__c;
        seguro.planPago='';//valor fijo
        seguro.quote_id=poliza.dsalesQuoteId__c;
        seguro.tarjetaPago='';//valor fijo
        seguro.trackingId=partida.DSALES_TrackingID__c;
        vehiculo.idVehiculo=cotizacion.dsalesIdDeVehiculo__c;
        vehiculo.modelo=poliza.DSALES_Modelo__c;
        vehiculo.numeroSerie=poliza.DSALES_Numeroserie__c;
        vehiculo.placas=poliza.DSALES_Placas__c;
        vehiculo.sevicio=poliza.DSALES_Servicio__c;
        vehiculo.tipo = poliza.DSALES_Tipovehiculo__c;
        vehiculo.uso=poliza.DSALES_Uso__c;

        datos.datosSeguro=seguro;
        datos.datosVehiculo=vehiculo;
        datos.datosConductor=conductor;
        datos.datosContratante=contratante;
        datos.beneficiarioPreferente=poliza.dsalesBeneficiarioPreferente__c;
        datos.contratante=pago.dsalesContratante__c;
        System.debug('datos: '+datos);
        return datos;
    }
    private static  DSALES_VentaSM.DatosContratante buscarContratante(List<InsurancePolicyParticipant> participantesAgregados){
        DSALES_VentaSM.DatosContratante datosContratante = new DSALES_VentaSM.DatosContratante();
        String contratanteCuenta='';
        for(InsurancePolicyParticipant part :participantesAgregados){
            System.debug('participante:'+part );
            if(part.Role==DSALES_Utility.FIGURA_CONTRATANTE && part.RelatedParticipantAccountId!=null){
                contratanteCuenta=part.RelatedParticipantAccountId;
            }
            else if(part.Role==DSALES_Utility.FIGURA_CONTRATANTE && part.RelatedParticipantAccountId==null){
                datosContratante.telefono=part.dsalesNumeroTelefono__c;
                datosContratante.correoElectronico=part.dsalesCorreoElectronico__c;
                datosContratante.genero=part.dsalesGenero__c;
                datosContratante.fechaNacimiento=part.dsalesFechaNacimiento__c;
                datosContratante.rfc=part.dsalesRfc__c;
                datosContratante.codigoPostal=Integer.valueOf(part.dsalesCodigoPostal__c);
                datosContratante.calle=part.dsalesCalle__c;
                datosContratante.codigoEstado=part.dsalesClaveEstado__c;
                //datosContratante.codigoCiudad=part.codigoCiudad;
                //datosContratante.codigoColonia=part.codigoColonia;
                //datosContratante.numeroInterior=part.numeroInterior;
                //datosContratante.numeroExterior=part.dsalesNumeroExterior__c;
                datosContratante.contratante=part.dsalesNombre__c +''+ part.dsalesPrimerApellido__c + ''+ part.dsalesSegundoApellido__c;
            }
            
        }
        if(!String.isEmpty(contratanteCuenta)){
            Account contratante =[SELECT Id,FirstName,dsalesCodigoEstado__c,dsalesRfc__c,LastName,Suffix,PersonMobilePhone,PersonEmail,CP_Gender__pc,PersonBirthdate,BillingStreet,BillingCity,BillingState,BillingPostalCode,dsalesNumeroInterior__c,dsalesNumeroExterior__c,CP_BillingStateCode__c,dsalesCodigoColonia__c,dsalesSegundoCorreo__c,dsalesNacionalidadSociedad__c,dsalesFechaConstitucion__c,dsalesGiroComercial__c,dsalesTipoPersona__c,dsalesNombreApoderadoLegal__c,dsalesActividad__c 
            FROM Account WHERE Id=:contratanteCuenta  WITH SECURITY_ENFORCED LIMIT 1];
            datosContratante.rfc=contratante.dsalesRfc__c;
            datosContratante.telefono =contratante.PersonMobilePhone;
            datosContratante.correoElectronico =contratante.PersonEmail;
            datosContratante.genero =contratante.CP_Gender__pc;
            datosContratante.fechaNacimiento =contratante.PersonBirthdate;
            datosContratante.calle =contratante.BillingStreet;
            datosContratante.codigoCiudad =contratante.BillingCity;
            datosContratante.codigoPostal =Integer.valueOf(contratante.BillingPostalCode);
            datosContratante.numeroInterior= String.valueOf(contratante.dsalesNumeroInterior__c);
            datosContratante.numeroExterior =String.valueOf(contratante.dsalesNumeroExterior__c);
            datosContratante.codigoEstado =String.valueOf(contratante.dsalesCodigoEstado__c); 
            datosContratante.codigoColonia=String.valueOf(contratante.dsalesCodigoColonia__c);
            datosContratante.segundoCorreoContratante=contratante.dsalesSegundoCorreo__c;
            datosContratante.nacionalidadSociedad=contratante.dsalesNacionalidadSociedad__c;
            datosContratante.fechaConstitucion=contratante.dsalesFechaConstitucion__c;
            datosContratante.giroComercial=contratante.dsalesGiroComercial__c;
            datosContratante.tipoPersona=contratante.dsalesTipoPersona__c;
            datosContratante.nombreApoderadoLegal=contratante.dsalesNombreApoderadoLegal__c;
            datosContratante.contratante=contratante.FirstName +''+ contratante.LastName + ''+ contratante.Suffix;
            datosContratante.actividad=contratante.dsalesActividad__c; 
        }
        return datosContratante;
    }
    private static DSALES_VentaSM.DatosConductor buscarConductor(List<InsurancePolicyParticipant> participantesAgregados){
        System.debug('role:'+participantesAgregados);
        DSALES_VentaSM.DatosContratante datosContratante = new DSALES_VentaSM.DatosContratante();
        DSALES_VentaSM.DatosConductor datosConductor = new DSALES_VentaSM.DatosConductor();
        List<DSALES_VentaSM.DatosParticipante> listaParticipantes = new List<DSALES_VentaSM.DatosParticipante>();
        Set<String> partiList= new Set<String>();
        String idContratante='';
        String idConductor='';
        String idPolizaConductor='';
        for(InsurancePolicyParticipant part :participantesAgregados){
            if(part.Role==DSALES_Utility.FIGURA_CONDUCTOR && part.PrimaryParticipantAccountId!=null){
                idConductor=part.PrimaryParticipantAccountId;
                idPolizaConductor=part.InsurancePolicyId;
                
            }
        }
        Account conductor =[SELECT Id,FirstName,LastName,Suffix,PersonMobilePhone,PersonEmail,CP_Gender__pc,PersonBirthdate,BillingStreet,BillingCity,BillingState,BillingPostalCode,dsalesNumeroInterior__c,dsalesNumeroExterior__c,CP_BillingStateCode__c,dsalesCodigoColonia__c FROM Account WHERE Id=:idConductor WITH SECURITY_ENFORCED LIMIT 1];
        Insurancepolicy poliza=[SELECT Id,SourceQuoteId FROM InsurancePolicy WHERE Id=:idPolizaConductor WITH SECURITY_ENFORCED LIMIT 1];
        Quote cotConductor =[SELECT Id,DSALES_RFC__c FROM Quote WHERE Id=:poliza.SourceQuoteId WITH SECURITY_ENFORCED LIMIT 1];
		datosConductor.rfc=cotConductor.DSALES_RFC__c;
        datosConductor.nombre =conductor.FirstName;
        datosConductor.apellidoPaterno=conductor.LastName;
        datosConductor.apellidoMaterno =conductor.Suffix ;
        datosConductor.telefono =conductor.PersonMobilePhone;
        datosConductor.correoElectronico =conductor.PersonEmail;
        datosConductor.genero =conductor.CP_Gender__pc;
        datosConductor.fechaNacimiento =conductor.PersonBirthdate;
        datosConductor.calle =conductor.BillingStreet;
        datosConductor.codigoCiudad =conductor.BillingCity;
        datosConductor.codigoPostal =Integer.valueOf(conductor.BillingPostalCode);
        datosConductor.numeroInterior= String.valueOf(conductor.dsalesNumeroInterior__c);
        datosConductor.numeroExterior =String.valueOf(conductor.dsalesNumeroExterior__c);
        datosConductor.codigoEstado =String.valueOf(conductor.CP_BillingStateCode__c); 
        datosConductor.codigoColonia  =String.valueOf(conductor.dsalesCodigoColonia__c); 
       
        return datosConductor;
    }
        
}