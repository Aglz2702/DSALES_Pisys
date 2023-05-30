public class DSALES_Utility {
    
    public static final String NUMERO_CLIENTE_GENERICO = '90001';
    public static final String BAD_REQUEST_MSJ = 'Malformed JSON: Expected';
    public static final String INTERNAL_ERROR_MSJ = 'Internal Error';
    public static final Integer BAD_REQUEST_CODE = 400;
    public static final Integer INTERNAL_ERROR_CODE = 500;
    public static final String SEGURO_PREDETERMINADO = 'PÓLIZA UNIVERSAL';
    public static final String FIGURA_CONDUCTOR ='Conductor';
    public static final String FIGURA_CONTRATANTE='Contratante';
    public static String getEndpoint(String nombreURL){
        try{
            DSALES_RutaIntegracion__mdt ruta = DSALES_RutaIntegracion__mdt.getInstance(nombreURL); 
            return ruta.DSALES_Endpoint__c;
        }catch(Exception ex){
            return null;
        }
    }
    public static String getNombreContratante(String nombre){
         try{
            dsalesDatosContratante__mdt contratante = dsalesDatosContratante__mdt.getInstance(nombre);
            return contratante.dsalesNombre__c;
         }catch(Exception ex){
            return null;
        }    
    }

}