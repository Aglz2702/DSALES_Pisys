import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCategoria from '@salesforce/apex/DSALES_ClasificacionServicio.getPickListCategoria';
import SendCat from '@salesforce/apex/DSALES_ClasificacionServicio.getPicklistOptionsDependent';
import getRecords from '@salesforce/apex/DSALES_ClasificacionServicio.getRecords';
import upsertRecord from '@salesforce/apex/DSALES_ClasificacionServicio.upsertRecord';
import getSku from '@salesforce/apex/DSALES_ClasificacionServicio.getBuscarSKU';
import getProfileType from '@salesforce/apex/DSALES_ClasificacionServicio.checkProfileType';
import getCategories from '@salesforce/apex/DSALES_ClasificacionServicio.getcategories';
import getSubCategories from '@salesforce/apex/DSALES_ClasificacionServicio.getSubCategories';
import getClases from '@salesforce/apex/DSALES_ClasificacionServicio.getClases';
import getFamilias from '@salesforce/apex/DSALES_ClasificacionServicio.getFamilias';
import getPickListTipoProducto from '@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList1';
import getPickListTipoServicio from '@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList2';
import getPickListTipoSeguro from '@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList4';
import getPickListMatriz from '@salesforce/apex/DSALES_ClasificacionServicio.getPickListValuesIntoList3';
import getMatrices from '@salesforce/apex/DSALES_ClasificacionServicio.getMatriz';
import getBuscarVinculacion from '@salesforce/apex/DSALES_ClasificacionServicio.getBuscarVinculacion';
//Crear Producto intangible
import createProductIntan from '@salesforce/apex/DSALES_ClasificacionServicio.createProductIntan';
import upsertVinculacion from '@salesforce/apex/DSALES_ClasificacionServicio.upsertVinculacion';
import getBuscarProducto from '@salesforce/apex/DSALES_ClasificacionServicio.getBuscarProducto';
import createVinculacion from '@salesforce/apex/DSALES_ClasificacionServicio.createVinculacion';
import getidservicio from '@salesforce/apex/DSALES_ClasificacionServicio.getidservicio';
import insertVinculacion from '@salesforce/apex/DSALES_ClasificacionServicio.insertVinculacion';
import updateMatriz from '@salesforce/apex/DSALES_ClasificacionServicio.updateMatriz';
import insertListaPrecios from '@salesforce/apex/DSALES_ClasificacionServicio.insertListaPrecios';
import insertPocentajeCobro from '@salesforce/apex/DSALES_ClasificacionServicio.insertPocentajeCobro';
import RecordTypeId from '@salesforce/apex/DSALES_ClasificacionServicio.RecordTypeId';
import getCampaings from '@salesforce/apex/DSALES_ClasificacionServicio.getCampaings';
import updateCampaigns from '@salesforce/apex/DSALES_ClasificacionServicio.updateCampaigns';
import getTipoUso from '@salesforce/apex/DSALES_ClasificacionServicio.getTipoUso';
import updateTipoUso from '@salesforce/apex/DSALES_ClasificacionServicio.updateTipoUso';
import getTiposUsoUsed from '@salesforce/apex/DSALES_ClasificacionServicio.getTiposUsoUsed';
import getCampanasUsed from '@salesforce/apex/DSALES_ClasificacionServicio.getCampanasUsed';
import getserviciocategorias from '@salesforce/apex/DSALES_ClasificacionServicio.getserviciocategorias';
import getserviciosubcategorias from '@salesforce/apex/DSALES_ClasificacionServicio.getserviciosubcategorias';
import getservicioclase from '@salesforce/apex/DSALES_ClasificacionServicio.getservicioclase';
import getserviciofamilia from '@salesforce/apex/DSALES_ClasificacionServicio.getserviciofamilia';
import getserviciosku from '@salesforce/apex/DSALES_ClasificacionServicio.getserviciosku';
//import updateTipoUsoMasivo from '@salesforce/apex/DSALES_ClasificacionServicio.updateTipoUsoMasivo';



const columns = [
    { label: 'Nombre', fieldName: 'etiqueta' }

];

export default class DSALES_ClasificacionServiciolwc extends LightningElement {
    @track data = {};
    @track pickList = {};
    @track asignacion = {};
    @track label = {};
    @track matrizPorcentaje = {};
    columns = columns;
    checkCategoria = false;
    checkSubCategoria = false;
    checkSku = false;
    checkSkus = false;
    checkClase = false;
    checkFamilia = false;
    showSpinner = true;
    popServicios = false;
    show = false;
    show2 = false;
    showc = false;
    showbyfilter=false;
    showVincuProduct = false;
    showCrearIntangible = false;
    showasignarSubCategorias = false;
    showasignarClases = false;
    showasignarFamilias = false;
    buscarCategoria = '';
    buscarSCat = '';
    buscarClase = '';
    buscarFami = '';
    buscarSkuString = '';
    buscarServicio = '';
    showPorcentajeCobro = false;
    openTablaResultado = false;
    openTableVincProduct = false;
    showConfirmarDesvincular = false
    showConfirmarVincular = false;
    //
    ValueCategoriaSelected = '';
    ValueSubCategoriaSelected = '';
    resultPerfil = false;
    campanasSelected = [];
    tiposUsoSelected = [];

    connectedCallback() {
        this.init();
        this.ProfileChecker();
    }

    init() {
        getCategoria()
            .then(result => {
                this.data = result;
                this.showSpinner = false;
                this.showc = true;
            })
            .catch(error => {
                this.showSpinner = false;
            });
        this.show = false;
        this.show2 = false;
        this.show3 = false;
        this.checkCategoria = false;
        this.checkSubCategoria = false;
        this.checkClase = false;
        this.checkFamilia = false;
    }

    changeSku(event) {
        this.buscarSkuString = event.target.value;
    }

    buscarSku() {
        this.showbyfilter=true;
        this.showSpinner = true;
        getSku({ sku: this.buscarSkuString })
            .then(result => {
                this.ProfileChecker();
                this.data.listServicios = result;
                this.showSpinner = false;
                if (this.data.listServicios.length > 0) {
                    this.popServicios = true;
                    this.recordServicio();
                } else {
                    this.pushMessage('Advertencia', 'warning', 'No se han encontrado productos.');
                }
            }).catch(error => {
                this.showSpinner = false;
            });
    }

    buscadorC(event) {
        this.buscarCategoria = event.target.value;
        this.buscarCategoria = this.quitaAcento(this.buscarCategoria);
        if (this.buscarCategoria.length > 2) {
            for (let i = 0; i < this.data.listCategorias.length; i++) {
                let etiqueta = this.quitaAcento(this.data.listCategorias[i].etiqueta);
                this.data.listCategorias[i].mostrar = etiqueta.includes(this.buscarCategoria);
            }
        } else {
            for (let i = 0; i < this.data.listCategorias.length; i++) {
                this.data.listCategorias[i].mostrar = true;
            }
        }
    }

    buscadorSubC(event) {
        this.buscarSCat = event.target.value;
        this.buscarSCat = this.quitaAcento(this.buscarSCat);
        if (this.buscarSCat.length > 2) {
            for (let i = 0; i < this.data.listSubCategorias.length; i++) {
                let etiqueta = this.quitaAcento(this.data.listSubCategorias[i].etiqueta);
                this.data.listSubCategorias[i].mostrar = etiqueta.includes(this.buscarSCat);
            }
        } else {
            for (let i = 0; i < this.data.listSubCategorias.length; i++) {
                this.data.listSubCategorias[i].mostrar = true;
            }
        }
    }

    buscadorCla(event) {
        this.buscarClase = event.target.value;
        this.buscarClase = this.quitaAcento(this.buscarClase);
        if (this.buscarClase.length > 2) {
            for (let i = 0; i < this.data.listClases.length; i++) {
                let etiqueta = this.quitaAcento(this.data.listClases[i].etiqueta);
                this.data.listClases[i].mostrar = etiqueta.includes(this.buscarClase);
            }
        } else {
            for (let i = 0; i < this.data.listClases.length; i++) {
                this.data.listClases[i].mostrar = true;
            }
        }
    }

    buscadorFami(event) {
        this.buscarFami = event.target.value;
        this.buscarFami = this.quitaAcento(this.buscarFami);
        if (this.buscarFami.length > 2) {
            for (let i = 0; i < this.data.listFamilias.length; i++) {
                let etiqueta = this.quitaAcento(this.data.listFamilias[i].etiqueta);
                this.data.listFamilias[i].mostrar = etiqueta.includes(this.buscarFami);
            }
        } else {
            for (let i = 0; i < this.data.listFamilias.length; i++) {
                this.data.listFamilias[i].mostrar = true;
            }
        }
    }

    quitaAcento(cadena) {
        cadena = cadena.toUpperCase();
        cadena = cadena.replace('Á', 'A');
        cadena = cadena.replace('É', 'E');
        cadena = cadena.replace('Í', 'I');
        cadena = cadena.replace('Ó', 'O');
        cadena = cadena.replace('Ú', 'U');
        return cadena;
    }
    mostrarSubcategoria() {
        this.show = true;
        this.cargarPickList();
    }

    mostrarClase() {
        this.show2 = true;
        this.cargarPickList();
    }

    mostrarFamilia() {
        this.show3 = true;
        this.cargarPickList();
    }

    cargarPickList() {
        this.showSpinner = true;
        SendCat({ allData: JSON.stringify(this.data) })
            .then(result => {
                this.data = result;
                this.showSpinner = false;
            }).catch(error => {
                this.showSpinner = false;
            });
    }

    onclickCategoria(event) {
        let x = false;
        const valor = event.target.name;
        const check = event.target.checked;
        for (let i = 0; i < this.data.listCategorias.length; i++) {
            if (valor == this.data.listCategorias[i].valor) {
                this.data.listCategorias[i].seleccionado = check;
            }
            if (this.data.listCategorias[i].seleccionado) {
                x = true;
                this.checkCategoria = true;
            }
        }
        if (x == false) {
            this.checkCategoria = false;
        }
        this.mostrarSubcategoria();
    }

    onclickSubCategoria(event) {
        let x = false;
        const valor = event.target.name;
        const check = event.target.checked;
        for (let i = 0; i < this.data.listSubCategorias.length; i++) {
            if (valor == this.data.listSubCategorias[i].valor) {
                this.data.listSubCategorias[i].seleccionado = check;
            }
            if (this.data.listSubCategorias[i].seleccionado) {
                x = true;
                this.checkSubCategoria = true;
            }
        }
        if (x == false) {
            this.checkSubCategoria = false;
        }
        this.mostrarClase();
    }

    onclickListFamilias(event) {
        let x = false;
        const valor = event.target.name;
        const check = event.target.checked;
        for (let i = 0; i < this.data.listFamilias.length; i++) {
            if (valor == this.data.listFamilias[i].valor) {
                this.data.listFamilias[i].seleccionado = check;
            }
            if (this.data.listFamilias[i].seleccionado) {
                x = true;
                this.checkFamilia = true;
            }
        }
        if (x == false) {
            this.checkFamilia = false;
        }
    }

    onclicklistClases(event) {
        let x = false;
        const valor = event.target.name;
        const check = event.target.checked;
        for (let i = 0; i < this.data.listClases.length; i++) {
            if (valor == this.data.listClases[i].valor) {
                this.data.listClases[i].seleccionado = check;
            }
            if (this.data.listClases[i].seleccionado) {
                x = true;
                this.checkClase = true;
            }
        }
        if (x == false) {
            this.checkClase = false;
        }
        this.mostrarFamilia();
    }

    selectAllCategoria(event) {
        const check = event.target.checked;
        for (let i = 0; i < this.data.listCategorias.length; i++) {
            this.data.listCategorias[i].seleccionado = check;
        }
        this.checkCategoria = check;
        this.mostrarSubcategoria();
    }

    selectAllSubCategoria(event) {
        const check = event.target.checked;
        for (let i = 0; i < this.data.listSubCategorias.length; i++) {
            this.data.listSubCategorias[i].seleccionado = check;
        }
        this.checkSubCategoria = check;
        this.mostrarClase();
    }

    selectAllFamilia(event) {
        const check = event.target.checked;
        for (let i = 0; i < this.data.listFamilias.length; i++) {
            this.data.listFamilias[i].seleccionado = check;
        }
        this.checkFamilia = check;
    }

    selectAllClase(event) {
        const check = event.target.checked;
        for (let i = 0; i < this.data.listClases.length; i++) {
            this.data.listClases[i].seleccionado = check;
        }
        this.checkClase = check;
        this.mostrarFamilia();
    }

    search() {
        
        if(this.buscarSkuString=='')
        {
            this.showSpinner = true;
            this.getNameRecordTypeId();
            getRecords({ allData: JSON.stringify(this.data), perfilUsuario: this.data.nameRecordType, opcion: 'RecordType' })
                .then(result => {
                    this.ProfileChecker();
                    this.showSpinner = false;
                    this.data = result;
                    this.data.registroSeguro = false;
                    this.data.registroServicio = false;
                    if (this.data.listServicios.length > 0) {
                        this.popServicios = true;
                        this.recordServicio();
                    } else {
                        this.pushMessage('Advertencia', 'warning', 'No se han encontrado productos.');
                    }
                    this.showbyfilter=true;
                    this.showSpinner = false;
                })
                .catch(error => {
                    this.showSpinner = false;
                    this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte su administrador.');
                });
        }
        else{
            this.buscarSku();
        }
       
    }

    searchAllRecords() {
        this.showSpinner = true;
        this.getNameRecordTypeId();
        getRecords({ allData: JSON.stringify(this.data), perfilUsuario: this.data.nameRecordType, opcion: 'AllRecords' })
            .then(result => {
                this.ProfileChecker();
                this.showSpinner = false;
                this.data= result;
                this.data.registroSeguro = false;
                this.data.registroServicio = false;
                if (this.data.listServicios.length > 0) {
                    this.popServicios = true;
                    //this.recordServicio();
                } else {
                    this.pushMessage('Advertencia', 'warning', 'No se han encontrado productos.');
                }
                this.showbyfilter=true;
                this.showCrearIntangible=false;
                this.showc=false;
                this.showVincuProduct=false;
            })
            .catch(error => {
                this.showSpinner = false;
                this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte su administrador.');
            });
    }

    guardar() {
        this.showSpinner = true;
        this.popServicios = false;
        upsertRecord({ allData: JSON.stringify(this.data.listServicios) })
            .then(result => {
                if(result[1]=='200'){
                    this.cancelar();
                    if(result[0]=='sin errores'){
                        this.pushMessage('Exitoso', 'success', 'Datos guardados exitosamente.');
                    }
                    else{
                        this.pushMessage('Advertencia', 'Warning', 'Operacion exitosa con los siguientes errores: '+result[0]);
                    }
                    insertListaPrecios({ idproductoservicio: 'opcion2', opcion: '2', JSON2: JSON.stringify(this.data.listServicios) })
                        .then(result => {
                        }).catch(error => {
                        });
                }
                else if (result[1]=='400'){
                    this.pushMessage('Advertencia', 'warning', 'Error: '+result+' Recurso no encontrado');
                    this.showSpinner = false;
                }
                else if (result[1]=='404'){
                    this.pushMessage('Advertencia', 'warning', 'Error: '+result+'No se encontró el recurso solicitado');
                    this.showSpinner = false;
                }
                else if (result[1]=='416'){
                    this.pushMessage('Advertencia', 'warning','Error: '+result+ 'Rango no satisfactorio');
                    this.showSpinner = false;
                }
                else if (result[1]=='422'){
                    this.pushMessage('Advertencia', 'warning','Error: '+result+ 'Entidad no procesable');
                    this.showSpinner = false;
                }
                else if (result[1]=='429'){
                    this.pushMessage('Advertencia', 'warning', 'Error: '+result+'Demasiadas peticiones');
                    this.showSpinner = false;
                }
                else if (result[1]=='500'){
                    this.pushMessage('Advertencia', 'warning', 'Error: '+result+ 'Problemas en la comunicación');
                    this.showSpinner = false;
                }
                this.showSpinner = false;
            }).catch(error => {
                this.showSpinner = false;
                this.pushMessage('Error', 'error', 'Ha ocurrido un error al actualizar los registros.');
            });
    }

    cancelar() {
        this.popServicios = false;
        this.showSpinner = false;
        this.showVincuProduct = false;
        this.openTablaResultado = false;
        this.ValueCategoriaSelected = '';
        this.pickList.ValueClasesSelected = '';
        this.pickList.ValuefamiliasSelected = '';
        this.pickList.aplicaCobro = false;
        this.pickList.porcentajeCobro = 0;
        this.pickList.valueSelectedMatriz = '';
        this.pickList.Description = '';
        this.pickList.Name = '';
        this.pickList.StockKeepingUnit = '';
        this.pickList.valueSelectedtipoSeguroServicio = '';
        this.pickList.matrizSelected == '';
        this.data.listasignacion = '';
        this.data.showcompras=false;
    }

    limpiarCampos() {
        this.ValueCategoriaSelected = '';
        this.pickList.ValueClasesSelected = '';
        this.pickList.ValuefamiliasSelected = '';
        this.pickList.aplicaCobro = false;
        this.pickList.porcentajeCobro = 0;
        this.pickList.valueSelectedMatriz = '';
        this.pickList.Description = '';
        this.pickList.Name = '';
        this.pickList.StockKeepingUnit = '';
        this.pickList.valueSelectedtipoSeguroServicio = '';
        this.pickList.matrizSelected = '';
        this.pickList.DSales_Aplicaporcentajecobro__c = false;
        this.showPorcentajeCobro = false;
        this.checkSku = false;
        this.checkSkus = false;
        this.pickList.listMatrices = '';
        this.pickList.DSales_PorcentajeCobro__c = 0;
        this.pickList.IsActive = false;
        this.pickList.subCategoriaSelected = '';
        this.matrizPorcentaje.anio1 = 0;
        this.matrizPorcentaje.anio2 = 0;
        this.matrizPorcentaje.anio3 = 0;
        this.matrizPorcentaje.anio4 = 0;
        this.matrizPorcentaje.anio5 = 0;
        this.matrizPorcentaje.anio6 = 0;
    }

    onchangeSeguro(event) {
        const name = event.target.name;
        const check = event.target.checked;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            if (this.data.listServicios[i].id == name) {
                this.data.listServicios[i].seguro = check;
                this.data.listServicios[i].noAplica = false;
                this.data.listServicios[i].noAplicaSeguro = false;
                this.asignarTipoServicio(i);
            }
        }
    }
    onchangeNoAplica(event) {
        const name = event.target.name;
        const check = event.target.checked;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            if (this.data.listServicios[i].id == name) {
                this.data.listServicios[i].noAplica = check;
                this.data.listServicios[i].noAplicaSeguro=check;
                this.data.listServicios[i].noAplicaServicio=check;
                this.data.listServicios[i].servicio = false;
                this.data.listServicios[i].seguro = false;
            }
        }
    }
    onchangeNoAplicaServicio(event) {
        const name = event.target.name;
        const check = event.target.checked;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            if (this.data.listServicios[i].id == name) {
                this.data.listServicios[i].noAplicaServicio = check;
                this.data.listServicios[i].servicio = false;
                this.data.listServicios[i].seguro = false;
            }
        }
    }
    onchangeNoAplicaSeguro(event) {
        const name = event.target.name;
        const check = event.target.checked;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            if (this.data.listServicios[i].id == name) {
                this.data.listServicios[i].noAplicaSeguro = check;
                this.data.listServicios[i].servicio = false;
                this.data.listServicios[i].seguro = false;
            }
        }
    }
    onchangeAllSeguro(event) {
        this.data.registroSeguro = event.target.checked;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            this.data.listServicios[i].seguro = this.data.registroSeguro;
            this.data.listServicios[i].servicio = false;
            this.data.listServicios[i].noAplica = false;
            this.asignarTipoServicio(i);
        }
        this.recordServicio();
    }

    onchangeAllNoAplica(event) {
        this.data.noAplica = event.target.checked;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            this.data.listServicios[i].noAplica = this.data.noAplica;
            this.data.listServicios[i].seguro = false;
            this.data.listServicios[i].servicio = false;
        }
        this.recordServicio();
    }

    onchangeAllNoAplicaServicio(event) {
        this.data.noAplica = event.target.checked;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            this.data.listServicios[i].noAplicaServicio = this.data.noAplica;
            this.data.listServicios[i].seguro = false;
            this.data.listServicios[i].servicio = false;
        }
        this.recordServicio();
    }

    onchangeAllNoAplicaSeguro(event) {
        this.data.noAplica = event.target.checked;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            this.data.listServicios[i].noAplicaSeguro = this.data.noAplica;
            this.data.listServicios[i].seguro = false;
            this.data.listServicios[i].servicio = false;
        }
        this.recordServicio();
    }
    onchangeAllTiposuso(event) {
        this.data.registroTiposUso = event.target.checked;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            this.data.listServicios[i].tipoUso = this.data.registroTiposUso;
        }
    }

    onchangeAllCampanas(event) {
        this.data.registroCampanas = event.target.checked;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            this.data.listServicios[i].campanas = this.data.registroCampanas;
        }
    }

    onchangeServicio(event) {
        const name = event.target.name;
        const check = event.target.checked;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            if (this.data.listServicios[i].id == name) {
                this.data.listServicios[i].servicio = check;
                this.data.listServicios[i].noAplica = false;
                this.data.listServicios[i].noAplicaServicio = false;
                this.asignarTipoServicio(i);
            }
        }
    }

    onchangeAllServicio(event) {
        this.data.registroServicio = event.target.checked;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            this.data.listServicios[i].servicio = this.data.registroServicio;
            this.data.listServicios[i].noAplica = false;
            this.data.listServicios[i].seguro = false;
            this.asignarTipoServicio(i);
        }
        this.recordServicio();
    }

    asignarTipoServicio(index) {
        if (this.data.listServicios[index].servicio && this.data.listServicios[index].seguro) {
            this.data.listServicios[index].tipoServicio = "3";
        } else if (this.data.listServicios[index].servicio) {
            this.data.listServicios[index].tipoServicio = "2";
        } else if (this.data.listServicios[index].seguro) {
            this.data.listServicios[index].tipoServicio = "1";
        } else {
            this.data.listServicios[index].tipoServicio = "0";
        }
    }

    recordServicio() {
        this.data.registroSeguro = false;
        this.data.registroServicio = false;
        this.data.noAplica = false;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            if (this.data.listServicios[i].seguro) {
                this.data.registroSeguro = true;
            }
            if (this.data.listServicios[i].servicio) {
                this.data.registroServicio = true;
            }
            if (this.data.listServicios[i].noAplica) {
                this.data.noAplica = true;
            }
        }
    }
    pushMessage(title, variant, msj) {
        const message = new ShowToastEvent({
            "title": title,
            "variant": variant,
            "message": msj
        });
        this.dispatchEvent(message);
    }

    openVincuProduct() {
        this.showVincuProduct = true;
        this.showc=false;
        this.showbyfilter=false;
        this.showCrearIntangible=false;
    }

    openFormIntangible(event) {
        this.showc=false;
        this.showbyfilter=false;
        this.showVincuProduct=false;
        this.limpiarCampos();
        this.showCrearIntangible = true;
        this.buscarServicio = '';
        this.SelectSeguroServicio();
        this.getPickList1();
    }

    getPickList1() {
        getPickListTipoProducto()
            .then(result => {
                this.pickList.tipoProducto = result;
            });
    }

    getPickList2(event) {
        this.label.labelTipoServicio = 'Tipo de servicio';
        this.label.labelSku = 'SKU del servicio';
        this.label.labelDescripcion = 'Descripción';
        this.label.labelName = 'Nombre del servicio';
        getPickListTipoServicio()
            .then(result => {
                this.pickList.tipoSeguroServicio = result;
            });
    }

    getPickList3() {
        getPickListMatriz()
            .then(result => {
                this.pickList.Matriz = result;
            });
    }

    getPickList4() {
        this.label.labelTipoServicio = 'Tipo de seguro';
        this.label.labelSku = 'SKU del seguro';
        this.label.labelDescripcion = 'Descripción';
        this.label.labelName = 'Nombre del seguro';
        getPickListTipoSeguro()
            .then(result => {
                this.pickList.tipoSeguroServicio = result;
            });
    }

    SelectSeguroServicio() {
        this.ProfileChecker();

    }

    SelectSeguroServicioAdmi(event) {
        this.pickList.valueSelectedtipoProducto = event.target.value;
        this.pickList.DSales_Tipo_de_Producto__c = event.target.value;
        if (event.target.value == 'Servicio') {
            this.data.showServicio = true;
            this.getPickList2();
        }
        else if (event.target.value == 'Seguro') {
            this.data.showServicio = false;
            this.getPickList4();
        }
    }
    asignarCategoria(event) {
        this.showSpinner = true;
        this.pickList.valueSelectedtipoSeguroServicio = event.target.value;
        RecordTypeId({ tipoRegistro: this.pickList.valueSelectedtipoSeguroServicio })
            .then(result => {
                this.pickList.RecordTypeId = result;
                if (this.pickList.valueSelectedtipoSeguroServicio == 'Garantía Extendida') {
                    this.pickList.DSALES_ServEspecifico__c = event.target.value;
                }
                else if (this.pickList.valueSelectedtipoSeguroServicio == 'Seguro de Motos') {
                    this.pickList.DSALES_SegEspecifico__c = event.target.value;
                }
            });

        getCategories({ recordName: this.pickList.valueSelectedtipoSeguroServicio })
            .then(result => {
                this.pickList.listCategorias = result;
                this.showSpinner = false;
            });
    }
    asignarSubCategorias(event) {
        this.ValueCategoriaSelected = event.target.value;
        this.pickList.DSALES_Categoria__c = event.target.value;
        this.showasignarSubCategorias = true;
        getSubCategories({ valueCategoria: this.ValueCategoriaSelected })
            .then(result => {
                this.pickList.listSubCategorias = result;
            });
    }

    asignarClase(event) {
        this.pickList.subCategoriaSelected = event.target.value;
        this.pickList.DSALES_SubCategoria__c = event.target.value;
        this.showasignarClases = true;
        this.pickList.IsActive = true;
        getClases({ valueCategoria: this.pickList.subCategoriaSelected })
            .then(result => {
                this.pickList.listClases = result;
            });
    }

    asignarFamilas(event) {
        this.pickList.ValueClasesSelected = event.target.value;
        this.pickList.DSALES_Clase__c = event.target.value;
        this.showasignarFamilias = true;
        getFamilias({ valueClases: this.pickList.ValueClasesSelected })
            .then(result => {
                this.pickList.listFamilias = result;
            });
    }

    asignarMatriz(event) {
        this.showSpinner = true;
        this.pickList.Valuefamilias = event.target.value;
        this.pickList.DSALES_Familia__c = event.target.value;
        getMatrices()
            .then(result => {
                this.pickList.listMatrices = result;
                this.showSpinner = false;
            });
    }

    ProfileChecker(event) {
        this.resultPerfil = false;
        this.data.showAdmiSM = false;
        this.data.showAdmiGex = false;
        getProfileType({ profile: 'Administrador SM' })
            .then(result => {
                this.data.confirmarProfileType = result;
                if (this.data.confirmarProfileType == 'Administrador SM') {
                    this.resultPerfil = false;
                    this.data.showAdmiSM = true;
                    this.data.showAdmiGex = false;
                    this.data.showServicio = false;
                    this.pickList.valueSelectedtipoProducto = 'Seguro';
                    this.pickList.DSales_Tipo_de_Producto__c = 'Seguro';
                    this.getPickList4();
                }
                else if (this.data.confirmarProfileType == 'No corresponde') {
                    this.resultPerfil = false;
                    this.data.showAdmiSM = false;
                    this.data.showAdmiGex = true;
                    this.data.showServicio = true;
                    this.pickList.valueSelectedtipoProducto = 'Servicio';
                    this.pickList.DSales_Tipo_de_Producto__c = 'Servicio';
                    this.getPickList2();
                }
                else if (this.data.confirmarProfileType == 'Administrador del sistema') {
                    this.resultPerfil = true;
                    this.data.showAdmiSM = false;
                    this.data.showAdmiGex = false;
                    this.data.showServicio = true;
                    this.pickList.valueSelectedtipoProducto = 'Servicio';
                    this.pickList.DSales_Tipo_de_Producto__c = 'Servicio';
                    this.getPickList2();
                }
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    buscarAsignacionVinculacion(event) {
        this.data.asignacion = event.target.value;
    }

    handleInputChangeSku(event) {
        this.pickList.StockKeepingUnit = event.detail.value;
    }

    handleInputChangeNameSS(event) {
        this.pickList.Name = event.detail.value;
    }

    handleInputChangeDescription(event) {
        this.pickList.Description = event.detail.value;
    }

    openPorcentajeCobro(event) {
        this.pickList.matrizSelected = '';
        this.pickList.DSales_PorcentajeCobro__c = 0;
        this.data.aniosporcentaje = 0;
        this.data.dos = 0;
        this.data.tres = 0;
        this.data.cuatro = 0;
        this.data.cinco = 0;
        this.data.seis = 0;
        const checkpc = event.target.checked;
        if (checkpc) {
            this.showPorcentajeCobro = true;
            this.pickList.DSales_Aplicaporcentajecobro__c = true;

        }
        else {
            this.showPorcentajeCobro = false;
            this.pickList.DSales_Aplicaporcentajecobro__c = false;
        }
        this.pickList.aplicaCobro = checkpc;

    }

    onChangePorcentajeCobro(event) {
        this.data.DSALES_Anios__c = 1;
        this.matrizPorcentaje.anio1 = event.target.value;
    }

    onChangePorcentajeCobro2(event) {
        this.data.DSALES_Anios__c = 2;
        this.matrizPorcentaje.anio2 = event.target.value;
    }

    onChangePorcentajeCobro3(event) {
        this.data.DSALES_Anios__c = 3;
        this.matrizPorcentaje.anio3 = event.target.value;
    }

    onChangePorcentajeCobro4(event) {
        this.data.DSALES_Anios__c = 4;
        this.matrizPorcentaje.anio4 = event.target.value;
    }

    onChangePorcentajeCobro5(event) {
        this.data.DSALES_Anios__c = 5;
        this.matrizPorcentaje.anio5 = event.target.value;
    }

    onChangePorcentajeCobro6(event) {
        this.data.DSALES_Anios__c = 6;
        this.matrizPorcentaje.anio6 = event.target.value;
    }

    onchangeValueMatriz(event) {
        this.pickList.matrizSelected = event.detail.value;
    }
    onchangeCampana(event) {
        this.data.campanasSelected = event.detail.value;
    }

    onchangeTiposuso(event) {
        this.data.tiposUsoSelected = event.detail.value;
    }

    onchangeTypesChecked(event) {
        const name = event.target.name;
        const check = event.target.checked;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            if (this.data.listServicios[i].id == name) {
                this.data.listServicios[i].tipoUso = check;
            }
        }
    }

    onchangeCampaignsChecked(event) {
        const name = event.target.name;
        const check = event.target.checked;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            if (this.data.listServicios[i].id == name) {
                this.data.listServicios[i].campanas = check;
            }
        }
    }

    camposVacios() {
        if (this.data.aniosporcentaje == 0 && this.matrizPorcentaje.anio1 != 0) {
            this.data.camposCompletos = true;
        }
        else if (this.data.aniosporcentaje == 1 && this.matrizPorcentaje.anio1 != 0 && this.matrizPorcentaje.anio2 != 0) {
            this.data.camposCompletos = true;
        }
        else if (this.data.aniosporcentaje == 2 && this.matrizPorcentaje.anio1 != 0 && this.matrizPorcentaje.anio2 != 0 && this.matrizPorcentaje.anio3 != 0) {
            this.data.camposCompletos = true;
        }
        else if (this.data.aniosporcentaje == 3 && this.matrizPorcentaje.anio1 != 0 && this.matrizPorcentaje.anio2 != 0 && this.matrizPorcentaje.anio3 != 0 &&
            this.matrizPorcentaje.anio4 != 0) {
            this.data.camposCompletos = true;
        }
        else if (this.data.aniosporcentaje == 4 && this.matrizPorcentaje.anio1 != 0 && this.matrizPorcentaje.anio2 != 0 && this.matrizPorcentaje.anio3 != 0 &&
            this.matrizPorcentaje.anio4 != 0 && this.matrizPorcentaje.anio5 != 0) {
            this.data.camposCompletos = true;
        }
        else if (this.data.aniosporcentaje == 5 && this.matrizPorcentaje.anio1 != 0 && this.matrizPorcentaje.anio2 != 0 && this.matrizPorcentaje.anio3 != 0 &&
            this.matrizPorcentaje.anio4 != 0 && this.matrizPorcentaje.anio5 != 0 && this.matrizPorcentaje.anio6 != 0) {
            this.data.camposCompletos = true;
        }
        else this.data.camposCompletos = false;
    }


    confirmarGuardar() {
        if (this.pickList.valueSelectedtipoProducto == 'Servicio') {
            this.camposVacios();
            this.data.confirmarGuardar = false;
            if (this.showPorcentajeCobro === true) {
                if (this.ValueCategoriaSelected == '' ||
                    this.pickList.ValueClasesSelected == '' ||
                    this.pickList.Description == '' ||
                    this.pickList.Name == '' ||
                    this.pickList.StockKeepingUnit == '' ||
                    this.data.camposCompletos == false
                ) {
                    this.pushMessage('Advertencia', 'warning', 'Existen campos vacios o no seleccionados');
                }
                else {
                    this.guardarProductIntan();

                }

            } else {
                if (this.ValueCategoriaSelected == '' ||
                    this.pickList.ValueClasesSelected == '' ||
                    // this.pickList.ValuefamiliasSelected=='' ||
                    this.pickList.Description == '' ||
                    this.pickList.Name == '' ||
                    this.pickList.StockKeepingUnit == '' ||
                    this.pickList.matrizSelected == ''

                ) {
                    this.pushMessage('Advertencia', 'warning', 'Existen campos vacios o no seleccionados');
                }
                else {
                    this.guardarProductIntan();

                }
            }


        } else {

            this.data.confirmarGuardar = false;

            if (this.ValueCategoriaSelected == '' ||
                this.pickList.ValueClasesSelected == '' ||
                // this.pickList.ValuefamiliasSelected=='' ||
                this.pickList.Description == '' ||
                this.pickList.Name == '' ||
                this.pickList.StockKeepingUnit == ''


            ) {
                this.pushMessage('Advertencia', 'warning', 'Existen campos vacios o no seleccionados');

            }
            else {
                this.guardarProductIntan();

            }

        }


    }

    guardarProductIntan() {
        createProductIntan({ productIntan: this.pickList, sku: this.pickList.StockKeepingUnit }
        ).then(result => {
            this.message = result.message;
            this.error = undefined;
            if (this.message !== undefined) {
                this.pushMessage('Error al crear Servicio', 'Warning', 'Error al crear registro')
            }
            this.pushMessage('Guardado', 'success', 'Producto guardado exitosamente.')
            this.showCrearIntangible = false;


            if (this.pickList.valueSelectedtipoProducto == 'Servicio') {
                this.data.confirmarGuardar = true;
                getidservicio({ sku: this.pickList.StockKeepingUnit })
                    .then(result => {
                        this.data.idservicio = result;
                        this.showSpinner = false;
                        if (this.showPorcentajeCobro == false) {
                            updateMatriz({ allData: JSON.stringify(this.pickList.matrizSelected), typeServicio: result })
                                .then(result => {
                                }).catch(error => {
                                    this.showSpinner = false;
                                });
                        }
                        else {
                            insertPocentajeCobro({ idservicio: result, JSONP: JSON.stringify(this.matrizPorcentaje) })
                                .then(result => {
                                }).catch(error => {
                                    this.showSpinner = false;
                                });
                        }
                    }).catch(error => {
                        this.showSpinner = false;
                    });

                getidservicio({ sku: this.pickList.StockKeepingUnit })
                    .then(result => {
                        this.data.idservicio = result;
                        this.showSpinner = false;
                        insertListaPrecios({ idproductoservicio: result, opcion: '1', JSON2: JSON.stringify(this.data.listServicios) })
                            .then(result => {
                            }).catch(error => {
                            });

                    }).catch(error => {
                        this.showSpinner = false;
                    });
            }

        })
            .catch(error => {
                this.message = undefined;
                this.error = error;
                this.pushMessage('Error al guardar, SKU ya existente', 'Warning', 'Error al crear registro')
            });



    }

    guardarAsignacion() {

        insertVinculacion({ dataJSON: JSON.stringify(this.data.listaproductos), idservicio: this.data.idservicio })
            .then(result => {
                this.pushMessage('Exitoso', 'success', 'Datos guardados exitosamente.');
                this.onClickBuscarIntanProduct();
            }).catch(error => {
                this.showSpinner = false;
                this.pushMessage('Error', 'error', 'Ha ocurrido un error al actualizar los registros.');
            });
        this.showConfirmarVincular = false;
        this.openTableVincProduct = false;
    }
    onClickBuscarIntanProduct() {
        this.limpiarCampos();
        this.showSpinner = true;
        if (this.buscarServicio === '') {
            this.buscarServicio = this.data.idservicio;
        }
        this.data.idservicio = this.buscarServicio;
        getBuscarVinculacion({ servicio: this.buscarServicio })
            .then(result => {
                this.data.listasignacion = result;
                this.error = undefined;
                this.showSpinner = false;
                if (this.data.listasignacion.length > 0) {
                    this.openTablaResultado = true;
                } else if (this.data.listasignacion.length < 1) {
                    this.pushMessage('Advertencia', 'warning', 'No se han encontrado Asignaciones, Crea una.');
                    this.openTablaResultado = true;
                }
            }).catch(error => {
                this.pushMessage('Advertencia', 'warning', 'Este Servicio no existe.');
                this.showSpinner = false;
                this.openTablaResultado = false;
            });

    }

    getidserviciostring() {
        getidservicio({ sku: this.buscarServicio })
            .then(result => {
                this.data.idservicio = result;
                this.showSpinner = false;
            }).catch(error => {
                this.showSpinner = false;
            });
    }
    onChangeInputBuscarServicio(event) {
        this.buscarServicio = event.target.value;
    }

    cancelar2() {
        this.openTablaResultado = false;

    }

    selectAllSku(event) {
        const check = event.target.checked;
        for (let i = 0; i < this.data.listasignacion.length; i++) {
            this.data.listasignacion[i].seleccionadoSubcategoria = check;
            this.data.listasignacion[i].seleccionadoSku = check;
            this.data.listasignacion[i].seleccionadoDept = check;
            this.data.listasignacion[i].seleccionadoClase = check;
            this.data.listasignacion[i].seleccionadoFamilia = check;
        }
        this.checkSku = check;
    }

    updateVinculacion() {
        upsertVinculacion({ dataJSON: JSON.stringify(this.data.listasignacion) })
            .then(result => {
                this.pushMessage('Exitoso', 'success', 'Datos guardados exitosamente.');
                this.onClickBuscarIntanProduct();
            }).catch(error => {
                this.showSpinner = false;
                this.pushMessage('Error', 'error', 'Ha ocurrido un error al actualizar los registros.');
            });


        this.showConfirmarDesvincular = false;
    }

    selectAllSkuSelected(event) {
        this.data.checkDepartamento = false;
        const check1 = event.target.checked;
        const checkDept = event.target.label;
        for (let i = 0; i < this.data.listasignacion.length; i++) {
            if (this.data.listasignacion[i].sku === checkDept) {
                this.data.listasignacion[i].seleccionadoSku = check1;
            }

        }
        this.checkDepartamento = check1;
    }

    selectAllDepartamentos(event) {
        this.data.checkDepartamento = false;


        const check1 = event.target.checked;
        const checkDept = event.target.label;
        for (let i = 0; i < this.data.listasignacion.length; i++) {
            if (this.data.listasignacion[i].departamento === checkDept) {
                this.data.listasignacion[i].seleccionadoDept = check1;
                this.data.listasignacion[i].seleccionadoSku = check1;
            }
        }
        this.checkDepartamento = check1;
    }

    selectAllSubcategoria(event) {

        const check1 = event.target.checked;
        const checkDept = event.target.label;
        for (let i = 0; i < this.data.listasignacion.length; i++) {
            if (this.data.listasignacion[i].subcategoria === checkDept) {
                this.data.listasignacion[i].seleccionadoSubcategoria = check1;
                this.data.listasignacion[i].seleccionadoDept = check1;
                this.data.listasignacion[i].seleccionadoSku = check1;
            }
        }
    }

    selectAllClases(event) {
        this.data.checkClase = false;

        const check2 = event.target.checked;
        const checkClass = event.target.label;
        for (let i = 0; i < this.data.listasignacion.length; i++) {
            if (this.data.listasignacion[i].clase === checkClass) {
                this.data.listasignacion[i].seleccionadoClase = check2;
                this.data.listasignacion[i].seleccionadoDept = check2;
                this.data.listasignacion[i].seleccionadoSku = check2;
            }
        }
        this.checkClase = check2;
    }

    selectAllFamilias(event) {
        this.data.checkfamilia = false;
        const check3 = event.target.checked;
        const checkFam = event.target.label;
        for (let i = 0; i < this.data.listasignacion.length; i++) {
            if (this.data.listasignacion[i].familia === checkFam) {
                this.data.listasignacion[i].seleccionadoClase = check3;
                this.data.listasignacion[i].seleccionadoDept = check3;
                this.data.listasignacion[i].seleccionadoSku = check3;
                this.data.listasignacion[i].seleccionadoFamilia = check3;
            }
        }
        this.data.checkFamilia = check3;
    }

    selectAllSkusProducto(event) {
        const checkP = event.target.checked;
        for (let i = 0; i < this.data.listaproductos.length; i++) {
            this.data.listaproductos[i].seleccionadoSku = checkP;
            this.data.listaproductos[i].seleccionadoClase = checkP;
            this.data.listaproductos[i].seleccionadoDept = checkP;
            this.data.listaproductos[i].seleccionadoSubcategoria = checkP;
            this.data.listaproductos[i].seleccionadoFamilia = checkP;
        }
        this.checkSkus = checkP;
    }

    selectAllSkuProducto(event) {
        this.data.checkSku = false;
        this.data.listSku = event.target.label;
        const check1 = event.target.checked;
        for (let i = 0; i < this.data.listaproductos.length; i++) {
            if (this.data.listaproductos[i].sku === this.data.listSku) {
                this.data.listaproductos[i].seleccionadoSku = check1;
            }
        }
        this.checkDepartamento = check1;
    }


    selectAllDepartamentosProducto(event) {
        this.data.checkDepartamento = false;
        this.data.DSALES_Departamento__c = event.target.label;
        const check1 = event.target.checked;
        for (let i = 0; i < this.data.listaproductos.length; i++) {
            if (this.data.listaproductos[i].departamento === this.data.DSALES_Departamento__c) {
                this.data.listaproductos[i].seleccionadoDept = check1;
                this.data.listaproductos[i].seleccionadoSku = check1;
            }
        }
        this.checkDepartamento = check1;
    }

    selectAllSubcategoriaProducto(event) {
        this.data.checkSubcategoria = false;
        this.data.DSALES_Subcategoria__c = event.target.label;
        const check1 = event.target.checked;
        for (let i = 0; i < this.data.listaproductos.length; i++) {
            if (this.data.listaproductos[i].subcategoria === this.data.DSALES_Subcategoria__c) {
                this.data.listaproductos[i].seleccionadoSubcategoria = check1;
                this.data.listaproductos[i].seleccionadoDept = check1;
                this.data.listaproductos[i].seleccionadoSku = check1;
            }
        }
    }

    selectAllClasesProducto(event) {
        this.data.checkClase = false;
        const check2 = event.target.checked;
        this.data.DSALES_Clase__c = event.target.label;
        for (let i = 0; i < this.data.listaproductos.length; i++) {
            if (this.data.listaproductos[i].clase === this.data.DSALES_Clase__c) {
                this.data.listaproductos[i].seleccionadoClase = check2;
                this.data.listaproductos[i].seleccionadoDept = check2;
                this.data.listaproductos[i].seleccionadoSku = check2;
            }
        }
        this.checkClase = check2;
    }

    selectAllFamiliasProducto(event) {
        this.data.checkfamilia = false;
        const check3 = event.target.checked;
        this.data.DSALES_Familia__c = event.target.label;
        for (let i = 0; i < this.data.listaproductos.length; i++) {
            if (this.data.listaproductos[i].familia === this.data.DSALES_Familia__c) {
                this.data.listaproductos[i].seleccionadoClase = check3;
                this.data.listaproductos[i].seleccionadoDept = check3;
                this.data.listaproductos[i].seleccionadoSku = check3;
                this.data.listaproductos[i].seleccionadoFamilia = check3;
                this.data.DSALES_Departamento__c = this.data.listaproductos[i].departamento;
                this.data.DSALES_Clase__c = this.data.listaproductos[i].clase;
                this.data.DSALES_SKU__c = this.data.listaproductos[i].sku;
                this.data.DSALES_Servicio_Seguro__c = this.data.listaproductos[i].id;
            }
        }
        this.data.checkFamilia = check3;
    }

    skuSelected(event) {
        this.data.checkfamilia = false;
        const check3 = event.target.checked;
        const checkFam = event.target.label;
        for (let i = 0; i < this.data.listasignacion.length; i++) {
            if (this.data.listasignacion[i].seleccionadoSku === true) {
                this.data.listSkuSelected = this.data.listasignacion[i].sku;

            }
        }
        this.data.checkFamilia = check3;
    }

    vincularNuevoServicio() {
        getidservicio({ sku: this.pickList.StockKeepingUnit })
            .then(result => {
                this.data.idservicio = result;
                this.showSpinner = false;
                this.buscarProductsNoVinc();
            }).catch(error => {
                this.showSpinner = false;
            });
        this.data.confirmarGuardar = false;
        this.showVincuProduct = true;
        this.openTablaResultado = true;

    }
    buscarProductsNoVinc() {
        getBuscarProducto({ servicio: this.data.idservicio })
            .then(result => {
                this.data.listaproductos = result;
                this.showSpinner = false;
                if (this.data.listaproductos.length > 0) {
                    this.openTableVincProduct = true;
                } else {
                    this.pushMessage('Advertencia', 'warning', 'No se han encontrado productos.');
                    this.onClickBuscarIntanProduct();
                }
            }).catch(error => {
                this.showSpinner = false;
            });


    }

    agregarAnioPorcentaje() {
        if (this.data.aniosporcentaje < 5) {
            this.data.aniosporcentaje = this.data.aniosporcentaje + 1;
            if (this.data.aniosporcentaje == 1) {
                this.data.dos = true;
                this.data.tres = false;
                this.data.cuatro = false;
                this.data.cinco = false;
                this.data.seis = false;
            }
            else if (this.data.aniosporcentaje == 2) {
                this.data.dos = true;
                this.data.tres = true;
                this.data.cuatro = false;
                this.data.cinco = false;
                this.data.seis = false;
            }
            else if (this.data.aniosporcentaje == 3) {
                this.data.dos = true;
                this.data.tres = true;
                this.data.cuatro = true;
                this.data.cinco = false;
                this.data.seis = false;
            }
            else if (this.data.aniosporcentaje == 4) {
                this.data.dos = true;
                this.data.tres = true;
                this.data.cuatro = true;
                this.data.cinco = true;
                this.data.seis = false;
            }
            else if (this.data.aniosporcentaje == 5) {
                this.data.dos = true;
                this.data.tres = true;
                this.data.cuatro = true;
                this.data.cinco = true;
                this.data.seis = true;
            }
        }

    }
    quitarAnioPorcentaje() {
        if (this.data.aniosporcentaje > 0) {
            this.data.aniosporcentaje = this.data.aniosporcentaje - 1;
            if (this.data.aniosporcentaje == 0) {
                this.data.dos = false;
                this.data.tres = false;
                this.data.cuatro = false;
                this.data.cinco = false;
                this.data.seis = false;
                this.matrizPorcentaje.anio2 = 0;
            }
            else if (this.data.aniosporcentaje == 1) {
                this.data.dos = true;
                this.data.tres = false;
                this.data.cuatro = false;
                this.data.cinco = false;
                this.data.seis = false;
                this.matrizPorcentaje.anio3 = 0;
            }
            else if (this.data.aniosporcentaje == 2) {
                this.data.dos = true;
                this.data.tres = true;
                this.data.cuatro = false;
                this.data.cinco = false;
                this.data.seis = false;
                this.matrizPorcentaje.anio4 = 0;
            }
            else if (this.data.aniosporcentaje == 3) {
                this.data.dos = true;
                this.data.tres = true;
                this.data.cuatro = true;
                this.data.cinco = false;
                this.data.seis = false;
                this.matrizPorcentaje.anio5 = 0;
            }
            else if (this.data.aniosporcentaje == 4) {
                this.data.dos = true;
                this.data.tres = true;
                this.data.cuatro = true;
                this.data.cinco = true;
                this.data.seis = false;
                this.matrizPorcentaje.anio6 = 0;
            }
        }
    }

    openFormCampaigns(event) {
        this.data.sku = event.currentTarget.dataset.id;
        getidservicio({ sku: this.data.sku })
            .then(result => {
                this.data.idProducto = result;
                this.getCampanas();
            }).catch(error => {
            });
    }

    openFormTypes(event) {
        this.data.sku = event.currentTarget.dataset.id;
        getidservicio({ sku: this.data.sku })
            .then(result => {
                this.data.idProducto = result;
                this.getTiposUso();
            }).catch(error => {
            });
    }

    closeformCampaignsTypes() {
        this.data.showCampaigns = false;
        this.data.showTypes = false;
        this.tiposUsoSelected = [];
        this.campanasSelected = [];
    }
    cancelar3() {
        this.openTableVincProduct = false;
        this.limpiarCampos();
    }

    openEmergenteDesvincular() {
        for (let i = 0; i < this.data.listasignacion.length; i++) {
            if (this.data.listasignacion[i].seleccionadoSku === true) {
                this.showConfirmarDesvincular = true;
            }
        }
    }

    cancelar4() {
        this.showConfirmarDesvincular = false;
        this.data.confirmarGuardar = false;
        this.limpiarCampos();
    }

    openEmergenteVincular() {
        for (let i = 0; i < this.data.listaproductos.length; i++) {
            if (this.data.listaproductos[i].seleccionadoSku === true) {

                this.showConfirmarVincular = true;
            }
        }
    }

    cancelar5() {
        this.showConfirmarVincular = false;
    }

    getCampanas() {
        getCampaings()
            .then(campanas => {
                this.data.listaCampanas = campanas;
                this.getCampanasUsadas();
            })
    }

    getTiposUso() {
        getTipoUso()
            .then(tipos => {
                this.data.listaTiposuso = tipos;
                this.getTiposUsoUsadas();
            })
    }

    getTiposUsoUsadas() {
        getTiposUsoUsed({ idProducto: this.data.idProducto })
            .then(tipos => {
                this.data.tiposUsoSelected = tipos;
                this.tiposUsoSelected.push(...this.data.tiposUsoSelected);
                this.data.showTypes = true;
            })
    }

    getCampanasUsadas() {
        getCampanasUsed({ idProducto: this.data.idProducto })
            .then(tipos => {
                this.data.campanasSelected = tipos;
                this.campanasSelected.push(... this.data.campanasSelected);
                this.data.showCampaigns = true;
            })
    }

    getSkuforCampaings() {
        updateCampaigns({ allData: JSON.stringify(this.data.campanasSelected), idProducto: this.data.idProducto })
                        .then(result => {
                            this.pushMessage('Exitoso', 'success', 'Campañas actualizadas exitosamente.');
                        }).catch(error => {
                        });
                    this.closeformCampaignsTypes();
    }

    getSkuforTypes() {
        updateTipoUso({ allData: JSON.stringify(this.data.tiposUsoSelected), idProducto: this.data.idProducto })
                            .then(result => {
                                this.pushMessage('Exitoso', 'success', 'Tipos de usos actualizados exitosamente.');
                            }).catch(error => {                          
                            });
                        this.closeformCampaignsTypes();
    }

    openTypesVincuMasiva() {
        getTipoUso()
            .then(tipos => {
                this.data.listaTiposuso = tipos;
                this.data.showTypes = true;
            })
        this.data.idProducto = null;
    }

    handleInputChangeVehicleID(event) {
        const name = event.target.name;
        this.data.idvehiculo = event.detail.value;
        for (let i = 0; i < this.data.listServicios.length; i++) {
            if (this.data.listServicios[i].id == name) {
                this.data.listServicios[i].idvehiculo = this.data.idvehiculo;
                
            } 
        }
    }

    getNameRecordTypeId(){
        if(this.data.confirmarProfileType=='Administrador SM') {
            this.data.nameRecordType= 'Seguro de Motos';
        }
        else if(this.data.confirmarProfileType=='Administrador del sistema') {
            this.data.nameRecordType= 'Administrador del sistema';
        }
        else {
            this.data.nameRecordType= 'Garantía Extendida';
        }
    }

    openSearchFilter(){
        this.showc=true;
        this.showbyfilter=false;
        this.showCrearIntangible=false;
        this.showVincuProduct=false;
    }
    
    getservicecategories(){
       this.data.showcompras=true;
       this.data.valueCategoryService= '';
        this.data.valueSubcategoryService= '';
        this.data.valueClassService= '';
        this.data.valueFamilyService= '';
        getserviciocategorias()
        .then(result => {
            this.data.servicioCategoria= result;
        }).catch(error => {
        });
    }

    getservicesubcategories(event){
        this.data.valueCategoryService=event.target.value;
        getserviciosubcategorias({valueCategoria: this.data.valueCategoryService})
        .then(result => {
            this.data.servicioSubcategoria= result;
        }).catch(error => {
        });
    }

    getserviceclass(event){
        this.data.valueSubcategoryService=event.target.value;
        getservicioclase({valueCategoria: this.data.valueCategoryService, valueSubcategoria:this.data.valueSubcategoryService})
        .then(result => {
            this.data.servicioClases= result;
        }).catch(error => {
        });
    }

    getservicefamily(event){
        this.data.valueClassService=event.target.value;
        getserviciofamilia({valueCategoria: this.data.valueCategoryService, valueSubcategoria:this.data.valueSubcategoryService, valueClases: this.data.valueClassService})
        .then(result => {
            this.data.servicioFamilias= result;
        }).catch(error => {
        });
    }

    getValueFamily(event){
        this.data.valueFamilyService=event.target.value;
    }

    getservicesku(){
        if( this.data.valueCategoryService=='' || this.data.valueSubcategoryService== '' || this.data.valueClassService== '' || this.data.valueFamilyService== ''){
            this.pushMessage('Advertencia', 'warning', 'Existen campos vacios o no seleccionados');
        }
        else{
            getserviciosku({valueCategoria: this.data.valueCategoryService, valueSubcategoria:this.data.valueSubcategoryService, valueClases: this.data.valueClassService, valueFamilias: this.data.valueFamilyService})
            .then(result => {
                this.data.servicioSku= result;
            }).catch(error => {
            });
        }
        
    }
    
    handleKeyDownSearch(event) {
        if (event.key === 'Enter') {
            this.search();
          // Aquí puedes llamar a la función que quieres ejecutar cuando se presiona Enter
          console.log('Enter presionado');
        }
      }
     
      

    











}