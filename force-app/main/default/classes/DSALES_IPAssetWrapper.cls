@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_IPAssetWrapper {
    global class IPAssetRequest{
        global Boolean emitirPoliza {get;set;}
        global String idUniversal {get;set;}
        global String uso { get; set; }
        global String claveTienda { get; set; }
        global String servicio { get; set; }
        global String numeroSerie { get; set; }
        global String numeroMotor { get; set; }
        global String modelo { get; set; }
        global String placas { get; set; }
        global String claveVehicular { get; set; }
        global Integer valorFactura { get; set; }
        global Boolean bajoDemanda { get; set; }
        global String descripcion { get; set; }
        global String marca { get; set; }
        global String nombreActivo { get; set; }
        //global String id_pago { get; set; }
    }
    global class IPAssetResponse{
        global List<DSALES_VentaSMRest.WrapperDatosProductos> listaPartidasOportunidad {get; set;}
        global Boolean exito {get;set;}
        global String mensajeError {get;set;}
        global Integer codigoError {get;set;}
        global DSALES_VentaSM.DatosParaEmitir datosParaEmitir {get;set;}
       
    }

    global class ListaPartidasOportunidad
		{
			global String idPartidaDeOportunidad { get; set; }
			global String nombreProducto { get; set; }
			global String sku { get; set; }
		}
    global class Seguro
    {
        global String urlPdfPoliza { get; set; }
        global String poliza { get; set; }
    }
}