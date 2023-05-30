@SuppressWarnings('PMD.AvoidGlobalModifier')
global class DSALES_VentaSM {
	global class VentaSMRequest{
		global String idCotizacion{get;set;}
		global List<String> idPartidaPresupuesto{get;set;}
		global DSALES_PaymentInfoWrapper.PaymentRequest pagos {get;set;}
		global DSALES_IPAssetWrapper.IPAssetRequest activo {get;set;}
		global Boolean beneficiarioPreferente{get;set;}
		global Boolean envioContratante {get;set;}
		global String contratante{get;set;}
		global List<DatosParticipante> datosParticipantes { get; set; } 
	}

	global class DatosParticipante {
		//global Boolean contratante {get;set;}
		global String figura { get; set; }
		global String numeroCliente { get; set; }
		global String nombre { get; set; }
		global String apellidoPaterno { get; set; }
		global String apellidoMaterno { get; set; }
		global String relacionConParticipante {get;set;}
		global String porcentaje{get;set;}
		global String telefono { get; set; }
		global String correoElectronico { get; set; }
		global String genero { get; set; }
		global Date fechaNacimiento { get; set; }
		global String rfc { get; set; }
		global Integer codigoPostal { get; set; }
		global String codigoEstado { get; set; }
		global String codigoCiudad { get; set; }
		global String codigoColonia { get; set; }
		global String calle { get; set; }
		global String numeroExterior { get; set; }
		global String numeroInterior { get; set; } 
	}
	global class ListaPartidasOportunidad{
		global String idPartidaOportunidad { get; set; }
		global String nombreProducto { get; set; }
		global String sku { get; set; }
	}

	global class VentaSMResponse{
		global Boolean exito {get;set;}
		global String mensajeError {get;set;}
		global Integer codigoError {get;set;}
		global String idUniversal{get;set;}
		global List<ListaPartidasOportunidad> listaPartidasOportunidad { get; set; }
		global DatosParaEmitir datosParaEmitir { get; set; } 
		
	}

	global class IdsARetornar{
		global List<DSALES_VentaSM.ListaPartidasOportunidad> listaPartidas {get;set;}
		global String idActivo {get;set;}
	}


	/////////////////////////////////////////////////
	global class DatosParaEmitir {
		global DatosSeguro datosSeguro { get; set; } 
		global DatosVehiculo datosVehiculo { get; set; } 
		global String beneficiarioPreferente {get;set;}
		global String contratante {get;set;}
		global DatosContratante datosContratante {get;set;}
		global DatosConductor datosConductor {get;set;}
		//global List<DatosParticipante> participante { get; set; } 
		
	}
	global class DatosContratante {
		//global String nombre { get; set; }
		//global String apellidoPaterno { get; set; }
		//global String apellidoMaterno { get; set; }
		global String telefono { get; set; }
		global String correoElectronico { get; set; }
		global String segundoCorreoContratante {get;set;}
		global String nacionalidadSociedad {get;set;}
		global Date fechaConstitucion{get;set;}
		global String giroComercial{get;set;}
		global String tipoPersona{get;set;}
		global String nombreApoderadoLegal {get;set;}
		global String contratante {get;set;}
		global String actividad {get;set;}
		global String genero { get; set; }
		global Date fechaNacimiento { get; set; }
		global String rfc { get; set; }
		global Integer codigoPostal { get; set; }
		global String codigoEstado { get; set; }
		global String codigoCiudad { get; set; }
		global String codigoColonia { get; set; }
		global String calle { get; set; }
		global String numeroExterior { get; set; }
		global String numeroInterior { get; set; } 
	}
	global class DatosConductor {
		global String nombre { get; set; }
		global String apellidoPaterno { get; set; }
		global String apellidoMaterno { get; set; }
		global String telefono { get; set; }
		global String correoElectronico { get; set; }
		global String genero { get; set; }
		global Date fechaNacimiento { get; set; }
		global String rfc { get; set; }
		global Integer codigoPostal { get; set; }
		global String codigoEstado { get; set; }
		global String codigoCiudad { get; set; }
		global String codigoColonia { get; set; }
		global String calle { get; set; }
		global String numeroExterior { get; set; }
		global String numeroInterior { get; set; } 
	}
	global class DatosSeguro {
		global string trackingId { get; set; }
		global string quote_id { get; set; }
		global string negocio { get; set; }
		global string aseguradora { get; set; }
		global string paquete { get; set; }
		global string planPago { get; set; }
		global string opcionPago { get; set; }
		global string tarjetaPago { get; set; }
		global string codigoPromocion { get; set; }
		global string idAsociado { get; set; }
		global Date fechaEmision { get; set; }
		global Date fechaInicio { get; set; }
		global Integer sumaAsegurada {get;set;}
		global String valorfactura{get;set;}
	   
	   }
	  
	global class DatosVehiculo {
		global string idVehiculo { get; set; }
		global string sevicio { get; set; }
		global string uso{ get; set; }
		global string numeroSerie { get; set; }
		global string placas { get; set; }
		global string tipo { get; set; }
		global string modelo { get; set; }  
	}
	  
}