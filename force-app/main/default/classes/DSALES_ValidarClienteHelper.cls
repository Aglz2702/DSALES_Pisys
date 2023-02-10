public class DSALES_ValidarClienteHelper {    
    public static void deleteUnpurchasedItem(List<DSALES_AssetWrapper.AssetRequest> listAssets, List<DSALES_CertificadoWrapper.CertificadoRequest> certificado, String quoteId) {
        Quote originalQuote = [SELECT Id, Name,OpportunityId, DSALES_EmailNew__c, Pricebook2Id, RecordTypeId, Status, DSALES_Enviarcotizacion__c, DSales_Tienda__c, DSales_Vendedor__c,
                               DSALES_Fechadecreacionpresupuesto__c, ExpirationDate, DSALES_esClon__c FROM Quote WHERE Id = :quoteId ]; 
        
        List<QuoteLineItem> unpurchasedItems= new List<QuoteLineItem>();        
        List<String> productSKUs = new List<String>();
        for(DSALES_AssetWrapper.AssetRequest a:listAssets){
            productSKUs.add(a.sku_de_tangible);
        }
        If(listAssets!= null){
            List<QuoteLineItem>quoteLineMap= [SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2Id,DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Producto'AND DSALES_SKU__c NOT IN:productSKUs ]; 
            unpurchasedItems.addAll(quoteLineMap);
            
        }
        If(listAssets== null){
            List<QuoteLineItem>quoteLineMap= [SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2Id, DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Producto']; 
            unpurchasedItems.addAll(quoteLineMap);
            
        }
        
        List<String> quoteLineItemId = new List<String>();
        List<String> lstSku = new List<String>();
        //List<id> lstwotId= new List<id>();
        List<String> lstwotId = new List<String>();
        
        for(DSALES_CertificadoWrapper.CertificadoRequest cer:certificado){
            quoteLineItemId.add(cer.id_partida_presupuesto);
            lstSku.add(cer.sku);
        }
        List<QuoteLineItem>warrantyMap= [SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2.StockKeepingUnit,Product2Id, DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Servicio'AND Id NOT IN:quoteLineItemId AND DSALES_SKU__c  IN:lstSku ];
       
            delete warrantyMap;
        
        List<QuoteLineItem>quoteLineMap=[SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2.StockKeepingUnit,Product2Id, DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Servicio'AND Id NOT IN:quoteLineItemId];
           unpurchasedItems.addAll(quoteLineMap);

        
        If(certificado== null){
            List<QuoteLineItem>quoteLine= [SELECT Id,Quantity,PricebookEntryId,UnitPrice,Product2Id, DSALES_ListaArticulo__c, Vigencia_meses__c FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Servicio']; 
            unpurchasedItems.addAll(quoteLine);
            
        }
        If(unpurchasedItems.size()>0){
            Quote unpurchasedQuote = originalQuote.clone(false, true);
            //unpurchasedQuote.RecordTypeId=originalQuote.RecordTypeId;
            unpurchasedQuote.Name = originalQuote.Name;
            unpurchasedQuote.OpportunityId=originalQuote.OpportunityId;            
            unpurchasedQuote.DSALES_Enviarcotizacion__c = false;
            try{   
                insert unpurchasedQuote;
                List<QuoteLineItem> item= new List<QuoteLineItem>();
                for (QuoteLineItem items : unpurchasedItems) {              
                    QuoteLineItem newItem = new QuoteLineItem();
                    newItem.QuoteId = unpurchasedQuote.Id;
                    newItem.Quantity= items.Quantity;
                    newItem.PricebookEntryId= items.PricebookEntryId;
                    newItem.UnitPrice= items.UnitPrice;
                    newItem.Product2Id= items.Product2Id;
                    newItem.DSALES_ListaArticulo__c= items.DSALES_ListaArticulo__c;
                    newItem.Vigencia_meses__c= items.Vigencia_meses__c;
                    item.add(newItem);  
                } 
                
                insert item;
                DELETE unpurchasedItems;
                
                unpurchasedQuote.Status = 'Enviada';
                unpurchasedQuote.DSALES_Enviarcotizacion__c=true;
                unpurchasedQuote.DSALES_esClon__c=true;
                system.debug('Id del quote a borrar: '+unpurchasedQuote.Id);
                update unpurchasedQuote;
                actualizarCotizacion(quoteId);
                //DELETE unpurchasedQuote;
            }  catch (DmlException e) {
                System.debug('Error occured: ' + e);
            }
             
        }  
        
       
    }
    
    //@future(callout=true)
    public static void actualizarCotizacion(String quoteId){
        Quote cotizacion = [SELECT Id,AccountId,OpportunityId,Opportunity.AccountId FROM Quote WHERE Id= :quoteId];
        List<Opportunity> oppor= new List<Opportunity>(); 
        oppor = [SELECT Id, StageName,SyncedQuoteId FROM opportunity WHERE Id=:cotizacion.OpportunityId ];
        If(oppor.size()>0){
            System.debug(oppor);
            for(Opportunity opp:oppor){
                opp.StageName='Cerrada ganada';
                opp.SyncedQuoteId=cotizacion.Id;
                
            } 
            try{
                Update oppor;
                
            }catch(DmlException e){
                System.debug('Error occured: ' + e);  
            }
        }
    }
    
    /*  
//quote has Client´s email & name

public static void deleteTangibles(List<DSALES_AssetWrapper.AssetRequest> listAssets, String quoteId){
Quote originalQuote = [SELECT Id, Name FROM Quote WHERE Id = :quoteId];              
List<QuoteLineItem> unpurchasedItems = new List<QuoteLineItem>();
Map<String, Boolean> purchasedSKUs = new Map<String, Boolean>();
for(DSALES_AssetWrapper.AssetRequest a:listAssets){
purchasedSKUs.put(a.sku_de_tangible, true);            
}
for (QuoteLineItem item : [SELECT Id,DSALES_SKU__c  FROM QuoteLineItem WHERE QuoteId = :quoteId and Product2.DSales_Tipo_de_Producto__c='Producto']) {
if (!purchasedSKUs.containsKey(item.DSALES_SKU__c)) {
unpurchasedItems.add(item);
}
}

}

public static void recepcionProductos(List<DSALES_CertificadoWrapper.CertificadoRequest>certificado, String quoteId){ 
Map<Id, Boolean> purchasedWarranties = new Map<Id, Boolean>();
for(DSALES_CertificadoWrapper.CertificadoRequest c:certificado){           
purchasedWarranties.put(c.id_partida_presupuesto, true);                  //purchased Warranties.

}
Quote originalQuote = [SELECT Id, Name FROM Quote WHERE Id = :quoteId];
List<QuoteLineItem>quoteLineMap= [SELECT id FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Servicio']; 

//Sku:1234 Computer + warranty 12 months.
//Sku:1234 24 months
//Sku:1234 36 months
List<QuoteLineItem> item= new List<QuoteLineItem>();
// item=[SELECT DSALES_SKU__c FROM QuoteLineItem WHERE id IN:id_quotelineitem];
// if(certificado == null){
// List<QuoteLineItem>quoteLineMap= [SELECT id FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Servicio'AND Id NOT IN:id_quotelineitem ]; 

//AND DSALES_SKU__c NOT IN:sku
// item.addAll(quoteLineMap);
// DELETE item;

// }
for (QuoteLineItem lineItem : quoteLineMap) {
if (!purchasedWarranties.containsKey(lineItem.Id)) {
item.add(lineItem);
}
}

}
*/   
    
    
    
    /*public static void deleteTangibles(List<DSALES_AssetWrapper.AssetRequest>listAssets, String quoteId)
{

Map<String,QuoteLineItem>quoteLineMapTan= new map<String,QuoteLineItem>();
for(QuoteLineItem qt:[SELECT DSALES_SKU__c,Vigencia_meses__c,id FROM QuoteLineItem WHERE QuoteId=:quoteId and Product2.DSales_Tipo_de_Producto__c='Producto'])
{
quoteLineMapTan.put(qt.DSALES_SKU__c + qt.Vigencia_meses__c,qt);
}

Integer meses;
for(DSALES_CertificadoWrapper.CertificadoRequest certi: certificado)
{
meses=Integer.valueOf(certi.warranty_duration);
if(quoteLineMap.containskey(certi.sku+meses))
{
quoteLineMap.remove(certi.sku+meses);
}

}
DELETE quoteLineMap.values();

}*/
    /*
public static String ValidarCliente(String quoteId)
{
String clienteId;
Integer contadora=0;
String email,name,accountNumber,telephone,Product2Id;
//quoteId='0Q08J000000D4U2SAK';


try{


Quote coti = [Select id, DSALES_EmailNew__c, OpportunityId,Name FROM Quote WHERE Id=:quoteId];
Opportunity oppor=[SELECT AccountId FROM Opportunity WHERE Id=:coti.OpportunityId LIMIT 1];
system.debug('Su account Id es: '+oppor.AccountId);
email=coti.DSALES_EmailNew__c;
name=coti.Name;

//if the client doesn´t exist, then create it.

Account nameAccount=[SELECT Name FROM Account WHERE ID=:oppor.AccountId LIMIT 1];
system.debug('Su account Id es: '+nameAccount.Name);
//   if(pago.DSALES_Cliente__r.Name.Contains('90001'))

if(nameAccount.Name.Contains(DSALES_Utility.NUMERO_CLIENTE_GENERICO))
{

List<Account> acc = [SELECT Id FROM Account WHERE Name=:Name OR PersonEmail=:email  LIMIT 1];


if(acc.size()==0)
{
RecordType record= [SELECT id FROM RECORDTYPE WHERE Name='Cuenta personal'];
Account cliente = new Account(RecordTypeId=''+record.Id,FirstName=Name,LastName=Name,PersonEmail=email,PersonMobilePhone=telephone);
insert cliente;
oppor.AccountId=cliente.Id;
clienteId=cliente.Id;
upsert oppor;
//Step 2

system.debug('Si pasó, y el Id del nuevo cliente es: ' +cliente.Id);
}
else
{
system.debug('Ya existe un cliente con el siguiente id: '+ acc[contadora].Id);
clienteId=acc[contadora].Id;
contadora++;

}
}
else
{
clienteId=oppor.AccountId;
}

}
catch(Exception e)
{
system.debug('No pasó ');
String message= e.getMessage() + ' '+e.getLineNumber() + ' '+e.getCause();
System.debug(message);
}

return clienteId;

}
*/
    //comparing QuoteLineItem products with Asset object 
    /* 
public static void insertProduct(List<DSALES_AssetWrapper.AssetRequest> lstAsset, String accountId, String quoteId){
List<QuoteLineItem> quotitem1 =  [SELECT Id, QuoteId, Product2Id, DSales_SKU_Producto__c FROM QuoteLineItem where QuoteId=:quoteId AND DSALES_ListaArticulo__c= 'Producto'];
List<QuoteLineItem> lstItem1 = new  List<QuoteLineItem>();
for(DSALES_AssetWrapper.AssetRequest ass: lstAsset ){
for(QuoteLineItem item:quotitem1){
if(item.DSales_SKU_Producto__c!= ass.sku){
ass.account_id=accountId;
QuoteLineItem cot = new QuoteLineItem();
cot.DSales_SKU_Producto__c= ass.sku;
cot.Vigencia_meses__c = ass.months;
lstItem1.add(cot);
}

} 
}

upsert lstItem1;
System.debug('updated list of QuoteLineItem is------->' +lstItem1);
}
// Comparing QuoteLineItem service with Certificado object

public static void insertService(List<DSALES_CertificadoWrapper.CertificadoRequest> lstcert, String quoteId, String accountId){
List<QuoteLineItem> quotitem =  [SELECT Id, QuoteId, Product2Id, DSales_SKU_Producto__c FROM QuoteLineItem where QuoteId=:quoteId AND DSALES_ListaArticulo__c= 'Servicio'];
List<QuoteLineItem> lstItem = new  List<QuoteLineItem>();
List<QuoteLineItem> lstItem1 = new  List<QuoteLineItem>();

for(DSALES_CertificadoWrapper.CertificadoRequest certificate: lstcert ){
string monthsValidity= string.valueOf(certificate.warranty_duration);            
for(QuoteLineItem item:quotitem){
if(item.DSales_SKU_Producto__c== certificate.sku &&  item.Vigencia_meses__c!= monthsValidity){
lstItem1.add(item);
} 
else if(quotitem.size()== 0 || quotitem == null){
QuoteLineItem cot = new QuoteLineItem();
cot.DSales_SKU_Producto__c= certificate.sku;
cot.Vigencia_meses__c = monthsValidity;
lstItem.add(cot);
}
}

}
upsert lstItem;
Delete lstItem1;
System.debug('Updated list of QuoteLineItem is------->' +lstItem);        
System.debug('Deleted list of QuoteLineItem is------->' +lstItem1);


}  
      
          for(QuoteLineItem item:quoteLineMap){
              for(DSALES_CertificadoWrapper.CertificadoRequest cert:certificado){
                     if(lstSku.contains(item.Product2.StockKeepingUnit) && item.Product2.StockKeepingUnit== cert.sku && item.Product2.StockKeepingUnit== cert.id_partida_presupuesto) {
                        lstwotId.add(item.Product2.StockKeepingUnit);
                            }
                        }
                  }
             if(lstwotId.size() > 0) {
              lstwotId.clear();
                 }

           
        for(Product2 t: [Select StockKeepingUnit,Id from Product2 where StockKeepingUnit in :lstSku and DSales_Tipo_de_Producto__c='Servicio']){
            for(DSALES_CertificadoWrapper.CertificadoRequest cert:certificado){
                If(string.valueOf(t.StockKeepingUnit)==cert.id_partida_presupuesto && String.isEmpty(cert.id_partida_presupuesto)){
                    lstwotId.add(cert.sku);
                }
            }  
        }
        if(!lstwotId.isEmpty()){
            lstwotId.clear();
        }
        
*/
    
    
    
}