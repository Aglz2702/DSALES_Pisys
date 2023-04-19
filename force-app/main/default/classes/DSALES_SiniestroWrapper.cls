global class DSALES_SiniestroWrapper {
    global class siniestroCallPost { 
        global String uid { get; set;}
        global String Reporte { get; set;}
        global String NumeroSiniestro { get; set;}
        global String TipoSiniestro { get; set;}
        global String FechaSiniestro { get; set;}
        global String NombreConductor { get; set;}
        global String Causa { get; set;}

        global vehiculo Vehiculo { get; set;}
        global poliza Poliza { get; set;} //minuscula

        global String ComoOcurrio { get; set;}
        global String Ubicacion { get; set;}
        global String Municipio { get; set;}
        global String Estado { get; set;}
        global String Estatus { get; set;}
        global String salesforceid { get; set;}
    }

    global class vehiculo{
        global String Descripcion { get; set;}
        global String Anio { get; set;}
        global String Placa { get; set;}
        global String Serie { get; set;}
    }

    global class poliza{
        global String numeroPoliza { get; set;}
        global String Inciso { get; set;}
        global String FechaInicioVigencia { get; set;}
        global String FechaFinVigencia { get; set;}
        global String NombreAsegurado { get; set;}
    }

    global class siniestroPostResponse{
        global Boolean success { get; set;}
        global String mensaje { get; set;}
        global Integer codigo_error { get; set;}
        global String id_siniestro { get; set;}      
    }

    global class siniestro{
        global String uid { get; set;}
        global String NumeroSiniestro { get; set;}
    }

    global class SiniestroPut{
        global String uid { get; set;}
        global String Reporte { get; set;}
        global String NumeroSiniestro { get; set;}
        global String TipoSiniestro { get; set;}
        global String FechaSiniestro { get; set;}
        global String NombreConductor { get; set;}
        global String Causa { get; set;}

        global vehiculo Vehiculo { get; set;}
        global poliza Poliza { get; set;}

        global String ComoOcurrio { get; set;}
        global String Ubicacion { get; set;}
        global String Municipio { get; set;}
        global String Estado { get; set;}
        global String Estatus { get; set;}
        global String salesforceid { get; set;}       
    }

    global class comprobantesTenencia{
        global String Descripcion { get; set;} 
        global String Comprobante { get; set;} 
        global String IdComprobante { get; set;} 
        
    }

    global class SiniestroGet{
        global String uid { get; set;}
        global String reporte { get; set;}
        global String numeroSiniestro { get; set;}
        global String tipoSiniestro { get; set;}
        global String fechaSiniestro { get; set;}
        global String nombreConductor { get; set;}
        global String causa { get; set;}

        global vehiculo vehiculo { get; set;}
        global poliza poliza { get; set;}
		global List<listaSiniestros> listSiniestro{get;set;}
        global String comoOcurrio { get; set;}
        global String ubicacion { get; set;}
        global String municipio { get; set;}
        global String estado { get; set;}
        global String estatus { get; set;}

        global String solucionDevolucion { get; set;}
        global String motivoDevolucion { get; set;}
        global String saldoinsoluto {get;set;}
        global String motivoRechazo {get;set;}
        global String salesforceid { get; set;}       
    }
        global class listaSiniestros{
        //Informacion de Resumen de pago de poliza
        global String claimpayment_name{get;set;}
        global Double payment_amount{get;set;}
        global String payment_type{get;set;}
        global Date payment_date{get;set;}
    }

}