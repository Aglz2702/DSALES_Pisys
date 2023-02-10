public class DSALES_ControladorCotizacionGex {
    public  String html{get;set;}
    public  String html2{get;set;}
    public  String email{get;set;}
    public String cliente{get;set;}
    public String tienda {get;set;}
    private static final String NOMBRE_OBJETO = 'Quote';
    private static final String NOMBRE_OBJETO2 = 'QuoteLineItem'; 
    private static final String NOMBRE_PLANTILLA = 'Cotizacion Gex';
    private static final String NOMBRE_Seguro= 'Cotizacion SG';
    private static final String NOMBRE_Seguro2= 'DSALES_EnvioCotizacionSm' ;
    private static final String NOMBRE_DATE = 'DATE';
    private static final String NOMBRE_DOUBLE = 'DOUBLE';
        private static final String myfilename = 'Cotizacion';
    
    public DSALES_ControladorCotizacionGex(){
        //Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=hey');
        String recordId = ApexPages.currentPage().getParameters().get('quoteId');
        Quote recordCoti=[SELECT Id, RecordTypeId FROM Quote Where Id=:recordId];
        RECORDTYPE motos= [SELECT Id, Name FROM RECORDTYPE WHERE Id=:recordCoti.RecordTypeId ];
        System.debug('recordType: '+motos);
        //html = [Select Id, HtmlValue, Subject from EmailTemplate Where DeveloperName = :NOMBRE_PLANTILLA].HtmlValue;
        If(motos.name=='Venta de Garantía Extendida')
        {
        html = [select Id, DSALES_Plantilla__c  from DSALES_Generador__c Where Name = :NOMBRE_PLANTILLA LIMIT 1].DSALES_Plantilla__c; 
            replaceHtml(NOMBRE_PLANTILLA,recordId);
        }
        else if(motos.name=='Venta de Seguro de Motos')
        {
            List<QuoteLineItem> partidas =[SELECT Id FROM QuoteLineItem WHERE QuoteId=:recordCoti.Id];
            if(partidas!=null && partidas.size()==2){
                html = [select Id, DSALES_Plantilla__c  from DSALES_Generador__c Where Name = :NOMBRE_Seguro2 LIMIT 1].DSALES_Plantilla__c;
                System.debug('+++++plantilla+++++++++: '+html);
                replaceSecondPlantilla(NOMBRE_Seguro2, recordId);
            }
            else if(partidas!=null && partidas.size()==3){
                html = [select Id, DSALES_Plantilla__c  from DSALES_Generador__c Where Name = :NOMBRE_Seguro LIMIT 1].DSALES_Plantilla__c;
                System.debug('+++++plantilla+++++++++: '+html);
                replaceHtml(NOMBRE_Seguro,recordId);
            }
           
          // System.debug('html:'+html);
            //replaceHtml(NOMBRE_Seguro,recordId);
           // 
           // System.debug('html2:'+html2);
            //
            //DSALES_ControladorContizacionSm.
        }
        
      
    }
    
    
    private static Map<String, String> getField(String ObjName){
        Map<String, String> mapCampos = new Map<String, String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(ObjName).getDescribe().fields.getMap();
        for(Schema.SObjectField Sfield : fieldMap.Values()){
            schema.describefieldresult Field = sfield.getDescribe();
            mapCampos.put(Field.getName(), String.valueOf(Field.getType())); 
        }
        return mapCampos;
    }
    
   
    
    public void replaceHtml(String templateName,Id recordId){ 
        Quote cotizacion=[SELECT  DSALES_EmailNew__c,Name,Id,DSales_Tienda__c,DSales_Vendedor__c,DSALES_Plazoacotizar__c,DSALES_Fechadecreacionpresupuesto__c,ExpirationDate,QuoteNumber,DSALES_fechadecreacion__c,Email,   OpportunityId FROM Quote WHERE ID=:recordId];
        DSALES_InformacionDePago__c pago =[SELECT Id,DSALES_Fechadeentregaestimada__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c=:cotizacion.OpportunityId LIMIT 1];
        email=[SELECT  DSALES_EmailNew__c,Name,Id,DSales_Direccion_de_la_tienda__c FROM Quote WHERE ID=:recordId].DSALES_EmailNew__c;
       // cliente=[SELECT Name FROM Account WHERE Id=:cliente].Name;
        List<Tienda__c> tienda = new List<Tienda__c>();
           //tienda=[SELECT DSALES_Direccin__c FROM Tienda__c WHERE Id=:String.ValueOf(cotizacion.DSales_Tienda__c) Limit 1].DSALES_Direccin__c;
           tienda=[SELECT DSALES_Direccin__c,DSALES_Cdigopostal__c,DSALES_Ciudad__c,DSALES_Estado__c FROM Tienda__c WHERE Id=:cotizacion.DSales_Tienda__c Limit 1];
        String direccion='';
        for(Tienda__c t: tienda)
        {
            
            if(tienda!=null){ //datos de la direción de la tienda SG
                direccion='\n'+t.DSALES_Direccin__c+','+'\n';
                direccion +='\n CP '+t.DSALES_Cdigopostal__c+','+t.DSALES_Ciudad__c+','+t.DSALES_Estado__c;
                html=html.replace('Tienda__c', direccion);
            }else
            {
                html=html.replace('Tienda__c', '');
            }
        }
           
        
        
        if(email!=null)
        {
            html=html.replace('DSALES_EmailNew__c', email);  
        }
       
        
        
        Map<String, String> mapCampos = getField(NOMBRE_OBJETO);
        Map<String, String> mapCamposQuoteLineItem = getField(NOMBRE_OBJETO2);
        String query = 'Select ';
        String query2 = 'Select ';
        for(String item: mapCampos.keySet()){
            query += item+',';
        }
        for(String item2: mapCamposQuoteLineItem.keySet()){
            query2 += item2+',';
        }
        query = query.substring(0, query.length() -1);
        query += ' From Quote Where Id = :recordId';
        query2 = query2.substring(0, query2.length() -1);
        query2 += ' From QuoteLineItem Where QuoteId = :recordId';
        
        Quote coti = DataBase.query(query);
        html = html.replace('coti.', '');
        Integer contadora=0;
        List<QuoteLineItem> cotiLine = DataBase.query(query2);
        System.debug('*********Partidas**********'+cotiLine);
        List<String> idsPartidas = new List<String>();
        for(QuoteLineItem ql:cotiLine){
            idsPartidas.add(ql.DSALES_Plazo__c);

        }
        System.debug('ids partidas: '+ idsPartidas.size());
        List<Plazo__c> plazo=[SELECT Id,Dsales_Plazo__c,DSALES_Seguro__r.Name FROM Plazo__c WHERE Id IN: idsPartidas ];
       // System.debug('plazos: '+plazo);
        //System.debug('plazos: '+plazo[0].DSALES_Seguro__r.Name);
        html = html.replace('Quote.', '');
        for(String item: mapCampos.keySet()){
           
            if(html.contains(item)){
              String replace = '';
                if(coti.get(item)!= null){
                    if(mapCampos.get(item) == NOMBRE_DATE){
                        replace = String.valueOf(Date.valueOf(coti.get(item)).format());
                    }else if (mapCampos.get(item) == NOMBRE_DOUBLE ){
                        replace = String.valueOf(Decimal.valueOf( String.valueOf(coti.get(item)) ).format());
                    }else{
                        replace = String.valueOf(coti.get(item));
                    }
                }
                html = html.replace(item, replace);
                 contadora++;
                
            
            }
           
        }
        Integer count=0;
        Double total=0;
        Double total12=0;
        Double total24=0;
        //System.debug('html: '+html);
        String formato='<tr>';
        formato+='<td colspan="1" rowspan="1">DSALES_NombreProducto__c</td>';
             formato+='<td colspan="1" rowspan="1">QuoteLineItem.Quantity</td>';
             formato+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
             formato+='<td colspan="1" rowspan="1">QuoteLineItem.DSALES_Fechadecompra__c</td>';
             formato+='<td colspan="1" rowspan="1">QuoteLineItem.DSALES_PrecioTotal</td>';        
        formato+='</tr>';
        
        String formato2='<tr>';
        formato2+='<td colspan="1" rowspan="1">DSALES_NombreProducto__c</td>';
        formato2+='<td colspan="1" rowspan="1">DSALES_SKU__c</td>';
        formato2+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
        formato2+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
        formato2+='<td colspan="1" rowspan="1">8000</td>';
        formato2+='</tr>';
        
        
        String tdTotal='<tr>';
        tdTotal+='<td colspan="1" rowspan="1" >Total</td>';
        tdTotal+='<td colspan="1" rowspan="1">&nbsp;</td>';
        tdTotal+='<td colspan="1" rowspan="1">&nbsp;</td>';
        tdTotal+='<td colspan="1" rowspan="1">16000</td>';
        tdTotal+='<td colspan="1" rowspan="1">8000</td>';
        tdTotal+='</tr>';
        String tdTotalRem='';
        String tabla='';
        String tabla2='';
        String tabla3='';
        String tabla4='';
        double price=0;
        double tdPrice=0;
        double sgPrice=0;
        String formattedDate1='';
        double discount=0;
        String tablaMoto='';
        //motos tablas sin formato
        String tablaSucursal='<tr>';
        tablaSucursal+='<td colspan="1" rowspan="1">Sucursal: Tienda</td>';
        tablaSucursal+='</tr>';
        String tablaSucursal2='<tr>';
        tablaSucursal2+='<td colspan="1" rowspan="1">Sucursal</td>';
        tablaSucursal2+='</tr>';

        String tablaPrep='<tr>';
        tablaPrep+='<td colspan="1" rowspan="1">Preparado por:Vendedor</td>';
        tablaPrep+='</tr>';
        String tablaPrep2='<tr>';
        tablaPrep2+='<td colspan="1" rowspan="1">Preparado</td>';
        tablaPrep2+='</tr>';
        
        String tablaFecha='<tr>';
        tablaFecha+='<td colspan="1" rowspan="1">Fecha:</td>';
        tablaFecha+='<td colspan="1" rowspan="1">fechaCreacion</td>';
        tablaFecha+='</tr>';
        String tablaFechaCreacion='<tr>';
        tablaFechaCreacion+='<td colspan="1" rowspan="1">Fecha2</td>';
        tablaFechaCreacion+='<td colspan="1" rowspan="1">fechaCreacion2</td>';
        tablaFechaCreacion+='</tr>';
        String tablaFecha2='<tr>';
        tablaFecha2+='<td colspan="1" rowspan="1">Fechacaducidad:</td>';
        tablaFecha2+='<td colspan="1" rowspan="1">fechaFin</td>';
        tablaFecha2+='</tr>';
        String tablaFechaFin2='<tr>';
        tablaFechaFin2+='<td colspan="1" rowspan="1">Fechacaducidad2</td>';
        tablaFechaFin2+='<td colspan="1" rowspan="1">fechaFin2</td>';
        tablaFechaFin2+='</tr>';

        String tableEmailSG='<tr>';
        tableEmailSG+='<td colspan="1" rowspan="1">Correo:correo</td>';
        tableEmailSG+='</tr>';
        String tableEmailSG2='<tr>';
        tableEmailSG2+='<td colspan="1" rowspan="1">Correo2</td>';
        tableEmailSG2+='</tr>';

        String tableName='<tr>';
        tableName+='<td colspan="1" rowspan="1">Nombre:nombre</td>';
        tableName+='</tr>';
        String tableName2='<tr>';
        tableName2+='<td colspan="1" rowspan="1">Nombre2</td>';
        tableName2+='</tr>';
        String tablaConceptoSG='<tr>';
        tablaConceptoSG+='<td colspan="1" rowspan="1">Concepto</td>';
        tablaConceptoSG+='</tr>';

        String tablaConcepto2='<tr>';
        tablaConcepto2+='<td colspan="1" rowspan="1">Concepto2</td>';
        tablaConcepto2+='</tr>';

        String tablaConcepto2x='<tr>';
        tablaConcepto2x+='<td colspan="1" rowspan="1">Concepto3</td>';
        tablaConcepto2x+='</tr>';

        String tablaProductoSG='<tr>';
        tablaProductoSG+='<td colspan="1" rowspan="1">Producto</td>';
        tablaProductoSG+='<td colspan="1" rowspan="1">DSALES_NombreProducto__c</td>';
        tablaProductoSG+='</tr>';

        String tablaProducto2='<tr>';
        tablaProducto2+='<td colspan="1" rowspan="1">Cantidad</td>';
        tablaProducto2+='<td colspan="1" rowspan="1">QuoteLineItem.Quantity</td>';
        tablaProducto2+='</tr>';

        String tablaProducto3='<tr>';
        tablaProducto3+='<td colspan="1" rowspan="1">Precio por producto</td>';
        tablaProducto3+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
        tablaProducto3+='</tr>';

        String tablaProducto4='<tr>';
        tablaProducto4+='<td colspan="1" rowspan="1">Total</td>';
        tablaProducto4+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
        tablaProducto4+='</tr>';

        String tablaFechaSG='<tr>';
        tablaFechaSG+='<td colspan="1" rowspan="1">Fecha de entrega estimada</td>';
        tablaFechaSG+='<td colspan="0" rowspan="1">fechaEstimada</td>';
        tablaFechaSG+='</tr>';

        String tablaPresupuestoSG='<tr>';
        tablaPresupuestoSG+='<td colspan="1" rowspan="1">Nro de presupuesto</td>';
        tablaPresupuestoSG+='<td colspan="0" rowspan="1">Num</td>';
        tablaPresupuestoSG+='</tr>';

        String leyendaSG='<tr>';
        leyendaSG+='<td colspan="1" rowspan="1">Vendido y entregado por Coppel</td>';
        leyendaSG+='</tr>';

        String leyendaSG2='<tr>';
        leyendaSG2+='<td colspan="1" rowspan="1">SKU:QuoteLineItem.DSales_SKU_Producto__c</td>';
        leyendaSG2+='</tr>';
        String leyendaSG3='<tr>';
        leyendaSG3+='<td colspan="1" rowspan="1">plazo</td>';
        leyendaSG3+='</tr>';

        String tablaServicioSG='<tr>';
        tablaServicioSG+='<td colspan="1" rowspan="1">Servicio</td>';
        tablaServicioSG+='<td colspan="1" rowspan="1">DSALES_NombreProducto__c</td>';
        tablaServicioSG+='</tr>';

        String tablaServicioSG2='<tr>';
        tablaServicioSG2+='<td colspan="1" rowspan="1">CantidadServicio</td>';
        tablaServicioSG2+='<td colspan="1" rowspan="1">QuoteLineItem.Quantity</td>';
        tablaServicioSG2+='</tr>';

        String tablaServicioSG3='<tr>';
        tablaServicioSG3+='<td colspan="1" rowspan="1">PrecioServicio</td>';
        tablaServicioSG3+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
        tablaServicioSG3+='</tr>';

        String tablaServicioSG4='<tr>';
        tablaServicioSG4+='<td colspan="1" rowspan="1">TotalServicio</td>';
        tablaServicioSG4+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
        tablaServicioSG4+='</tr>';
        
        String tablaServicioSGx='<tr>';
        tablaServicioSGx+='<td colspan="1" rowspan="1">Servicio2</td>';
        tablaServicioSGx+='<td colspan="1" rowspan="1">DSALES_NombreProducto__c</td>';
        tablaServicioSGx+='</tr>';

        String tablaServicioSG2x='<tr>';
        tablaServicioSG2x+='<td colspan="1" rowspan="1">Cantidad2</td>';
        tablaServicioSG2x+='<td colspan="1" rowspan="1">QuoteLineItem.Quantity</td>';
        tablaServicioSG2x+='</tr>';

        String tablaServicioSG3x='<tr>';
        tablaServicioSG3x+='<td colspan="1" rowspan="1">Precio2</td>';
        tablaServicioSG3x+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
        tablaServicioSG3x+='</tr>';
        String tablaImagen='<tr>';
        tablaImagen+='<td colspan="1" rowspan="1">imagen1</td>';
        tablaImagen+='</tr>';
        String tablaImagen2='<tr>';
        tablaImagen2+='<td colspan="1" rowspan="1">imagen2</td>';
        tablaImagen2+='</tr>';
        String tablaImagen3='<tr>';
        tablaImagen3+='<td colspan="1" rowspan="1">imagen3</td>';
        tablaImagen3+='</tr>';
        String tablaImagen4='<tr>';
        tablaImagen4+='<td colspan="1" rowspan="1">imagen4</td>';
        tablaImagen4+='</tr>';

        String tablaServicioSG4x='<tr>';
        tablaServicioSG4x+='<td colspan="1" rowspan="1">Total2</td>';
        tablaServicioSG4x+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
        tablaServicioSG4x+='</tr>';

        String tablaMejora='<tr>';
        tablaMejora+='<td colspan="1" rowspan="1">Mejora tu vida</td>';
        tablaMejora+='</tr>';
        String tabDiv='<div style="display:flex">';
        String tablaMejora2='<tr>';
        tablaMejora2+='<td colspan="1" rowspan="1">Mejora tu vida 2</td>';
        tablaMejora2+='</tr>';
        String tablaP2='<tr>';
        tablaP2+='<td colspan="1" rowspan="1">plazo2</td>';
        tablaP2+='</tr>';
        String espacio ='<tr>';
        espacio+='<td colspan="1" rowspan="1">espacio</td>';
        espacio+='</tr>';
        String logoCoppel='<tr>';
        logoCoppel+='<td colspan="1" rowspan="1">logoCoppel</td>';
        logoCoppel+='</tr>';
        String espaciosTab = '<tr>';
        espaciosTab+='<td colspan="1" rowspan="1" style="height:auto">&nbsp;</td>';
        espaciosTab+='</tr>';
      //motos tablas con formato 
        String rempConcepto2='<tr>';
        rempConcepto2+='<td colspan="1" rowspan="1" height="35px" style="background:rgb(0,72,118 );border:solid; border-color:white;color:white;padding-left:15px;"><strong>Concepto</strong></td>';
        rempConcepto2+='</tr>';
        String rempSucSG='<tr>';
        rempSucSG+='<td colspan="1" rowspan="1"style="font-size:15px"><b>Sucursal:</b><br />';
        rempSucSG+= direccion + '</td>';
        //rempSucSG+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209);border-bottom: .2rem solid white;width:30%;border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Fecha creaci&oacute;n:</strong></td>';
        //rempSucSG+='<td colspan="1" rowspan="1" height="35px"style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .2rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;width:30%;text-align:center; font-size:12px">'+fechaFormato +'</td>';
        rempSucSG+='</tr>';
        String fechaFormato=cotizacion.DSALES_Fechadecreacionpresupuesto__c.format();
        System.debug('fechaFormato1:'+fechaFormato);
        String rempFecha='<tr>';
        rempFecha+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209);border-bottom: .2rem solid white;width:30%;border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Fecha creaci&oacute;n:</strong></td>';
        rempFecha+='<td colspan="1" rowspan="1" height="35px"style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .2rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;width:30%;text-align:center; font-size:12px">'+fechaFormato +'</td>';
        rempFecha+='</tr>';
        //fechaFormato=cotizacion.ExpirationDate.format();
        System.debug('fechaFormato2:'+fechaFormato);
        String rempSucSG1='<tr>';
        rempSucSG1+='<td colspan="1" rowspan="1" height="39px" style="font-size:15px;"><strong>Preparado por:</strong><br/>'+cotizacion.DSales_Vendedor__c+'</td>';
       // rempSucSG1+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209 );border-bottom: .2rem solid white;width:20%;border:solid; border-color:white; font-size:12px;padding-left:15px;"><strong>Fecha caducidad:</strong></td>';
        //rempSucSG1+='<td colspan="1" rowspan="1" height="35px"style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .2rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;width:30%;text-align:center; font-size:12px">'+fechaFormato+'</td>';
        rempSucSG1+='</tr>';
        String rempFecha2='<tr>';
        rempFecha2+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209 );border-bottom: .2rem solid white;width:20%;border:solid; border-color:white; font-size:12px;padding-left:15px;"><strong>Fecha caducidad:</strong></td>';
       	if(pago.DSALES_Fechadeentregaestimada__c!=null)
             rempFecha2+='<td colspan="1" rowspan="1" height="35px"style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .2rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;width:30%;text-align:center; font-size:12px">'+pago.DSALES_Fechadeentregaestimada__c.format()+'</td>';
        rempFecha2+='</tr>';
        //String nroCotizacion =cotizacion.QuoteNumber.replace('0000', '');
        String rempEspacio ='<tr>';
        rempEspacio+='<td colspan="1" rowspan="1"  style="font-size:5px;">&nbsp;</td>';
        rempEspacio+='</tr>';
        String rempPres='<tr>';
        rempPres+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209);border-bottom: .2rem solid white;width:20%;border:solid; border-color:white; font-size:12px;padding-left:15px;"><strong>Nro de presupuesto</strong></td>';
        rempPres+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;text-align:left; font-size:12px;padding-left:12px;width:20%">'+cotizacion.QuoteNumber+'</td>';
        rempPres+='</tr>';

        String rempLeyendaSG='<tr>';
        rempLeyendaSG+='<td colspan="1" rowspan="1" height="35px" style="width:20%;font-size:12px;padding-left:15px;"><b>Vendido y entregado por Coppel</b></td>';
        rempLeyendaSG+='</tr>';
        String tablaLine='<tr>';
        tablaLine+='<td colspan="1" rowspan="1">linea</td>';
        tablaLine+='</tr>';
        String tablaLine2='<tr>';
        tablaLine2+='<td colspan="1" rowspan="1">line</td>';
        tablaLine2+='</tr>';
        String rempEmailSG='<tr>';
        rempEmailSG+='<td colspan="1" rowspan="1" height="35px" style="font-size:15px;"><strong>Correo:</strong><br>'+cotizacion.Email+'</td>';
        rempEmailSG+='</tr>';
        String rempEmailSG2='<tr>';
        rempEmailSG2+='<td colspan="1" rowspan="1" height="35px" style="font-size:15px;padding-top:6px"><strong>Correo:</strong><br>'+cotizacion.Email+'</td>';
        rempEmailSG2+='</tr>';
        String rempName='<tr>';
        rempName+='<td colspan="1" rowspan="1" height="35px" style="font-size:15px"><strong>Nombre:</strong><br>'+cotizacion.Name+'</td>';
        rempName+='</tr>';
        
        //-----------------
        String tabAnt='<table border="1" cellpadding="0" cellspacing="0" style="height:auto; width:80%">';
        String tabRemp='<table border="0" cellpadding="0" cellspacing="0" style="height:auto; width:80%:float:left">';
        String tab2='<table border="0" cellpadding="0" cellspacing="0" style="height:auto;">';
        String tab2Remp='<table border="0" cellpadding="0" cellspacing="0" style="height:auto;float:right">';
        if(templateName==NOMBRE_Seguro){
            try{
                String rempFechaSG='<tr>';
                rempFechaSG+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209 );border-bottom: .2rem solid white;width:20%;border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Fecha de entrega estimada</strong></td>';
                rempFechaSG+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;text-align:left; font-size:12px;padding-left:12px;width:20%;"><strong>'+pago.DSALES_Fechadeentregaestimada__c.format()+'</strong></td>';
                rempFechaSG+='</tr>';
                String rempImagen1='<tr>';
                //rempImagen1+='<td colspan="1" rowspan="1" style="height:auto; width:70px;"></td>';
                //rempImagen1+='<td colspan="1" rowspan="1"style="height:auto; width:70px;"></td>';
                rempImagen1+='<td colspan="1" rowspan="1" style="height:auto; width:40px;text-align:right;background-color:rgb(238, 238, 238 ); border-bottom:2pt solid white;"><img src="https://coppelmx--pisysdev2--c.sandbox.vf.force.com/resource/1674077199000/DSALES_ClubProteccionMotos?" style="height:60px;" /></td>';

                String rempImagen2='<tr>';
                //rempImagen2+='<td colspan="1" rowspan="1" style="height:auto; width:70px;"></td>';
                //rempImagen2+='<td colspan="1" rowspan="1" style="height:auto; width:70px;"></td>';
                rempImagen2+='<td colspan="1" rowspan="1" style="height:auto; width:50px;text-align:center;background-color:rgb(238, 238, 238 );font-family:italic; font-size:10px"><div><p style="color:#238DC1"><strong>VIAJA TRANQUILO Y <br>PROTEGIDO </strong></p><p style="text-align: center;">Un seguro creado para <br>acompañarte y asistirte<br> ante los imprevistos que <br> se presentan en tu camino.</p><img src="https://coppelmx--pisysdev2--c.sandbox.vf.force.com/resource/1673912662000/DSALES_MotoSG?" style="height:60px; " /></div></td>';
                html=html.replace(tablaFechaSG,rempFechaSG);
                html=html.replace(tablaFecha, rempFecha);
                html=html.replace(tablaFecha2, rempFecha2);
                //html=html.replace(tablaFechaSG,rempFechaSG);
                html=html.replace(tablaImagen,rempImagen1);
                html=html.replace(tablaImagen2,rempImagen2);
                html=html.replace(espacio, rempEspacio);
                if(cotiLine!=null && cotiLine.size()==3){
                    for(QuoteLineItem quote: cotiLine){
                        System.debug('partidas:'+quote);
                        Product2 producto = [SELECT DSales_Tipo_de_Producto__c FROM Product2 WHERE ID=:quote.Product2Id ];
                        String rempServ='<tr>';
                        rempServ+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209);border-bottom: .2rem solid white;width:15%;border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Servicio</strong></td>';
                        rempServ+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;white;width:20%;text-align:left;font-size:12px;padding-left:15px;"><strong>'+quote.DSALES_NombreProducto__c+'</strong></td>';
                        rempServ+='</tr>';
                        
                        String cantidadSeg =String.valueOf(quote.Quantity).replace('.00', '');
                        String rempServ2='<tr>';
                        rempServ2+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209 );border-bottom: .2rem solid white;width:50%; border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Cantidad</strong></td>';
                        rempServ2+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;text-align:left; font-size:12px;padding-left:12px;">'+cantidadSeg+'<td>';
                        rempServ2+='</tr>';
                        String rempServ3='<tr>';
                        rempServ3+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209);border-bottom: .2rem solid white;width:50%; border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Precio por producto</strong></td>';
                        rempServ3+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;text-align:left;font-size:12px;padding-left:15px;">'+'$'+quote.UnitPrice+'</td>';
                        rempServ3+='</tr>';
                        String rempServ4='<tr>';
                        rempServ4+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209 );border-bottom: .2rem solid white;width:50%; border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Total</strong></td>';
                        rempServ4+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;white;text-align:left; font-size:12px;padding-left:15px;"><strong>'+'$'+quote.TotalPrice+'</strong></td>';
                        rempServ4+='</tr>';
                        String rempProduc='<tr>';
                        rempProduc+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(242, 242, 242 );border-bottom: .2rem solid white;width:20%;border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Producto</strong></td>';
                        rempProduc+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;white;width:20%;text-align:left;font-size:12px;padding-left:15px;">'+quote.DSALES_NombreProducto__c+'</td>';
                        rempProduc+='</tr>';
                        cantidadSeg =String.valueOf(quote.Quantity).replace('.00', '');
                        String rempProduc2='<tr>';
                        rempProduc2+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(242, 242, 242 );border-bottom: .2rem solid white;width:50%; border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Cantidad</strong></td>';
                        rempProduc2+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;text-align:left; font-size:12px;padding-left:12px;">'+cantidadSeg+'<td>';
                        rempProduc2+='</tr>';
                        String rempProduc3='<tr>';
                        rempProduc3+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(242, 242, 242 );border-bottom: .2rem solid white;width:50%; border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Precio por producto</strong></td>';
                        rempProduc3+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;text-align:left;font-size:12px;padding-left:15px;">'+'$'+quote.UnitPrice+'</td>';
                        rempProduc3+='</tr>';
                        String rempProduc4='<tr>';
                        rempProduc4+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(242, 242, 242 );border-bottom: .2rem solid white;width:50%; border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Total</strong></td>';
                        rempProduc4+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;white;text-align:left; font-size:12px;padding-left:15px;"><strong>'+'$'+quote.TotalPrice+'</strong></td>';
                        rempProduc4+='</tr>';
                        /*String rempFechaSG='<tr>';
                        rempFechaSG+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209);border-bottom: .2rem solid white;width:70%;border:solid; border-color:white; font-size:12px;padding-left:15px;"><strong>Fecha de entrega estimada</td>';
                        rempFechaSG+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;text-align:left; font-size:12px;padding-left:12px;">'+fechaFormato+'</td>';
                        rempFechaSG+='</tr>';*/
                        String rempSku='<tr>';
                        rempSku+='<td colspan="1" rowspan="1" style="text-align:left; width:50%; color:rgb(189,189,189);font-size:12px;padding-left:15px;">SKU:'+quote.DSALES_SKU__c+'</td><br>';
                        rempSku+='</tr>';
                        String rempleyendaSG3='<tr>';
                    
                        String rempMejora='<tr>';
                        rempMejora+='<td colspan="1" rowspan="1" style="color:#238DC1;font-size:12px"><strong>Mejora tu vida</strong></td>';
                        rempMejora+='</tr>';
                        String rempLine='<tr>';
                        rempLine+='<td colspan="1" rowspan="1"><hr style="color:#238DC1; border-color:#238DC1;size:3;" /></td>';
                        rempLine+='</tr>';
                        String rempLogoCoppel='<tr>';
                        rempLogoCoppel+='<td colspan="1" rowspan="1"><img src="https://coppelmx--pisysdev2--c.sandbox.vf.force.com/resource/1658351938000/DSALES_LogoCoppelSM" style="width:200px" /></td>';
                        rempLogoCoppel+='</tr>';
                        
                        html=html.replace(logoCoppel, rempLogoCoppel);
                        html=html.replace(tablaLine2, rempLine);
                        html=html.replace(tablaLine, rempLine);
                        html=html.replace(tablaSucursal,rempSucSG);
                        html=html.replace(tablaSucursal2,rempSucSG);
                        html=html.replace(tablaPrep,rempSucSG1);
                        html=html.replace(tablaPrep2,rempSucSG1);
                        html=html.replace(tablaFechaCreacion, rempFecha);
                        html=html.replace(tablaFechaFin2, rempFecha2);
                        html=html.replace(tablaMejora, rempMejora);
                        html=html.replace(tablaMejora2, rempMejora);
                        html=html.replace(leyendaSG,rempLeyendaSG);
                        html=html.replace(tableEmailSG, rempEmailSG);
                        html=html.replace(tableEmailSG2, rempEmailSG2);
                        html=html.replace(tableName, rempName);
                        html=html.replace(tableName2, rempName);
                        
                        html=html.replace(tablaImagen3,rempImagen1);
                        html=html.replace(tablaImagen4,rempImagen2);
                        ///presupues
                        html=html.replace(tablaPresupuestoSG,rempPres);
                        if(producto.DSales_Tipo_de_Producto__c=='Producto'){
                            System.debug('producto:'+quote);
                            
                            html=html.replace(tablaConceptoSG,rempConcepto2);
                            html=html.replace(tablaProductoSG,rempProduc);
                            html=html.replace(tablaProducto2,rempProduc2); 
                            html=html.replace(tablaProducto3,rempProduc3);
                            html=html.replace(tablaProducto4,rempProduc4);
                            html=html.replace(leyendaSG2,rempSku);
                            
                            //html=html.replace(leyendaSG3,rempleyendaSG3);
                        }
                        
                        if(producto.DSales_Tipo_de_Producto__c=='Seguro'){
                            if(quote.DSALES_NombreProducto__c=='AMP Seguro de Moto'){
                                System.debug('amp:'+quote);
                                String plazoSeg='';
                                System.debug('Nombre de seguro:'+quote.DSALES_NombreProducto__c);
                                for(Plazo__c pl:plazo){
                                    if(quote.DSALES_Plazo__c==pl.Id){
                                        System.debug('es igual:'+pl.DSALES_Seguro__r.Name);
                                        plazoSeg=pl.Dsales_Plazo__c;
                                    }
                                }
                                System.debug('plazo amp'+plazoSeg);
                                rempleyendaSG3+='<td style="background-color:#238DC1;width:2%;">&nbsp;</td>';
                                rempleyendaSG3+='<td colspan="1" rowspan="1" style="background-color:rgb(242, 242, 242 );text-align:left;font-size:12px;padding-left:15px;border-bottom:2pt solid white;">Seguro de motos a '+ plazoSeg+' meses <strong>Club de Protecci&oacute;n de Motos</strong></td>';
                                rempleyendaSG3+='</tr>';
                                //tablas con los datos de los seguros
                                html=html.replace(leyendaSG3,rempleyendaSG3);
                                html=html.replace(tabAnt, tabRemp);
                                html=html.replace(tablaServicioSG,rempServ);
                                html=html.replace(tablaConcepto2,rempConcepto2);
                                html=html.replace(tablaServicioSG2,rempServ2);
                                html=html.replace(tablaServicioSG3,rempServ3);
                                html=html.replace(tablaServicioSG4,rempServ4);
                                
                                
                            }
                            if(quote.DSALES_NombreProducto__c=='RC Seguro de Moto'){
                                String plazoSeg='';
                                System.debug('Nombre de seguro:'+quote.DSALES_NombreProducto__c);
                                for(Plazo__c pl:plazo){
                                    if(quote.DSALES_Plazo__c==pl.Id){
                                        System.debug('es igual:'+pl.DSALES_Seguro__r.Name);
                                        plazoSeg=pl.Dsales_Plazo__c;
                                    }
                                }
                                System.debug('plazo a mostrar rc:'+plazoSeg);
                                String rempTablaP2='<tr>';
                                rempTablaP2+='<td style="background-color:#238DC1;width:2%;">&nbsp;</td>';
                                rempTablaP2+='<td colspan="1" rowspan="1" style="background-color:rgb(242, 242, 242 );text-align:left;font-size:12px;padding-left:15px;border-bottom:2pt solid white;">Seguro de motos a '+ plazoSeg+' meses <strong>Club de Protecci&oacute;n de Motos</strong></td>';
                                rempTablaP2+='</tr>';
                                System.debug('rc:'+quote);
                                html=html.replace(tablaP2, rempTablaP2);
                                html=html.replace(tab2, tab2Remp);
                                html=html.replace(tablaServicioSGx,rempServ);
                                html=html.replace(tablaConcepto2x,rempConcepto2);
                                html=html.replace(tablaServicioSG2x,rempServ2);
                                html=html.replace(tablaServicioSG3x,rempServ3);
                                html=html.replace(tablaServicioSG4x,rempServ4);
                            }
                        }
                    }
                }
            }catch(Exception e){
                System.debug(e.getLineNumber() + e.getMessage());
            }
        }
        for(QuoteLineItem quote: cotiLine){
            Product2 producto = [SELECT DSales_Tipo_de_Producto__c FROM Product2 WHERE ID=:quote.Product2Id ];
            String sku='';
            String skuArray='';
            if(String.isBlank(quote.DSALES_SKU__c))
                sku='';
            else
                sku=quote.DSALES_SKU__c;
            String formattedDate='';
            
            
            if(producto.DSales_Tipo_de_Producto__c=='Producto')
             {
            skuArray+=sku;
            
            tabla+='<tr>';
            tabla+='<td colspan="1" rowspan="1" style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+ '<br/>' +quote.DSALES_NombreProducto__c+ '<br/>'+'<span style="color:#838383">'+'SKU: '+ sku+'</span>'+'</td>';
            tabla+='<td colspan="1" rowspan="1" style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+ '<br/>' +quote.Quantity+'<br/>'+ '</td>';
            tabla+='<td colspan="1" rowspan="1" style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+ '<br/>' +'$ '+quote.UnitPrice+'<br/>'+ '</td>';
            price=quote.UnitPrice;
            if(quote.DSALES_Fechadecompra__c!=null){
                formattedDate=quote.DSALES_Fechadecompra__c.format();
                tabla+='<td colspan="1" rowspan="1" style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+formattedDate+'</td>';
                tabla+='<td colspan="1" rowspan="1" style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+ '<br/>' +'$ '+quote.totalPrice+  '<br/>' +'</td>';
            }
              else
                 {
                      tabla+='<td colspan="1" rowspan="1 "style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+'________'+'</td>';
                tabla+='<td colspan="1" rowspan="1" style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+ '<br/>' +'$ '+quote.totalPrice+  '<br/>'+'</td>';
                 }
            if(String.valueOf(quote.DSALES_Fechadecompra__c)==null)
                total+=quote.TotalPrice;
            tabla+='</tr>';
            tabla+='<tr>';
            tabla+='<td style="border-bottom:1px solid #00a9e0;"height="10"></td>';
            tabla+='<td style="border-bottom:1px solid #00a9e0;"height="10"></td>';
            tabla+='<td style="border-bottom:1px solid #00a9e0;"height="10"></td>';
            tabla+='<td style="border-bottom:1px solid #00a9e0;"height="10"></td>';
            tabla+='<td style="border-bottom:1px solid #00a9e0;"height="10"></td>';
            tabla+='</tr>';
            
             }   
            
            
            if(producto.DSales_Tipo_de_Producto__c=='Servicio'){
            
            
            tabla2+='<tr>';
            tabla2+='<td colspan="1" rowspan="1" style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+  '<br/>' +quote.DSALES_NombreProducto__c+  '<br/>' +'</td>';
            
            tabla2+='<td colspan="1" rowspan="1" style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+  '<br/>'+sku+ '<br/>'+'</td>';
            sku=sku.replace('-GEX', '');
            if(skuArray==sku)
            {
                tabla2+='<td colspan="1" rowspan="1" style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+ '<br/>'+'$ '+price+ '<br/>'+'</td>';
            }
            else
            {
                tabla2+='<td colspan="1" rowspan="1" style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+ '<br/>'+'$ '+price+ '<br/>'+'</td>';
            }
            
            if(quote.Vigencia_meses__c=='12')
            {
                tabla2+='<td colspan="1" rowspan="1"style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+ '<br/>'+'$ '+quote.TotalPrice+ '<br/>'+'</td>';
                total12+=quote.TotalPrice;
                tabla2+='<td colspan="1" rowspan="1"style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+'________'+ '</td>';  
                tabla4+='<td colspan="1" rowspan="1"style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+ '<br/>'+'$ '+quote.TotalPrice+ '<br/>'+'</td>';
            }
            else if (quote.Vigencia_meses__c=='24')
            {
                tabla2+='<td colspan="1" rowspan="1"style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+'________'+'</td>';
                tabla2+='<td colspan="1" rowspan="1"style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+ '<br/>'+ '$ '+quote.TotalPrice+ '<br/>'+'</td>';  
                total24+=quote.TotalPrice;
                tabla4+='<td colspan="1" rowspan="1"style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+ '<br/>'+'$ '+quote.TotalPrice+ '<br/>'+'</td>';
            }
            else 
            {
                tabla2+='<td colspan="1" rowspan="1" style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+'________'+'</td>';
                tabla2+='<td colspan="1" rowspan="1"style="font-size:15px;font-family: Arial, Helvetica, sans-serif;text-align:center;">'+'________'+'</td>'; 
            }
            tabla2+='</tr>';
             //tabla2+='</tr>';
            tabla2+='<tr>';
            tabla2+='<td style="border-bottom:1px solid #00a9e0;"height="12"></td>';
            tabla2+='<td style="border-bottom:1px solid #00a9e0;"height="12"></td>';
            tabla2+='<td style="border-bottom:1px solid #00a9e0;"height="12"></td>';
            tabla2+='<td style="border-bottom:1px solid #00a9e0;"height="12"></td>';
            tabla2+='<td style="border-bottom:1px solid #00a9e0;"height="12"></td>';
            tabla2+='</tr>';
            
            }
           
        }
        
    
        
        html=html.replace('<th','<th style="border-top: 1px solid #00a9e0;border-bottom:1px solid #00a9e0;text-align:center;font-family: Arial, Helvetica, sans-serif;font-size:15px;" height="23"');
         //html=html.replace('<td', '<td style="border-bottom:1px solid #333; border-left:1px solid #333; border-right:1px solid #333;"');
        //html=html.replace('<td ', '<td style="border-top: 1px solid #00a9e0;border-bottom:1px solid #00a9e0;border-left:1px solid #00a9e0;border-right:1px solid #00a9e0;"');
        // html=html.replace('<th style="border-top: 1px solid #00a9e0;border-bottom:1px solid #00a9e0;>Producto</th>', 'style=border-left:1px solid #00a9e0;>Producto');
         if(templateName==NOMBRE_PLANTILLA){
            //htmL=html.replace('YYY',)
             html=html.replace(formato, tabla);
            html=html.replace(formato2,tabla2);
            html=html.replace('null', 'fdsfsfsdf');
            html=html.replace('XX',' '+String.valueOf(total));
            html=html.replace('total12',String.valueOf(total12+total));
            html=html.replace('total24',String.valueOf(total24+total));
             //html=html.replace(sku, sku2);
            }
      if(templateName==NOMBRE_Seguro){
          //remplazar los valores de la platilla con lo que se pone en codigo
      }
        html=html.replace('null', '________');
        //system.debug('Discount: '+discount);
       // system.debug('Price: '+tdPrice);
       // system.debug('Total: '+total);
        //system.debug('Tabla: '+tabla); 

    } 


    public  void replaceSecondPlantilla(String templateName, Id recordId){ 
        try{
            Quote cotizacion=[SELECT  DSALES_EmailNew__c,Name,Id,DSales_Tienda__c,DSales_Vendedor__c,DSALES_Plazoacotizar__c,DSALES_Fechadecreacionpresupuesto__c,ExpirationDate,QuoteNumber,DSALES_fechadecreacion__c,Email,   OpportunityId FROM Quote WHERE ID=:recordId];
            DSALES_InformacionDePago__c pago =[SELECT Id,DSALES_Fechadeentregaestimada__c FROM DSALES_InformacionDePago__c WHERE DSALES_Oportunidad__c=:cotizacion.OpportunityId LIMIT 1];
            email=[SELECT  DSALES_EmailNew__c,Name,Id,DSales_Direccion_de_la_tienda__c FROM Quote WHERE ID=:recordId].DSALES_EmailNew__c;
        // cliente=[SELECT Name FROM Account WHERE Id=:cliente].Name;
            List<Tienda__c> tienda = new List<Tienda__c>();
                //tienda=[SELECT DSALES_Direccin__c FROM Tienda__c WHERE Id=:String.ValueOf(cotizacion.DSales_Tienda__c) Limit 1].DSALES_Direccin__c;
                tienda=[SELECT DSALES_Direccin__c,DSALES_Cdigopostal__c,DSALES_Ciudad__c,DSALES_Estado__c FROM Tienda__c WHERE Id=:cotizacion.DSales_Tienda__c Limit 1];
            String direccion='';
            for(Tienda__c t: tienda)
            {
                
                if(tienda!=null){ //datos de la direción de la tienda SG
                    direccion='\n'+t.DSALES_Direccin__c+','+'\n';
                    direccion +='\n CP '+t.DSALES_Cdigopostal__c+','+t.DSALES_Ciudad__c+','+t.DSALES_Estado__c;
                    //html=html.replace('Tienda__c', direccion);
                }else
                {
                    html=html.replace('Tienda__c', '');
                }
            }
            
            
            Map<String, String> mapCampos = getField(NOMBRE_OBJETO);
            Map<String, String> mapCamposQuoteLineItem = getField(NOMBRE_OBJETO2);
            String query = 'Select ';
            String query2 = 'Select ';
            for(String item: mapCampos.keySet()){
                query += item+',';
            }
            for(String item2: mapCamposQuoteLineItem.keySet()){
                query2 += item2+',';
            }
            query = query.substring(0, query.length() -1);
            query += ' From Quote Where Id = :recordId';
            query2 = query2.substring(0, query2.length() -1);
            query2 += ' From QuoteLineItem Where QuoteId = :recordId';
            
            Quote coti = DataBase.query(query);
            html = html.replace('coti.', '');
            Integer contadora=0;
            List<QuoteLineItem> cotiLine = DataBase.query(query2);
            System.debug('*********Partidas**********'+cotiLine);
            List<String> idsPartidas = new List<String>();
            for(QuoteLineItem ql:cotiLine){
                idsPartidas.add(ql.DSALES_Plazo__c);

            }
            System.debug('ids partidas: '+ idsPartidas.size());
            List<Plazo__c> plazo=[SELECT Id,Dsales_Plazo__c,DSALES_Seguro__r.Name FROM Plazo__c WHERE Id IN: idsPartidas ];
           
            html = html.replace('Quote.', '');
            for(String item: mapCampos.keySet()){
                
                if(html.contains(item)){
                    String replace = '';
                    if(coti.get(item)!= null){
                        if(mapCampos.get(item) == NOMBRE_DATE){
                            replace = String.valueOf(Date.valueOf(coti.get(item)).format());
                        }else if (mapCampos.get(item) == NOMBRE_DOUBLE ){
                            replace = String.valueOf(Decimal.valueOf( String.valueOf(coti.get(item)) ).format());
                        }else{
                            replace = String.valueOf(coti.get(item));
                        }
                    }
                    html = html.replace(item, replace);
                        contadora++;
                    
                
                }
                
            }
            Integer count=0;
            Double total=0;
            Double total12=0;
            Double total24=0;
            //System.debug('html: '+html);
            String formato='<tr>';
            formato+='<td colspan="1" rowspan="1">DSALES_NombreProducto__c</td>';
                    formato+='<td colspan="1" rowspan="1">QuoteLineItem.Quantity</td>';
                    formato+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
                    formato+='<td colspan="1" rowspan="1">QuoteLineItem.DSALES_Fechadecompra__c</td>';
                    formato+='<td colspan="1" rowspan="1">QuoteLineItem.DSALES_PrecioTotal</td>';        
            formato+='</tr>';
            
            String formato2='<tr>';
            formato2+='<td colspan="1" rowspan="1">DSALES_NombreProducto__c</td>';
            formato2+='<td colspan="1" rowspan="1">DSALES_SKU__c</td>';
            formato2+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
            formato2+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
            formato2+='<td colspan="1" rowspan="1">8000</td>';
            formato2+='</tr>';
            
            
            String tdTotal='<tr>';
            tdTotal+='<td colspan="1" rowspan="1" >Total</td>';
            tdTotal+='<td colspan="1" rowspan="1">&nbsp;</td>';
            tdTotal+='<td colspan="1" rowspan="1">&nbsp;</td>';
            tdTotal+='<td colspan="1" rowspan="1">16000</td>';
            tdTotal+='<td colspan="1" rowspan="1">8000</td>';
            tdTotal+='</tr>';
            String tdTotalRem='';
            String tabla='';
            String tabla2='';
            String tabla3='';
            String tabla4='';
            double price=0;
            double tdPrice=0;
            double sgPrice=0;
            String formattedDate1='';
            double discount=0;
            String tablaMoto='';
            //motos tablas sin formato
            String tablaSucursal='<tr>';
            tablaSucursal+='<td colspan="1" rowspan="1">Sucursal: Tienda</td>';
            tablaSucursal+='</tr>';
            String tablaSucursal2='<tr>';
            tablaSucursal2+='<td colspan="1" rowspan="1">Sucursal</td>';
            tablaSucursal2+='</tr>';

            String tablaPrep='<tr>';
            tablaPrep+='<td colspan="1" rowspan="1">Preparado por:Vendedor</td>';
            tablaPrep+='</tr>';
            String tablaPrep2='<tr>';
            tablaPrep2+='<td colspan="1" rowspan="1">Preparado</td>';
            tablaPrep2+='</tr>';
            
            String tablaFecha='<tr>';
            tablaFecha+='<td colspan="1" rowspan="1">Fecha:</td>';
            tablaFecha+='<td colspan="1" rowspan="1">fechaCreacion</td>';
            tablaFecha+='</tr>';
            String tablaFechaCreacion='<tr>';
            tablaFechaCreacion+='<td colspan="1" rowspan="1">Fecha2</td>';
            tablaFechaCreacion+='<td colspan="1" rowspan="1">fechaCreacion2</td>';
            tablaFechaCreacion+='</tr>';
            String tablaFecha2='<tr>';
            tablaFecha2+='<td colspan="1" rowspan="1">Fechacaducidad:</td>';
            tablaFecha2+='<td colspan="1" rowspan="1">fechaFin</td>';
            tablaFecha2+='</tr>';
            String tablaFechaFin2='<tr>';
            tablaFechaFin2+='<td colspan="1" rowspan="1">Fechacaducidad2</td>';
            tablaFechaFin2+='<td colspan="1" rowspan="1">fechaFin2</td>';
            tablaFechaFin2+='</tr>';

            String tableEmailSG='<tr>';
            tableEmailSG+='<td colspan="1" rowspan="1">Correo:correo</td>';
            tableEmailSG+='</tr>';
            String tableEmailSG2='<tr>';
            tableEmailSG2+='<td colspan="1" rowspan="1">Correo2</td>';
            tableEmailSG2+='</tr>';

            String tableName='<tr>';
            tableName+='<td colspan="1" rowspan="1">Nombre:nombre</td>';
            tableName+='</tr>';
            String tableName2='<tr>';
            tableName2+='<td colspan="1" rowspan="1">Nombre2</td>';
            tableName2+='</tr>';
            String tablaConceptoSG='<tr>';
            tablaConceptoSG+='<td colspan="1" rowspan="1">Concepto</td>';
            tablaConceptoSG+='</tr>';

            String tablaConcepto2='<tr>';
            tablaConcepto2+='<td colspan="1" rowspan="1">Concepto2</td>';
            tablaConcepto2+='</tr>';

            String tablaConcepto2x='<tr>';
            tablaConcepto2x+='<td colspan="1" rowspan="1">Concepto3</td>';
            tablaConcepto2x+='</tr>';

            String tablaProductoSG='<tr>';
            tablaProductoSG+='<td colspan="1" rowspan="1">Producto</td>';
            tablaProductoSG+='<td colspan="1" rowspan="1">DSALES_NombreProducto__c</td>';
            tablaProductoSG+='</tr>';

            String tablaProducto2='<tr>';
            tablaProducto2+='<td colspan="1" rowspan="1">Cantidad</td>';
            tablaProducto2+='<td colspan="1" rowspan="1">QuoteLineItem.Quantity</td>';
            tablaProducto2+='</tr>';

            String tablaProducto3='<tr>';
            tablaProducto3+='<td colspan="1" rowspan="1">Precio por producto</td>';
            tablaProducto3+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
            tablaProducto3+='</tr>';

            String tablaProducto4='<tr>';
            tablaProducto4+='<td colspan="1" rowspan="1">Total</td>';
            tablaProducto4+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
            tablaProducto4+='</tr>';

            String tablaFechaSG='<tr>';
            tablaFechaSG+='<td colspan="1" rowspan="1">Fecha de entrega estimada</td>';
            tablaFechaSG+='<td colspan="0" rowspan="1">fechaEstimada</td>';
            tablaFechaSG+='</tr>';

            String tablaPresupuestoSG='<tr>';
            tablaPresupuestoSG+='<td colspan="1" rowspan="1">Nro de presupuesto</td>';
            tablaPresupuestoSG+='<td colspan="0" rowspan="1">Num</td>';
            tablaPresupuestoSG+='</tr>';

            String leyendaSG='<tr>';
            leyendaSG+='<td colspan="1" rowspan="1">Vendido y entregado por Coppel</td>';
            leyendaSG+='</tr>';

            String leyendaSG2='<tr>';
            leyendaSG2+='<td colspan="1" rowspan="1">SKU:QuoteLineItem.DSales_SKU_Producto__c</td>';
            leyendaSG2+='</tr>';
            String leyendaSG3='<tr>';
            leyendaSG3+='<td colspan="1" rowspan="1">plazo</td>';
            leyendaSG3+='</tr>';

            String tablaServicioSG='<tr>';
            tablaServicioSG+='<td colspan="1" rowspan="1">Servicio</td>';
            tablaServicioSG+='<td colspan="1" rowspan="1">DSALES_NombreProducto__c</td>';
            tablaServicioSG+='</tr>';

            String tablaServicioSG2='<tr>';
            tablaServicioSG2+='<td colspan="1" rowspan="1">CantidadServicio</td>';
            tablaServicioSG2+='<td colspan="1" rowspan="1">QuoteLineItem.Quantity</td>';
            tablaServicioSG2+='</tr>';

            String tablaServicioSG3='<tr>';
            tablaServicioSG3+='<td colspan="1" rowspan="1">PrecioServicio</td>';
            tablaServicioSG3+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
            tablaServicioSG3+='</tr>';

            String tablaServicioSG4='<tr>';
            tablaServicioSG4+='<td colspan="1" rowspan="1">TotalServicio</td>';
            tablaServicioSG4+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
            tablaServicioSG4+='</tr>';
            
            String tablaServicioSGx='<tr>';
            tablaServicioSGx+='<td colspan="1" rowspan="1">Servicio2</td>';
            tablaServicioSGx+='<td colspan="1" rowspan="1">DSALES_NombreProducto__c</td>';
            tablaServicioSGx+='</tr>';

            String tablaServicioSG2x='<tr>';
            tablaServicioSG2x+='<td colspan="1" rowspan="1">Cantidad2</td>';
            tablaServicioSG2x+='<td colspan="1" rowspan="1">QuoteLineItem.Quantity</td>';
            tablaServicioSG2x+='</tr>';

            String tablaServicioSG3x='<tr>';
            tablaServicioSG3x+='<td colspan="1" rowspan="1">Precio2</td>';
            tablaServicioSG3x+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
            tablaServicioSG3x+='</tr>';
            String tablaImagen='<tr>';
            tablaImagen+='<td colspan="1" rowspan="1">imagen1</td>';
            tablaImagen+='</tr>';
            String tablaImagen2='<tr>';
            tablaImagen2+='<td colspan="1" rowspan="1">imagen2</td>';
            tablaImagen2+='</tr>';
            String tablaImagen3='<tr>';
            tablaImagen3+='<td colspan="1" rowspan="1">imagen3</td>';
            tablaImagen3+='</tr>';
            String tablaImagen4='<tr>';
            tablaImagen4+='<td colspan="1" rowspan="1">imagen4</td>';
            tablaImagen4+='</tr>';

            String tablaServicioSG4x='<tr>';
            tablaServicioSG4x+='<td colspan="1" rowspan="1">Total2</td>';
            tablaServicioSG4x+='<td colspan="1" rowspan="1">QuoteLineItem.UnitPrice</td>';
            tablaServicioSG4x+='</tr>';

            String tablaMejora='<tr>';
            tablaMejora+='<td colspan="1" rowspan="1">Mejora tu vida</td>';
            tablaMejora+='</tr>';
            String tabDiv='<div style="display:flex">';
            String tablaMejora2='<tr>';
            tablaMejora2+='<td colspan="1" rowspan="1">Mejora tu vida 2</td>';
            tablaMejora2+='</tr>';
            String tablaP2='<tr>';
            tablaP2+='<td colspan="1" rowspan="1">plazo2</td>';
            tablaP2+='</tr>';
            String espacio ='<tr>';
            espacio+='<td colspan="1" rowspan="1">espacio</td>';
            espacio+='</tr>';
            String logoCoppel='<tr>';
            logoCoppel+='<td colspan="1" rowspan="1">logoCoppel</td>';
            logoCoppel+='</tr>';
            String espaciosTab = '<tr>';
            espaciosTab+='<td colspan="1" rowspan="1" style="height:auto">&nbsp;</td>';
            espaciosTab+='</tr>';
            //motos tablas con formato 
            String rempConcepto2='<tr>';
            rempConcepto2+='<td colspan="1" rowspan="1" height="35px" style="background:rgb(0,72,118 );border:solid; border-color:white;color:white;padding-left:15px;"><strong>Concepto</strong></td>';
            rempConcepto2+='</tr>';
            String rempSucSG='<tr>';
            rempSucSG+='<td colspan="1" rowspan="1"style="font-size:15px"><b>Sucursal:</b><br />';
            rempSucSG+= direccion + '</td>';
            //rempSucSG+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209);border-bottom: .2rem solid white;width:30%;border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Fecha creaci&oacute;n:</strong></td>';
            //rempSucSG+='<td colspan="1" rowspan="1" height="35px"style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .2rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;width:30%;text-align:center; font-size:12px">'+fechaFormato +'</td>';
            rempSucSG+='</tr>';
            String fechaFormato=cotizacion.DSALES_Fechadecreacionpresupuesto__c.format();
            System.debug('fechaFormato1:'+fechaFormato);
            String rempFecha='<tr>';
            rempFecha+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209);border-bottom: .2rem solid white;width:30%;border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Fecha creaci&oacute;n:</strong></td>';
            rempFecha+='<td colspan="1" rowspan="1" height="35px"style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .2rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;width:30%;text-align:center; font-size:12px">'+fechaFormato +'</td>';
            rempFecha+='</tr>';
            //fechaFormato=cotizacion.ExpirationDate.format();
            System.debug('fechaFormato2:'+fechaFormato);
            String rempSucSG1='<tr>';
            rempSucSG1+='<td colspan="1" rowspan="1" height="39px" style="font-size:15px;"><strong>Preparado por:</strong><br/>'+cotizacion.DSales_Vendedor__c+'</td>';
            // rempSucSG1+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209 );border-bottom: .2rem solid white;width:20%;border:solid; border-color:white; font-size:12px;padding-left:15px;"><strong>Fecha caducidad:</strong></td>';
            //rempSucSG1+='<td colspan="1" rowspan="1" height="35px"style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .2rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;width:30%;text-align:center; font-size:12px">'+fechaFormato+'</td>';
            rempSucSG1+='</tr>';
            String rempFecha2='<tr>';
            rempFecha2+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209 );border-bottom: .2rem solid white;width:20%;border:solid; border-color:white; font-size:12px;padding-left:15px;"><strong>Fecha caducidad:</strong></td>';
            rempFecha2+='<td colspan="1" rowspan="1" height="35px"style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .2rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;width:30%;text-align:center; font-size:12px">'+pago.DSALES_Fechadeentregaestimada__c.format()+'</td>';
            rempFecha2+='</tr>';
            //String nroCotizacion =cotizacion.QuoteNumber.replace('0000', '');
            String rempEspacio ='<tr>';
            rempEspacio+='<td colspan="1" rowspan="1"  style="font-size:5px;">&nbsp;</td>';
            rempEspacio+='</tr>';
            String rempPres='<tr>';
            rempPres+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209);border-bottom: .2rem solid white;width:20%;border:solid; border-color:white; font-size:12px;padding-left:15px;"><strong>Nro de presupuesto</strong></td>';
            rempPres+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;text-align:left; font-size:12px;padding-left:12px;width:20%">'+cotizacion.QuoteNumber+'</td>';
            rempPres+='</tr>';

            String rempLeyendaSG='<tr>';
            rempLeyendaSG+='<td colspan="1" rowspan="1" height="35px" style="width:20%;font-size:12px;padding-left:15px;"><b>Vendido y entregado por Coppel</b></td>';
            rempLeyendaSG+='</tr>';
            String tablaLine='<tr>';
            tablaLine+='<td colspan="1" rowspan="1">linea</td>';
            tablaLine+='</tr>';
            String tablaLine2='<tr>';
            tablaLine2+='<td colspan="1" rowspan="1">line</td>';
            tablaLine2+='</tr>';
            String rempEmailSG='<tr>';
            rempEmailSG+='<td colspan="1" rowspan="1" height="35px" style="font-size:15px;"><strong>Correo:</strong><br>'+cotizacion.Email+'</td>';
            rempEmailSG+='</tr>';
            String rempEmailSG2='<tr>';
            rempEmailSG2+='<td colspan="1" rowspan="1" height="35px" style="font-size:15px;padding-top:6px"><strong>Correo:</strong><br>'+cotizacion.Email+'</td>';
            rempEmailSG2+='</tr>';
            String rempName='<tr>';
            rempName+='<td colspan="1" rowspan="1" height="35px" style="font-size:15px"><strong>Nombre:</strong><br>'+cotizacion.Name+'</td>';
            rempName+='</tr>';
            
            //-----------------
            String tabAnt='<table border="1" cellpadding="0" cellspacing="0" style="height:auto; width:80%">';
            String tabRemp='<table border="0" cellpadding="0" cellspacing="0" style="height:auto; width:80%:float:left">';
            String tab2='<table border="0" cellpadding="0" cellspacing="0" style="height:auto;">';
            String tab2Remp='<table border="0" cellpadding="0" cellspacing="0" style="height:auto;float:right">';
            
            if(templateName==NOMBRE_Seguro2){
                String rempFechaSG='<tr>';
                rempFechaSG+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209 );border-bottom: .2rem solid white;width:20%;border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Fecha de entrega estimada</strong></td>';
                rempFechaSG+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;text-align:left; font-size:12px;padding-left:12px;width:20%;"><strong>'+pago.DSALES_Fechadeentregaestimada__c.format()+'</strong></td>';
                rempFechaSG+='</tr>';
                String rempImagen1='<tr>';
                //rempImagen1+='<td colspan="1" rowspan="1" style="height:auto; width:70px;"></td>';
                //rempImagen1+='<td colspan="1" rowspan="1"style="height:auto; width:70px;"></td>';
                rempImagen1+='<td colspan="1" rowspan="1" style="height:auto; width:40px;text-align:right;background-color:rgb(238, 238, 238 ); border-bottom:2pt solid white;"><img src="https://coppelmx--pisysdev2--c.sandbox.vf.force.com/resource/1674077199000/DSALES_ClubProteccionMotos?" style="height:60px;" /></td>';

                String rempImagen2='<tr>';
                //rempImagen2+='<td colspan="1" rowspan="1" style="height:auto; width:70px;"></td>';
                //rempImagen2+='<td colspan="1" rowspan="1" style="height:auto; width:70px;"></td>';
                rempImagen2+='<td colspan="1" rowspan="1" style="height:auto; width:50px;text-align:center;background-color:rgb(238, 238, 238 );font-family:italic; font-size:10px"><div><p style="color:#238DC1"><strong>VIAJA TRANQUILO Y <br>PROTEGIDO </strong></p><p style="text-align: center;">Un seguro creado para <br>acompañarte y asistirte<br> ante los imprevistos que <br> se presentan en tu camino.</p><img src="https://coppelmx--pisysdev2--c.sandbox.vf.force.com/resource/1673912662000/DSALES_MotoSG?" style="height:60px; " /></div></td>';
                html=html.replace(tablaFechaSG,rempFechaSG);
                html=html.replace(tablaFecha, rempFecha);
                html=html.replace(tablaFecha2, rempFecha2);
                //html=html.replace(tablaFechaSG,rempFechaSG);
                html=html.replace(tablaImagen,rempImagen1);
                html=html.replace(tablaImagen2,rempImagen2);
                html=html.replace(espacio, rempEspacio);
                if(cotiLine!=null && cotiLine.size()==2){
                    for(QuoteLineItem quote: cotiLine){
                        System.debug('partidas:'+quote);
                        Product2 producto = [SELECT DSales_Tipo_de_Producto__c FROM Product2 WHERE ID=:quote.Product2Id ];
                        String rempServ='<tr>';
                        rempServ+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209);border-bottom: .2rem solid white;width:15%;border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Servicio</strong></td>';
                        rempServ+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;white;width:20%;text-align:left;font-size:12px;padding-left:15px;">'+quote.DSALES_NombreProducto__c+'</td>';
                        rempServ+='</tr>';
                        String cantidadSeg =String.valueOf(quote.Quantity).replace('.00', '');
                        String rempServ2='<tr>';
                        rempServ2+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209 );border-bottom: .2rem solid white;width:50%; border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Cantidad</strong></td>';
                        rempServ2+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;text-align:left; font-size:12px;padding-left:12px;">'+cantidadSeg+'<td>';
                        rempServ2+='</tr>';
                        String rempServ3='<tr>';
                        rempServ3+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209);border-bottom: .2rem solid white;width:50%; border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Precio por producto</strong></td>';
                        rempServ3+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;text-align:left;font-size:12px;padding-left:15px;">'+'$'+quote.UnitPrice+'</td>';
                        rempServ3+='</tr>';
                        String rempServ4='<tr>';
                        rempServ4+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(209, 209, 209 );border-bottom: .2rem solid white;width:50%; border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Total</strong></td>';
                        rempServ4+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;white;text-align:left; font-size:12px;padding-left:15px;"><strong>'+'$'+quote.TotalPrice+'</strong></td>';
                        rempServ4+='</tr>';
                        String rempProduc='<tr>';
                        rempProduc+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(242, 242, 242 );border-bottom: .2rem solid white;width:20%;border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Producto</strong></td>';
                        rempProduc+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;white;width:20%;text-align:left;font-size:12px;padding-left:15px;">'+quote.DSALES_NombreProducto__c+'</td>';
                        rempProduc+='</tr>';
                        cantidadSeg =String.valueOf(quote.Quantity).replace('.00', '');
                        String rempProduc2='<tr>';
                        rempProduc2+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(242, 242, 242 );border-bottom: .2rem solid white;width:50%; border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Cantidad</strong></td>';
                        rempProduc2+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;text-align:left; font-size:12px;padding-left:12px;">'+cantidadSeg+'<td>';
                        rempProduc2+='</tr>';
                        String rempProduc3='<tr>';
                        rempProduc3+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(242, 242, 242 );border-bottom: .2rem solid white;width:50%; border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Precio por producto</strong></td>';
                        rempProduc3+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;text-align:left;font-size:12px;padding-left:15px;">'+'$'+quote.UnitPrice+'</td>';
                        rempProduc3+='</tr>';
                        String rempProduc4='<tr>';
                        rempProduc4+='<td colspan="1" rowspan="1" height="35px" style="background-color:rgb(242, 242, 242 );border-bottom: .2rem solid white;width:50%; border:solid; border-color:white;font-size:12px;padding-left:15px;"><strong>Total</strong></td>';
                        rempProduc4+='<td colspan="1" rowspan="1" style="border:solid; border-color:rgb(242, 242, 242);border-bottom: .1rem solid #cecbc9;border-top: .1rem solid #cecbc9;border-left: .2rem solid #cecbc9;border-right: .2rem solid #cecbc9;white;text-align:left; font-size:12px;padding-left:15px;"><strong>'+'$'+quote.TotalPrice+'</strong></td>';
                        rempProduc4+='</tr>';
                        
                        String rempSku='<tr>';
                        rempSku+='<td colspan="1" rowspan="1" style="text-align:left; width:50%; color:rgb(189,189,189);font-size:12px;padding-left:15px;">SKU:'+quote.DSALES_SKU__c+'</td><br>';
                        rempSku+='</tr>';
                        
                        String rempMejora='<tr>';
                        rempMejora+='<td colspan="1" rowspan="1" style="color:#238DC1;font-size:12px"><strong>Mejora tu vida</strong></td>';
                        rempMejora+='</tr>';
                        String rempLine='<tr>';
                        rempLine+='<td colspan="1" rowspan="1"><hr style="color:#238DC1; border-color:#238DC1;size:3;" /></td>';
                        rempLine+='</tr>';
                        html=html.replace(tablaLine, rempLine);
                        html=html.replace(tablaSucursal,rempSucSG);
                        html=html.replace(tablaPrep,rempSucSG1);
                        html=html.replace(tablaMejora, rempMejora);
                        html=html.replace(leyendaSG,rempLeyendaSG);
                        html=html.replace(tableEmailSG, rempEmailSG);
                        html=html.replace(tableName, rempName);
                        //html=html.replace(tablaP2,rempTablaP2);
                        ///presupues
                        html=html.replace(tablaPresupuestoSG,rempPres);
                        if(producto.DSales_Tipo_de_Producto__c=='Producto'){
                            System.debug('producto:'+quote);
                            
                            html=html.replace(tablaConceptoSG,rempConcepto2);
                            html=html.replace(tablaProductoSG,rempProduc);
                            html=html.replace(tablaProducto2,rempProduc2); 
                            html=html.replace(tablaProducto3,rempProduc3);
                            html=html.replace(tablaProducto4,rempProduc4);
                            html=html.replace(leyendaSG2,rempSku);
                            
                            //html=html.replace(leyendaSG3,rempleyendaSG3);
                        }
                        
                        if(producto.DSales_Tipo_de_Producto__c=='Seguro'){
                            if(quote.DSALES_NombreProducto__c=='AMP Seguro de Moto'){
                                System.debug('amp:'+quote);
                                String plazoSeg='';
                                System.debug('Nombre de seguro:'+quote.DSALES_NombreProducto__c);
                                for(Plazo__c pl:plazo){
                                    System.debug('nombre plazo:'+pl.DSALES_Seguro__r.Name);
                                    if(quote.DSALES_Plazo__c==pl.Id){
                                        System.debug('es igual:'+pl.DSALES_Seguro__r.Name);
                                        plazoSeg=pl.Dsales_Plazo__c;
                                    }
                                }
                                System.debug('plazo a mostrar2:'+plazoSeg);
                                String rempleyendaSG3='<tr>';
                                rempleyendaSG3+='<td style="background-color:#238DC1;width:2%;">&nbsp;</td>';
                                rempleyendaSG3+='<td colspan="1" rowspan="1" style="background-color:rgb(242, 242, 242 );text-align:left;font-size:12px;padding-left:15px;border-bottom:2pt solid white;">Seguro de motos a '+ plazoSeg+' meses <strong>Club de Protecci&oacute;n de Motos</strong></td>';
                                rempleyendaSG3+='</tr>';
                                //tablas con los datos de los seguros
                                html=html.replace(leyendaSG3,rempleyendaSG3);
                                html=html.replace(tabAnt, tabRemp);
                                html=html.replace(tablaServicioSG,rempServ);
                                html=html.replace(tablaConcepto2,rempConcepto2);
                                html=html.replace(tablaServicioSG2,rempServ2);
                                html=html.replace(tablaServicioSG3,rempServ3);
                                html=html.replace(tablaServicioSG4,rempServ4);
                                html=html.replace(tablaServicioSGx,'');
                                html=html.replace(tablaConcepto2x,'');
                                html=html.replace(tablaServicioSG2x,'');
                                html=html.replace(tablaServicioSG3x,'');
                                html=html.replace(tablaServicioSG4x,'');
                            }

                        
                        }
                    }

                }
                
            }
            html=html.replace('null', '________');

        }catch(Exception e){
            System.debug('********2plant*******'+e.getLineNumber() + e.getMessage());
        }
    }   
}