//
//  estructuras.swift
//  Test App 003
//
//  Created by adrian aguilar on 11/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import Foundation
import Alamofire
import GoogleMaps
import CoreLocation


struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        return self.sharedInstance.isReachable
    }
}

struct pagina{
    var img: UIImage
    var url: String
    
    init(img: UIImage, url: String){
        self.img = img
        self.url = url
    }
}

struct place{
    let name: String!
    let street: String!
    let attention: String!
    let coordinate: CLLocationCoordinate2D
    let date_sync: String!
    var selected: Bool
    
    init(name: String, street: String, attention: String, coordinate : CLLocationCoordinate2D, selected: Bool, date_sync: String) {
        self.name = name
        self.street = street
        self.attention = attention
        self.coordinate = coordinate
        self.selected = selected
        self.date_sync = date_sync
    }
}

struct location{
    var lat: NSNumber?
    var lng: NSNumber?
    
    init(lat: NSNumber, lng: NSNumber) {
        self.lat = lat
        self.lng = lng
    }
}

struct Bill {
    let name : String
    let index : Int
    var enabled : Bool
    let date_ini : String
    let date_end : String
    let value : String
    let type : String
    let code : String
    
    
    init(name : String, enabled : Bool, index : Int, date_ini : String, date_end : String, value : String, type : String, code : String) {
        self.name = name
        self.enabled = enabled
        self.index = index
        self.date_ini = date_ini
        self.date_end = date_end
        self.value = value
        self.type = type
        self.code = code
    }
}

struct User: Decodable {
    var id_user: Int
    var document: String?
    var person: String
    var email: String?
    var phone: String?
    var sync_date: String
    var adress: String?
    var status: Int
    var error: Int?
    
}

struct UserLogin {
    let id_user: Int?
    let email: String?
}

struct UserDB {
    var id: Int?
    var name: String?
    var email: String?
    var identifier: String?
    var addresss: String?
    var telephone: String?
    var contract: String?
    var pass: String?
}

struct data_pie {
    var name : String
    var y : Double
    
    init(name:String, y:Double) {
        self.name = name
        self.y = y
    }
}

struct Process {
    let title : String
    let subtitle : String
    let code: String
    let status: String
    let date: String
    let img: UIImage
    var enabled : Bool
    let date_end: String
    let json: String
    
    init(_ title : String, _ subtitle : String, _ code : String,_ status: String,_ date: String,_ img: UIImage,_ enabled: Bool,_ date_end: String , _ json: String) {
        self.title = title
        self.subtitle = subtitle
        self.code = code
        self.status = status
        self.date = date
        self.img = img
        self.enabled = enabled
        self.date_end = date_end
        self.json = json
    }
}

struct account {
    let service: String
    let alias: String
    let document: String
    let date_sync: String
    
    init(service : String , alias : String, document : String, date_sync : String) {
        self.service = service
        self.alias = alias
        self.document = document
        self.date_sync = date_sync
    }
}

struct notification {
    let contract: String
    let type: String
    let document_code: String
    let message: String
    let date_gen: String
    let date_sync: String
    
    init(contract: String , type: String , document_code: String , message: String , date_gen: String , date_sync: String) {
        self.contract = contract
        self.type = type
        self.document_code = document_code
        self.message = message
        self.date_gen = date_gen
        self.date_sync = date_sync
    }
}

//detalles de contratos
struct detailAccount {
    let facturas_vencidas: String
    let deuda_diferida: String
    let max_fecha_pago: String
    let tipo_medidor: String
    let serie_medidor: String
    let consumo: String
    let estado_corte: String
    let contrato: String
    let cliente: String
    let uso_servicio: String
    let direccion: String
    let ci_ruc: String
    let id_direccion: String
    let id_direccion_contrato: String
    let id_producto: String
    let id_cliente: String
    let deuda_pendiente: String
    let servicio: String
    let alias: String
    
    
    init(facturas_vencidas: String, deuda_diferida: String, max_fecha_pago: String, tipo_medidor: String, serie_medidor: String, consumo: String, estado_corte: String, contrato: String, cliente: String, uso_servicio: String, direccion: String, ci_ruc: String, id_direccion: String, id_direccion_contrato: String, id_producto: String, id_cliente: String, deuda_pendiente: String, servicio: String, alias: String) {
        self.facturas_vencidas = facturas_vencidas
        self.deuda_diferida = deuda_diferida
        self.max_fecha_pago = max_fecha_pago
        self.tipo_medidor = tipo_medidor
        self.serie_medidor = serie_medidor
        self.consumo = consumo
        self.estado_corte = estado_corte
        self.contrato = contrato
        self.cliente = cliente
        self.uso_servicio = uso_servicio
        self.direccion = direccion
        self.ci_ruc = ci_ruc
        self.id_direccion = id_direccion
        self.id_direccion_contrato = id_direccion_contrato
        self.id_producto = id_producto
        self.id_cliente = id_cliente
        self.deuda_pendiente = deuda_pendiente
        self.servicio = servicio
        self.alias = alias
    }
}

// query 3  facturas del contrato

struct billsAccount {
    let codigo_factura: String
    let fecha_emision: String
    let fecha_vencimiento: String
    let monto_factura: String
    let saldo_factura: String
    let estado_factura: String
    let consumo_kwh: String
    let lectura_actual: String
    let servicio: String
    
    init(codigo_factura: String, fecha_emision: String, fecha_vencimiento: String, monto_factura: String, saldo_factura: String, estado_factura: String, consumo_kwh: String, lectura_actual: String, servicio: String) {
        self.codigo_factura = codigo_factura
        self.fecha_emision = fecha_emision
        self.fecha_vencimiento = fecha_vencimiento
        self.monto_factura = monto_factura
        self.saldo_factura = saldo_factura
        self.estado_factura = estado_factura
        self.consumo_kwh = consumo_kwh
        self.lectura_actual = lectura_actual
        self.servicio = servicio
    }
}

// query 5  detalle de deuda

struct detailDebs {
    let nombre: String
    let descripcion: String
    let valor: String
    let servicio: String
    
    init(nombre: String , descripcion: String , valor: String, servicio: String) {
        self.nombre = nombre
        self.descripcion = descripcion
        self.valor = valor
        self.servicio = servicio
    }
}

// query 9  tramites realizados

struct detailProcedure {
    let codigo: String
    let descripcion: String
    let fecha_inicio: String
    let fecha_fin: String
    let estado: String
    let json: String
    let descripcion2: String
    let descripcion3: String
    let servicio: String
    
    init(codigo: String , descripcion: String , fecha_inicio: String , fecha_fin: String , estado: String , json: String , descripcion2: String , descripcion3: String, servicio: String) {
        self.codigo = codigo
        self.descripcion = descripcion
        self.fecha_inicio = fecha_inicio
        self.fecha_fin = fecha_fin
        self.estado = estado
        self.json = json
        self.descripcion2 = descripcion2
        self.descripcion3 = descripcion3
        self.servicio = servicio
    }
}

// query 48  lista de pagos

struct detailPayment {
    let meses: String
    let monto_pago: String
    let codigo_pago: String
    let tipo_recaudacion: String
    let fecha_pago: String
    let estado_pago: String
    let numero_servicio: String
    let terminal: String
    let sync_date: String
    let servicio: String
    
    init(meses: String , monto_pago: String , codigo_pago: String , tipo_recaudacion: String , fecha_pago: String , estado_pago: String , numero_servicio: String , terminal: String , sync_date: String, servicio: String) {
        self.meses = meses
        self.monto_pago = monto_pago
        self.codigo_pago = codigo_pago
        self.tipo_recaudacion = tipo_recaudacion
        self.fecha_pago = fecha_pago
        self.estado_pago = estado_pago
        self.numero_servicio = numero_servicio
        self.terminal = terminal
        self.sync_date = sync_date
        self.servicio = servicio
    }
}

struct detailContract {
    
    let id_cliente: String
    let id_contrato: String
    let direccion_tradicional: String
    let nombre_beneficiario: String
    let identificacion_benef: String
    let nombre_propietario: String
    let identifiacion_propietario: String
    let id_cliente_propietario: String
    let factcodi: String
    let factnufi: String
    let fecha_emision: String
    let id_producto: String
    let fecha_venc_fact: String
    let numdoc: String
    let tipodocu: String
    let rucempresa: String
    let deuda_pendiente: String
    let account_with_balance: String
    let def_balance: String
    let consumo: String
    let sbitemtipo: String
    let sbitem: String
    let sbserie: String
    let categoria: String
    let subcategoria: String
    let estado_corte: String
    let ult_fecha_pago: String
    let id_direccion_contrato: String
    let address_id: String
    let telefono: String
    var status: Bool
    
    init(id_cliente: String
        ,id_contrato: String
        ,direccion_tradicional: String
        ,nombre_beneficiario: String
        ,identificacion_benef: String
        ,nombre_propietario: String
        ,identifiacion_propietario: String
        ,id_cliente_propietario: String
        ,factcodi: String
        ,factnufi: String
        ,fecha_emision: String
        ,id_producto: String
        ,fecha_venc_fact: String
        ,numdoc: String
        ,tipodocu: String
        ,rucempresa: String
        ,deuda_pendiente: String
        ,account_with_balance: String
        ,def_balance: String
        ,consumo: String
        ,sbitemtipo: String
        ,sbitem: String
        ,sbserie: String
        ,categoria: String
        ,subcategoria: String
        ,estado_corte: String
        ,ult_fecha_pago: String
        ,id_direccion_contrato: String
        ,address_id: String
        ,telefono: String
        ,status: Bool) {
        
        self.id_cliente = id_cliente
        self.id_contrato = id_contrato
        self.direccion_tradicional = direccion_tradicional
        self.nombre_beneficiario = nombre_beneficiario
        self.identificacion_benef = identificacion_benef
        self.nombre_propietario = nombre_propietario
        self.identifiacion_propietario = identifiacion_propietario
        self.id_cliente_propietario = id_cliente_propietario
        self.factcodi = factcodi
        self.factnufi = factnufi
        self.fecha_emision = fecha_emision
        self.id_producto = id_producto
        self.fecha_venc_fact = fecha_venc_fact
        self.numdoc = numdoc
        self.tipodocu = tipodocu
        self.rucempresa = rucempresa
        self.deuda_pendiente = deuda_pendiente
        self.account_with_balance = account_with_balance
        self.def_balance = def_balance
        self.consumo = consumo
        self.sbitemtipo = sbitemtipo
        self.sbitem = sbitem
        self.sbserie = sbserie
        self.categoria = categoria
        self.subcategoria = subcategoria
        self.estado_corte = estado_corte
        self.ult_fecha_pago = ult_fecha_pago
        self.id_direccion_contrato = id_direccion_contrato
        self.address_id = address_id
        self.telefono = telefono
        self.status = status
    }
    
}

