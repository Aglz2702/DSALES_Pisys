@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_PolizaWrapper {
    global class Request{
        global String quote_id { get; set; }
        global String quote {get;set;}
        global String idEmision { get; set; }
        global String trackingId { get; set; }
        //global String nombrePoliza { get; set; }
        global String numeroPoliza { get; set; }
        global String urlPdf { get; set; }
        global Date fechaVigencia { get; set; }
        global Date fechaVencimiento { get; set; }
        global Date fechaEmision { get; set; }
        global String sumaAsegurada { get; set; }
        global String primaNeta { get; set; }
        global String primaTotal { get; set; }
        global String gastosExpedicion { get; set; }
        global Decimal iva { get; set; } 
        global String mensaje {get;set;}
    }
    global class Response {
        global List<DSALES_VentaSMRest.WrapperDatosProductos> listaPartidasOportunidad{get;set;}
        global Boolean exito{get;set;}
        global Integer codigoError{get;set;}
        global String mensajeError{get;set;}
    }   
}