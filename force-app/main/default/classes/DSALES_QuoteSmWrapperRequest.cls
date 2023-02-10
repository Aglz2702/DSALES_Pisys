@RestResource(urlMapping='/insertQuoteSM/*')
global class DSALES_QuoteSmWrapperRequest {
    public static final String NOMBRE_SERVICIO = 'DSALES_QuoteSM';
    public static final String valor = 'RC'; //nombre campaña
    public static final String tipo = 'Seguro gratis'; //tipo de campaña
    public static final String rc = 'RC Seguro de Moto';
    public static final String amp = 'AMP Seguro de Moto';
    @HttpPost
    global static DSALES_QuoteSmWrapper.RespuestaParaNpv createQuoteSM(){
        String numeroCliente = DSALES_Utility.NUMERO_CLIENTE_GENERICO;
        String message = '';
        String trackinId='';
        Account client = new Account();
        Opportunity oppor = new Opportunity();
        Quote cotiza = new Quote();
        List<DSALES_QuoteSmWrapper.RespuestaPlazos> plazos = new List<DSALES_QuoteSmWrapper.RespuestaPlazos>();
        DSALES_QuoteSmWrapper.RespuestaPlazos moto = new DSALES_QuoteSmWrapper.RespuestaPlazos();
        DSALES_QuoteSmWrapper.QuoteSmRequest data = new DSALES_QuoteSmWrapper.QuoteSmRequest();
        DSALES_QuoteSmWrapper.respuestaDelProveedor respuestaDeProveedor = new DSALES_QuoteSmWrapper.respuestaDelProveedor();
        DSALES_ListaNegraWrapper.responseListaNegra respuestaListaNegra = new DSALES_ListaNegraWrapper.responseListaNegra();
        Boolean listaNegra = false;
        Integer errorCode;
        Boolean succes = true;
        if(RestContext.request != null){
            String body = System.RestContext.request.requestBody.toString();
            if(String.isNotBlank(body)){
                try{
                    data = (DSALES_QuoteSmWrapper.QuoteSmRequest)JSON.deserialize(body, DSALES_QuoteSmWrapper.QuoteSmRequest.class);
                    String nombreCompleto=data.nombre;
                    if(data.apellido_materno!=null){
                        nombreCompleto += ' ' +data.apellido_materno;  
                      }
                      nombreCompleto += ' ' +data.apellido_paterno; 
                    String rfc = DSALES_ConsultaListaNegra.getRFC(data.nombre, data.apellido_materno, data.apellido_paterno, data.apellido_materno, data.fecha_nacimiento);
                    respuestaListaNegra = DSALES_ConsultaListaNegra.callWebService(rfc, nombreCompleto);
                    if(respuestaListaNegra.estatus =='true'){
                        listaNegra = true;
                        message = 'Esta en la Lista negra';
                    }            
                    DSALES_QuoteSmWrapper.QuotePostProvedor datosEnviar = new DSALES_QuoteSmWrapper.QuotePostProvedor();
                    if(data.sku!=''){
                        Product2 temporal = [SELECT Id,DSALES_vehculo__c, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:data.sku LIMIT 1];
                        data.id_vehiculo=temporal.DSALES_vehculo__c;  
                    }
                    datosEnviar.business = Label.DSALES_business;
                    datosEnviar.insurance = Label.DSALES_NombreAseguradora; //sales-fijo
                    datosEnviar.contact_name = data.nombre + data.apellido_paterno;//combinacion
                    datosEnviar.contact_method = Label.DSALES_ContactMethod;//sales-fijo
                    datosEnviar.contact_phone = data.telefono_celular;
                    datosEnviar.contact_email = data.correo_electronico;
                    datosEnviar.contact_gender = data.genero_contacto;
                    datosEnviar.contact_birth_date = data.fecha_nacimiento.format();
                    datosEnviar.contact_zip_code = data.codigo_postal;
                    datosEnviar.contact_now = true;//fijo-sales
                    datosEnviar.vehicle_id = data.id_vehiculo;
                    datosEnviar.vehicle_service = Label.DSALES_vehicleService;//fijo-sales
                    datosEnviar.vehicle_use = data.tipo_uso; //Nuevo
                    datosEnviar.vehicle_type = data.tipo_vehiculo; //Nuevo
                    datosEnviar.plazo = data.plazo_cotizar; //Nuevo hU 001
                    datosEnviar.payment_option = data.opcion_pago;
                    datosEnviar.packagge = '';
                    datosEnviar.promotion_code='0';//fijo
                    datosEnviar.associate_id='0';//fijo
                    date aux = date.today();
                    aux = date.newInstance(aux.year(), aux.month(), aux.day());
                    datosEnviar.quote_date = aux.format(); //cotiza.DSALES_Fechadecreacionpresupuesto__c.format();//fecha creacion-sales
                    datosEnviar.start_at = data.fecha_inicio.format(); //Nuevo revisar
                    datosEnviar.listaPlazos = plazosActivos(data.plazo_cotizar);
                    if(!listaNegra){
                        respuestaDeProveedor = crearQuoteSm(datosEnviar);
                    }
  
                    Account UniversalAccount = [Select Id from Account WHERE DSALES_ClienteCoppel__c = :numeroCliente LIMIT 1];
                    Tienda__c tienda = [Select Id from Tienda__c WHERE DSales_TiendaID__c =: data.id_tienda LIMIT 1];
                    Id ClienteId=null; 
                    if(data.numero_cliente == null || data.numero_cliente=='' ||data.numero_cliente==numeroCliente ){
                        List<Account> resul = [Select Id, FirstName, Suffix, LastName, Fecha_de_Nacimiento__c, Phone, PersonEmail from Account WHERE FirstName=:data.nombre AND Suffix=:data.apellido_materno AND LastName=:data.apellido_paterno];
                        if(resul.size() == 1){
                            ClienteId = resul[0].Id;
                            oppor = creaOportunidad(data, ClienteId, resul[0].FirstName, resul[0].Suffix, resul[0].LastName,tienda);
                            cotiza = crearCotizacion(data, oppor.Id, resul[0].FirstName,  resul[0].Suffix, resul[0].LastName, tienda,listaNegra);
                            plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos, data.sku,listaNegra); 
                            moto = creaPartidaM(cotiza,data.sku,listaNegra,data.precioProducto);
                        }
                        else{
                            Boolean SinCoincidenciaCuenta = true;
                            if(resul.size() > 1){                
                                for(Account CuentaSimilare: resul){
                                    if(CuentaSimilare.PersonEmail == data.correo_electronico || CuentaSimilare.Phone == data.telefono_celular){
                                        ClienteId = CuentaSimilare.Id;
                                        SinCoincidenciaCuenta = false;
                                        oppor = creaOportunidad(data, ClienteId, data.nombre, data.apellido_materno, data.apellido_paterno, tienda);
                                        cotiza = crearCotizacion(data, oppor.Id, data.nombre, data.apellido_materno, data.apellido_paterno, tienda,listaNegra);
                                        plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra);                                       
                                        moto = creaPartidaM(cotiza,data.sku,listaNegra,data.precioProducto);
                                        break;
                                    }
                                }                         
                            }
                            if(resul.size() == 0 || SinCoincidenciaCuenta==true){
                                ClienteId = UniversalAccount.Id; 
                                oppor = creaOportunidad(data, ClienteId, data.nombre, data.apellido_materno, data.apellido_paterno, tienda);
                                cotiza = crearCotizacion(data, oppor.Id, data.nombre, data.apellido_materno, data.apellido_paterno, tienda,listaNegra);
                                plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra);
                                moto = creaPartidaM(cotiza,data.sku,listaNegra,data.precioProducto);
                            }
                        }     
                    }else{
                            List<Account> result = [Select Id,FirstName,Suffix,LastName from Account WHERE CP_WalletCustomerNumber__c =:Decimal.valueOf(data.numero_cliente)];
                            if(result.size() == 0){
                                client = creaCliente(data);
                                ClienteId = client.Id;
                                oppor = creaOportunidad(data, ClienteId, data.nombre, data.apellido_materno, data.apellido_paterno,tienda);
                                cotiza = crearCotizacion(data, oppor.Id, client.FirstName,  client.Suffix, client.LastName, tienda,listaNegra);
                                plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra);
                                moto = creaPartidaM(cotiza,data.sku,listaNegra,data.precioProducto);
                            }else{
                                ClienteId = result[0].Id;
                                oppor = creaOportunidad(data, ClienteId, result[0].FirstName, result[0].Suffix, result[0].LastName,tienda);
                                cotiza = crearCotizacion(data, oppor.Id, result[0].FirstName,  result[0].Suffix, result[0].LastName, tienda,listaNegra);
                                plazos = creaPlazos(cotiza, respuestaDeProveedor.plazos,data.sku,listaNegra);
                                moto = creaPartidaM(cotiza,data.sku,listaNegra,data.precioProducto);
                            }       
                    }
                }catch(Exception.JSONException jsonException){
                    message = DSALES_Utility.BAD_REQUEST_MSJ;
                    errorCode = DSALES_Utility.BAD_REQUEST_CODE;
                    succes = false;      
                }catch(Exception e){
                    //ver error en la linea message = e.getMessage()+'Linea: '+e.getLineNumber();
                    message = DSALES_Utility.INTERNAL_ERROR_MSJ;
                    message = e.getMessage()+'Linea: '+e.getLineNumber();
                    errorCode = DSALES_Utility.INTERNAL_ERROR_CODE;
                    succes = false;
                }
            }
        }
        //llama a inter con datos
        
        
        DSALES_QuoteSmWrapper.RespuestaParaNpv response = new DSALES_QuoteSmWrapper.RespuestaParaNpv();
        DSALES_QuoteSmWrapper.ReceiptEspa traduccion = new DSALES_QuoteSmWrapper.ReceiptEspa();
        response.mensaje =  message;
        response.codigo_error = errorCode;
        response.success = succes;
        response.idCotizacion = cotiza.Id;
        response.Idoportunidad = oppor.Id;
        //response.TrackingId = respuestaDeProveedor.tracking_id;
        response.listaNegra = listaNegra;
        response.listaSeguros = plazos;
        if(data.sku!=null && data.sku!=''){
            response.listaproducto = moto;
            response.campanias = buscaCampanias(data.sku);       
        }
        return response;
    }
    public static List<DSALES_QuoteSmWrapper.Campanias> buscaCampanias(String sku){
        List<DSALES_QuoteSmWrapper.Campanias> listaCampanias = new List<DSALES_QuoteSmWrapper.Campanias>();
        try{
            Product2 productoMoto = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku LIMIT 1];
            List<DSALES_AsociacionCampanias__c> lista = [SELECT Name, DSALES_Campania__c, DSALES_Producto__c FROM DSALES_AsociacionCampanias__c WHERE DSALES_Producto__c =:productoMoto.Id];
            for(DSALES_AsociacionCampanias__c item:lista){
                Campaign aux = [SELECT Name, DSALES_Tipodecapana__c, Description FROM Campaign WHERE Id =: item.DSALES_Campania__c];
                DSALES_QuoteSmWrapper.Campanias aux2 = new DSALES_QuoteSmWrapper.Campanias();
                aux2.nombre = aux.Name;
                aux2.tipoCampana = aux.DSALES_Tipodecapana__c;
                aux2.descripcion = aux.Description;
                listaCampanias.add(aux2);
            }
        }catch(Exception e){
            System.debug('No Se encontraron Campanias para el SKU');        
        }    
        return listaCampanias;
    }
    public static List<DSALES_QuoteSmWrapper.Plazo> plazosActivos(String plazoMaximo){
        List<DSALES_QuoteSmWrapper.Plazo> plazosSeguros = new List<DSALES_QuoteSmWrapper.Plazo>();
        List<Plazo__c> lista;
        try{
            Product2 seguro = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Name=:rc LIMIT 1];
            lista = [SELECT Name, Dsales_Plazo__c, DSALES_Seguro__c FROM Plazo__c WHERE Dsales_Plazo__c<=:plazoMaximo AND DSALES_Activo__c = true AND DSALES_Seguro__c =:seguro.Id];        
            for(Plazo__c item:lista){
                DSALES_QuoteSmWrapper.Plazo aux = new DSALES_QuoteSmWrapper.Plazo();
                aux.producto = seguro.Name;
                aux.plazo = item.Dsales_Plazo__c;
                plazosSeguros.add(aux);             
            }
            seguro = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Name=:amp LIMIT 1];
            lista = [SELECT Dsales_Plazo__c, DSALES_Seguro__c FROM Plazo__c WHERE Dsales_Plazo__c<=:plazoMaximo AND DSALES_Activo__c = true AND DSALES_Seguro__c =:seguro.Id];
            for(Plazo__c item:lista){
  			   	DSALES_QuoteSmWrapper.Plazo aux = new DSALES_QuoteSmWrapper.Plazo();
               	aux.producto = seguro.Name;
               	aux.plazo = item.Dsales_Plazo__c;
               	plazosSeguros.add(aux);              
            }
        }
        catch(Exception e){
            System.debug('No Se encontraron plazos con las condiciones');        
        }
        return plazosSeguros;
    }
    
    public static DSALES_QuoteSmWrapper.respuestaDelProveedor crearQuoteSm(DSALES_QuoteSmWrapper.QuotePostProvedor obj){
        String body = JSON.serialize(obj);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = DSALES_Utility.getEndpoint(NOMBRE_SERVICIO);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
            DSALES_QuoteSmWrapper.respuestaDelProveedor respuesta = (DSALES_QuoteSmWrapper.respuestaDelProveedor) JSON.deserialize(response.getbody(), DSALES_QuoteSmWrapper.respuestaDelProveedor.class);
            return respuesta;     
        }else{
            System.debug('___Fallo____: comuncacion: ' + response.getBody());
            return null;
        }     
    }

    public static Account creaCliente (DSALES_QuoteSmWrapper.QuoteSmRequest data){
        Account cliente = new Account();
        cliente.CP_WalletCustomerNumber__c = Decimal.valueOf(data.numero_cliente);
        cliente.FirstName = data.nombre;
        cliente.LastName = data.apellido_paterno;
        cliente.Suffix = data.apellido_materno;
        cliente.PersonBirthdate = data.fecha_nacimiento;
        cliente.PersonEmail = data.correo_electronico;
        cliente.AccountNumber = data.numero_cliente;
        cliente.PersonMobilePhone = data.telefono_celular;
        insert cliente;
        return cliente;
    }

    public static Opportunity creaOportunidad (DSALES_QuoteSmWrapper.QuoteSmRequest data, Id clienteId, String FirstName,String Suffix, String LastName,Tienda__c tienda){
        Opportunity oppor = new Opportunity();
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seguro de Moto').getRecordTypeId();
        Pricebook2 precioLista = [SELECT id,Name FROM Pricebook2 WHERE Name= 'Standard Price Book' and IsActive=true LIMIT 1];
        oppor.AccountId = clienteId;
        oppor.Name = FirstName;
        if(data.apellido_materno != null ){
            oppor.Name+=' ' +data.apellido_materno;
        }
        oppor.Name+=' '+LastName;
        oppor.CloseDate = date.today()+30;
        oppor.StageName = 'Nuevo';
        oppor.RecordTypeId = recordTypeId;
        oppor.DSALES_Tiend__c = tienda.Id;
        oppor.Pricebook2Id = precioLista.Id;
        insert oppor;
        return oppor;
    }
    
    public static Quote crearCotizacion (DSALES_QuoteSmWrapper.QuoteSmRequest data, Id oportunidadId, String FirstName,String Suffix, String LastName, Tienda__c tienda, Boolean listaNegra){
        Quote cotiza = new Quote();
        String recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Venta de Seguro de Motos').getRecordTypeId();
        cotiza.Name = FirstName;
        if(data.apellido_materno != null ){
            cotiza.Name+=' '+data.apellido_materno + ' '+LastName;
        }
        else{
            cotiza.Name+= ' '+LastName;
        }
        DSALES_TipodeUso__c tipoUso = [Select Id from DSALES_TipodeUso__c WHERE Name =:data.tipo_uso LIMIT 1];
        DSALES_Tipodevehculo__c tipoVehiculo = [Select Id from DSALES_Tipodevehculo__c WHERE Name =: data.tipo_vehiculo LIMIT 1];
        cotiza.OpportunityId = oportunidadId;
        //cotiza.DSALES_FormadePago__c = data.method_payment;
        cotiza.DSales_ID_Tienda__c = data.id_tienda;
        cotiza.DSales_Tienda__c = tienda.Id;
        cotiza.ExpirationDate = date.today()+30;
        cotiza.RecordTypeId = recordTypeId;
        date aux = date.today();
        cotiza.DSALES_Fechadecreacionpresupuesto__c = date.newInstance(aux.year(), aux.month(), aux.day());
        cotiza.Lista_negra__c = listaNegra;
        cotiza.Motivo_de_lista_negra__c= 'Sin Definir';
        cotiza.Phone = data.telefono_celular;
        cotiza.DSALES_Fechadenacimiento__c = data.fecha_nacimiento;
        cotiza.DSALES_Cdigopostal__c = data.codigo_postal;
        cotiza.DSALES_IDdelvehculo__c = data.id_vehiculo;
        cotiza.DSALES_Opcindepago__c = data.opcion_pago;
        cotiza.DSALES_Cobertura__c = '';
        cotiza.DSales_Vendedor__c = data.nombre_vendedor;
        cotiza.DSALES_Gnero__c = data.genero_contacto;
        cotiza.DSALES_Fechadecomienzodepliza__c = data.fecha_inicio;
        cotiza.Email = data.correo_electronico;
        cotiza.DSALES_TipoUso__c = tipoUso.Id;
        cotiza.DSALES_Tipodeveihculo__c = tipoVehiculo.Id;
        cotiza.DSALES_RFC__c = data.rfc;
        cotiza.DSALES_Plazoacotizar__c= decimal.valueOf(data.plazo_cotizar);
        insert cotiza;
        return cotiza;
    }
    
    public static QuoteLineItem creaPartida(String seguro, Quote cotiza, DSALES_QuoteSmWrapper.ArmadoMuleSoft data, String sku){
            Product2 producto = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE Name=:seguro LIMIT 1];
            PricebookEntry precio = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id =:producto.Id LIMIT 1];
        	Plazo__c plazo = [SELECT Id, Name, DSALES_Activo__c, DSALES_Seguro__r.Name FROM Plazo__c WHERE DSALES_Seguro__r.Name =:seguro AND Name=:data.plazo AND DSALES_Activo__c = true];     	
        	QuoteLineItem partida = new QuoteLineItem();
            partida.QuoteId = cotiza.Id;
            partida.PricebookEntryId = precio.Id;
            partida.Product2Id = precio.Product2Id;
            partida.Quantity = 1;
            partida.UnitPrice = precio.UnitPrice;
            partida.DSALES_Fechadeinicio__c = Date.valueOf(data.data.receipts[0].start_date);
            partida.DSALES_Fechadetermino__c = Date.valueOF(data.data.receipts[0].end_date);
            partida.DSALES_Primaneta__c = decimal.valueOf(data.data.insurance_premium.net_premium);
            partida.UnitPrice = decimal.valueOf(data.data.receipts[0].total_premium);
            partida.DSALES_Derechosdepliza__c = decimal.valueOf(data.data.insurance_premium.right);
            partida.DSALES_Gastosdeoperacindelrecibo__c = decimal.valueOf(data.data.insurance_premium.surcharge);
            partida.DSALES_Impuestos__c = decimal.valueOf(data.data.insurance_premium.tax);
            partida.DSALES_TrackingID__c = data.tracking_id;
        	partida.DSALES_Plazo__c = plazo.Id;
        	partida.DSALES_Comision__c = decimal.valueOf(data.data.insurance_premium.commission);
            partida.DSALES_Recargos__c = decimal.valueOf(data.data.receipts[0].recharge);
        	partida.DSALES_Descripcion__c='Esta cobertura ampara la responsabilidad civil por el tránsito de vehículos en territorio nacional, en que incurra el Asegurado o cualquier persona que con consentimiento del Asegurado use o posea el vehículo descrito en la Póliza con el límite de responsabilidad establecido en la misma, siempre que a consecuencia de dicho uso o posesión, cause a Terceros daños materiales en sus bienes, lesiones corporales, incapacidades temporales y/o permanentes o la muerte, distintos de los ocupantes de dicho vehículo, que considera la Responsabilidad Civil a que se refiere el artículo 63 Bis de la Ley de Caminos, Puentes y Autotransporte Federal.';
        	partida.DSALES_Segurogratis__c = Campana(producto.Name, sku);
            return partida;
    }
    public static Boolean Campana2(String seguro, String tipo, String sku){
        Boolean condicion = false;  
        if(sku!=null && sku!=''){
            Product2 producto = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku LIMIT 1];
            List <DSALES_AsociacionCampanias__c> listaCampanas = [SELECT Name, DSALES_Campania__c, DSALES_Producto__c FROM DSALES_AsociacionCampanias__c WHERE DSALES_Producto__c =:producto.Id];
            for(DSALES_AsociacionCampanias__c asoCampana:listaCampanas){         
                //Campaign aux = [SELECT Id, Name, IsActive, DSALES_Tipodecapana__c FROM Campaign WHERE Name=:valor];             
                Campaign aux = [SELECT Id, Name, IsActive, DSALES_Tipodecapana__c FROM Campaign WHERE Id=:asoCampana.DSALES_Campania__c];             
                if(aux!=null){
                    if(aux.IsActive==true && aux.DSALES_Tipodecapana__c==tipo){
                        condicion = true;           
                    }
                }  
        	}         
        }  
        return condicion;
    }
    
    public static Boolean Campana(String seguro,String sku){
        Boolean condicion = false;  
        if(sku!=null && sku!=''){
            Product2 producto = [SELECT Id, Name, StockKeepingUnit,DSales_Tipo_de_Producto__c, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku LIMIT 1];        
            if(seguro == rc){               
            	List <DSALES_AsociacionCampanias__c> listaCampanas = [SELECT Name, DSALES_Campania__c, DSALES_Producto__c,DSALES_Activo__c FROM DSALES_AsociacionCampanias__c WHERE DSALES_Producto__c =:producto.Id AND DSALES_Activo__c=true];
                for(DSALES_AsociacionCampanias__c asoCampana:listaCampanas){                   
                	Campaign aux = [SELECT Id, Name, IsActive, DSALES_Tipodecapana__c FROM Campaign WHERE Id=:asoCampana.DSALES_Campania__c];             
                    if(aux!=null){
                        if(aux.Name == valor && aux.Id== asoCampana.DSALES_Campania__c && aux.IsActive==true && aux.DSALES_Tipodecapana__c==tipo){
                            condicion = true;           
                        }
                    }    
        		}
            }
        }  
        return condicion;
    }
    public static DSALES_QuoteSmWrapper.RespuestaPlazos creaPartidaM(Quote cotiza, String sku, Boolean ListaNegra, String precio){      
        DSALES_QuoteSmWrapper.RespuestaPlazos motoVacia = new DSALES_QuoteSmWrapper.RespuestaPlazos();
        if(sku!=null && sku!='' && ListaNegra!=true){
            Product2 productoMoto = [SELECT Id, Name, StockKeepingUnit, DSALES_Seguro__c, DSales_Articulo__c FROM Product2 WHERE StockKeepingUnit=:sku LIMIT 1];
        	PricebookEntry precioM = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id =:productoMoto.Id LIMIT 1];
        	QuoteLineItem partidaM = new QuoteLineItem();
            partidaM.QuoteId = cotiza.Id;
            partidaM.PricebookEntryId = precioM.Id;
            partidaM.Product2Id = precioM.Product2Id;
            partidaM.Quantity = 1;
            partidaM.UnitPrice = decimal.valueOf(precio);
            partidaM.DSALES_Segurogratis__c = Campana(rc, sku);
            DSALES_QuoteSmWrapper.RespuestaPlazos aux = new DSALES_QuoteSmWrapper.RespuestaPlazos(); 
            aux.nombreProducto = productoMoto.Name;
            insert partidaM;
            DSALES_QuoteSmWrapper.RespuestaPlazos moto = new DSALES_QuoteSmWrapper.RespuestaPlazos();
            moto.nombreProducto = productoMoto.Name;
            moto.Idpartida = partidaM.Id;
            return moto;
        }
        else {
            return motoVacia;
        }
        
        
    }   
    public static List<DSALES_QuoteSmWrapper.RespuestaPlazos> creaPlazos(Quote cotiza, List<DSALES_QuoteSmWrapper.ArmadoMuleSoft> plazos, String sku,Boolean ListaNegra){
        List<QuoteLineItem> listaPartidas = new List<QuoteLineItem>();
        List<DSALES_QuoteSmWrapper.RespuestaPlazos> listaSeguros = new List<DSALES_QuoteSmWrapper.RespuestaPlazos>();
        for(Integer i=0; i<plazos.size(); i++){
            listaPartidas.add(creaPartida(plazos[i].name, cotiza, plazos[i],sku));
            DSALES_QuoteSmWrapper.RespuestaPlazos aux = new DSALES_QuoteSmWrapper.RespuestaPlazos();
            aux.tracking_id = plazos[i].tracking_id;
            aux.nombreProducto = plazos[i].name;
            aux.vigencia = plazos[i].plazo;
            aux.costos = Traduccion(plazos[i].data.receipts[0]);
            listaSeguros.add(aux);
        }
        insert listaPartidas;
        for(Integer i=0; i<listaPartidas.size() ; i++){
            listaSeguros[i].Idpartida = listaPartidas[i].Id;
            listaSeguros[i].descripcion = listaPartidas[i].DSALES_Descripcion__c;
            listaSeguros[i].seguro_gratis = listaPartidas[i].DSALES_Segurogratis__c;

        }
        return listaSeguros;     
    }
    public static DSALES_QuoteSmWrapper.ReceiptEspa Traduccion(DSALES_QuoteSmWrapper.Receipt original){
        DSALES_QuoteSmWrapper.ReceiptEspa aux = new DSALES_QuoteSmWrapper.ReceiptEspa();
        aux.numero = original.numbere;
        aux.fecha_inicio = original.start_date;
        aux.fecha_termino = original.end_date;
        aux.prima_neta = original.net_premium;
        aux.precio_venta = original.total_premium;
        aux.derechos_poliza = original.right;
        aux.recargos = original.recharge;
        aux.impuestos = original.tax;
        aux.comision = original.commission;
        aux.pagoTotalEfectivo = original.pagoTotalEfectivo;
        aux.pagoMensual = original.pagoMensual;
        return aux;
    }
}