//
//  WService.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 15/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import Foundation
import GoogleMaps
import SQLite

class WService {
    let url_master = "http://54.86.88.196/aclientAES2/w?c&q="
    var user_in = User(id_user: 0, document: "", person: "", email: "", phone: "", sync_date: "", adress: "", status: 1, error: 1)
    
    let key = "Altura"
    let iv = "gqLOHUioQ0QjhuvI"
    
    
    let dbase = DBase();
    var db: Connection!
    
    //funcion para cargar todo mediante webservices json
    func loadUser(usr_id:String , pass: String, success: @escaping (_ value:Int, _ user:User) -> Void, error: @escaping (_ value:Int,_ user:User) -> Void ){
        print("entra en load user")
        
        if !Connectivity.isConnectedToInternet {
            print("no existe coneccion a internet")
            return error(4,self.user_in)
        }
        
        let n_key = key.md5()
        
        user_in = User(id_user: 0, document: "", person: "", email: "", phone: "", sync_date: "", adress: "", status: 1, error: 1)
        
        let url_part = "action=login&mail=\(usr_id)&pass=\(pass)&os=2&imei=111"
        let encode = try! url_part.aesEncrypt(key: n_key, iv: iv)
        
        print("codificado: \(encode)")
        
        let jsn_url = url_master + (encode.urlEncode() as String)
        
        print(jsn_url)
        
        guard let url = try? URL(string: jsn_url) else {
            return error(4,self.user_in)
        }
        
        
        var req = 4;
        
        URLSession.shared.dataTask(with: url!){ (data , response ,err ) in
            guard let data = data else {return error(4,self.user_in)}
            
            do{
                guard let data_received = String(data: data, encoding: .utf8) else{ return error(4,self.user_in) }
                print("data received: \(data_received)")
                
                let data2 = try! data_received.aesDecrypt(key: n_key, iv: self.iv)
                print("datos decript load user \(data2)")
                let user =  try JSONDecoder().decode(User.self, from: data2.data(using: .utf8)!)
                print("usuario en funcion: \(user)")
                if( user.status > 0){
                    self.user_in = user
                    print("usuario en funcion despues de if: \(user)")
                    if(user.status == 1 ){ // no valida email
                        req = 2
                        print("retorna error")
                        return error(req,self.user_in)
                    }else{
                        req = 1
                        print("retorna success")
                        return success(req,self.user_in)
                    }
                    
                }else{ // no existe
                    req = 3
                    print("retorna error load user")
                    return error(req,self.user_in)
                }
                
            }catch let errJson {
                print(errJson)
                req = 4
                print("retorna error catch load user")
                return error(req,self.user_in)
            }
            
            }.resume()
        
        
    }
    
    func loadAcounts(id_user: String, date: String, success: @escaping (_ list: Array<Any>) -> Void, error: @escaping (_ list: Array<Any>, _ message: String) -> Void) {
        
        print("entra en load accounts")
        
        var accounts:[account] = []
        
        if !Connectivity.isConnectedToInternet {
            print("no hay internet")
            return error( accounts,"No cuenta con conexión a Internet")
        }
        
        let n_key = key.md5()
        let url_part = "action=query&id_query=43&id_user=\(id_user)&fecha=\(date)"
        let encode = try! url_part.aesEncrypt(key: n_key, iv: iv)
        
        print("codificado: \(encode)")
        
        let jsn_url = url_master + (encode.urlEncode() as String)
        print(jsn_url)
        
        guard var url = try? URLRequest(url: NSURL(string: jsn_url) as! URL) else {
            print("Error al generar la url para cargar cuentas")
            return error( accounts,"Error al generar la url para cargar cuentas")
            
        }
        
        //var request = URLRequest(url: url1)
        //url.httpBody = body
        url.httpMethod = "POST"
        let (data, response, err) = URLSession.shared.synchronousDataTask(urlrequest: url)
        if let error2 = err {
            print("Synchronous task ended with error load accounts: \(error2)")
            return error( accounts,"Error de comunicación con el servidor. Por favor contacte al administrador del sistema.")
        }
        else {
            print("Synchronous task ended without errors.")
            //print(data)
            guard let data = data else { return error( accounts,"Error al obtener la data") }
            
            do{
                guard let data_received = String(data: data, encoding: .utf8) else{ return error( accounts,"Error encodign utf8") }
                print("data received: \(data_received)")
                
                let data2 = try! data_received.aesDecrypt(key: n_key, iv: self.iv)
                print("datos decript cuentas \(data2)")
                
                let dictionary: Dictionary<NSObject, AnyObject> = try JSONSerialization.jsonObject(with: data2.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<NSObject, AnyObject>
                
                var date_sync = ""
                var list: NSArray = []
                var message = ""
                var err = false
                for (key,value) in dictionary {
                    if key as! String == "sync_date" {
                        date_sync = value as! String
                    }
                    if key as! String == "row"{
                        list = value as! NSArray
                        
                    }
                    if key as! String == "error"{
                        err = true
                        message = value as! String
                    }
                }
                
                if err{
                    return error(accounts,message)
                }
                
                for value in list {
                    let val = value as! NSArray
                    
                    let account_temp = account.init(service: val[0] as! String, alias: val[1] as! String, document: val[2] as! String, date_sync: date_sync )
                    accounts.append(account_temp)
                }
                
                return success(accounts)
                
            }catch let errJson {
                print(errJson)
                return error( accounts,"Error \(errJson)")
            }
            
        }
        
        
    }
    
    func loadCore(id_user: String, accounts: [account], success: @escaping (_ status: Bool) -> Void, error: @escaping (_ status: Bool, _ message: String) -> Void) {
        
        print("entra en load core")
        let n_key = key.md5()
        
        if !Connectivity.isConnectedToInternet {
            return error( false,"No cuenta con conexión a Internet")
        }
        
        for accountItem in accounts{
            
            let url_part = "action=querys&id_query=2,3,5,9,48&id_user=\(id_user)&ID_USER=\(id_user)&CONTRATO=\(accountItem.service)&NS=\(accountItem.service)&ID=\(accountItem.document)&os=2"
            let encode = try! url_part.aesEncrypt(key: n_key, iv: iv)
            
            var detailPaymentList:[detailPayment] = []
            var detailProcedureList:[detailProcedure] = []
            var detailDebsList:[detailDebs] = []
            var billsAccountList:[billsAccount] = []
            var detailAccountList:[detailAccount] = []
            
            var q1 = true
            var q2 = true
            var q3 = true
            var q4 = true
            var q5 = true
            
            var message = ""
            
            print("codificado: \(encode)")
            
            let jsn_url = url_master + (encode.urlEncode() as String)
            print(jsn_url)
            
            guard var url = try? URLRequest(url: NSURL(string: jsn_url) as! URL) else {
                print("Error al generar la url load core")
                return error( false,"Error de comunicación con el servidor. Por favor contacte al administrador del sistema.")
                
            }
            
            //var request = URLRequest(url: url1)
            //url.httpBody = body
            url.httpMethod = "POST"
            let (data, response, err) = URLSession.shared.synchronousDataTask(urlrequest: url)
            if err != nil {
                print("Synchronous task ended with error load core: \(err)")
                return error( false,"Error de comunicación con el servidor. Por favor contacte al administrador del sistema.")
            }else {
                print("Synchronous task ended without errors.")
                //print(data)
                guard let data = data else { return error( false,"Error de comunicación con el servidor. Por favor contacte al administrador del sistema.") }
                
                do{
                    guard let data_received = String(data: data, encoding: .utf8) else{
                        
                        print("Error en codificacion utf8")
                        return error( false,"Error de comunicación con el servidor. Por favor contacte al administrador del sistema.")
                        
                    }
                    print("data received: \(data_received)")
                    
                    let data2 = try! data_received.aesDecrypt(key: n_key, iv: self.iv)
                    print("datos decript load core \(data2)")
                    
                    let dictionary: Dictionary<NSObject, AnyObject> = try JSONSerialization.jsonObject(with: data2.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<NSObject, AnyObject>
                    for (keyT,valueT) in dictionary {
                        // query 2  detalles de contratos
                        if keyT as! String == "2" {
                            let data_temp = valueT as! Dictionary<NSObject, AnyObject>
                            var date_sync = ""
                            var list: NSArray = []
                            for (key,value) in data_temp {
                                if key as! String == "sync_date" {
                                    date_sync = value as! String
                                }
                                if key as! String == "row"{
                                    list = value as! NSArray
                                }
                                if key as! String == "error"{
                                    q1 = false
                                    message = value as! String
                                }
                                
                                if key as! String == "status"{
                                    if value as! Int == -1{
                                        q1 = false
                                    }
                                }
                            }
                            for value in list {
                                let value = value as! NSArray
                                var val:[String] = []
                                for i in 0..<value.count  {
                                    if(value[i] is NSNull){
                                        val.append("")
                                    }else{
                                        val.append(value[i] as! String)
                                    }
                                }
                                
                                let detailAccount_temp = detailAccount.init( facturas_vencidas: val[0] , deuda_diferida: val[1] , max_fecha_pago: val[2] , tipo_medidor: val[3] , serie_medidor: val[4] , consumo: val[5] , estado_corte: val[6] , contrato: val[7] , cliente: val[8] , uso_servicio: val[9] , direccion: val[10] , ci_ruc: val[11] , id_direccion: val[12] , id_direccion_contrato: val[13] , id_producto: val[14] , id_cliente: val[15] , deuda_pendiente: val[16] , servicio: accountItem.service, alias: accountItem.alias)
                                detailAccountList.append(detailAccount_temp)
                            }
                            
                            //enviar a guardar el detalle de contratos en la base
                        }
                        // query 3  facturas del contrato
                        if keyT as! String == "3" {
                            let data_temp = valueT as! Dictionary<NSObject, AnyObject>
                            var date_sync = ""
                            //var message = ""
                            var list: NSArray = []
                            for (key,value) in data_temp {
                                if key as! String == "sync_date" {
                                    date_sync = value as! String
                                }
                                if key as! String == "row"{
                                    list = value as! NSArray
                                }
                                if key as! String == "error"{
                                    q2 = false
                                    message = value as! String
                                }
                                
                                if key as! String == "status"{
                                    if value as! Int == -1{
                                        q2 = false
                                    }
                                }
                            }
                            for value in list {
                                let value = value as! NSArray
                                var val:[String] = []
                                for i in 0..<value.count  {
                                    if(value[i] is NSNull){
                                        val.append("")
                                    }else{
                                        val.append(value[i] as! String)
                                    }
                                }
                                
                                let billsAccount_temp = billsAccount.init( codigo_factura: val[0] , fecha_emision: val[1] , fecha_vencimiento: val[2] , monto_factura: val[3] , saldo_factura: val[4] , estado_factura: val[5] , consumo_kwh: val[6] , lectura_actual: val[7] , servicio: accountItem.service)
                                billsAccountList.append(billsAccount_temp)
                            }
                        }
                        // query 5  detalle de deuda
                        if keyT as! String == "5" {
                            let data_temp = valueT as! Dictionary<NSObject, AnyObject>
                            var date_sync = ""
                            var list: NSArray = []
                            for (key,value) in data_temp {
                                if key as! String == "sync_date" {
                                    date_sync = value as! String
                                }
                                if key as! String == "row"{
                                    list = value as! NSArray
                                }
                                if key as! String == "error"{
                                    q3 = false
                                    message = value as! String
                                }
                                
                                if key as! String == "status"{
                                    if value as! Int == -1{
                                        q3 = false
                                    }
                                }
                            }
                            for value in list {
                                let value = value as! NSArray
                                var val:[String] = []
                                for i in 0..<value.count  {
                                    if(value[i] is NSNull){
                                        val.append("")
                                    }else{
                                        val.append(value[i] as! String)
                                    }
                                }
                                
                                let detailDebs_temp = detailDebs.init(nombre: val[0] , descripcion: val[1] , valor: val[2] , servicio: accountItem.service)
                                detailDebsList.append(detailDebs_temp)
                            }
                        }
                        // query 9  tramites realizados
                        if keyT as! String == "9" {
                            let data_temp = valueT as! Dictionary<NSObject, AnyObject>
                            var date_sync = ""
                            var list: NSArray = []
                            for (key,value) in data_temp {
                                if key as! String == "sync_date" {
                                    date_sync = value as! String
                                }
                                if key as! String == "row"{
                                    list = value as! NSArray
                                }
                                if key as! String == "error"{
                                    q4 = false
                                    message = value as! String
                                }
                                
                                if key as! String == "status"{
                                    if value as! Int == -1{
                                        q4 = false
                                    }
                                }
                            }
                            for value in list {
                                let value = value as! NSArray
                                var val:[String] = []
                                for i in 0..<value.count  {
                                    if(value[i] is NSNull){
                                        val.append("")
                                    }else{
                                        val.append(value[i] as! String)
                                    }
                                }
                                
                                let detailProcedure_temp = detailProcedure.init(codigo: val[0] , descripcion: val[1] , fecha_inicio: val[2] , fecha_fin: val[3] , estado: val[4] , json: val[5] , descripcion2: val[6] , descripcion3: val[7] , servicio: accountItem.service)
                                detailProcedureList.append(detailProcedure_temp)
                            }
                        }
                        // query 48  lista de pagos
                        if keyT as! String == "48" {
                            let data_temp = valueT as! Dictionary<NSObject, AnyObject>
                            var date_sync = ""
                            var list: NSArray = []
                            for (key,value) in data_temp {
                                if key as! String == "sync_date" {
                                    date_sync = value as! String
                                }
                                if key as! String == "row"{
                                    list = value as! NSArray
                                }
                                if key as! String == "error"{
                                    q5 = false
                                    message = value as! String
                                }
                                
                                if key as! String == "status"{
                                    if value as! Int == -1{
                                        q5 = false
                                    }
                                }
                            }
                            for value in list {
                                let value = value as! NSArray
                                var val:[String] = []
                                for i in 0..<value.count  {
                                    if(value[i] is NSNull){
                                        val.append("")
                                    }else{
                                        val.append(value[i] as! String)
                                    }
                                }
                                
                                let detailPayment_temp = detailPayment.init(meses: val[0] , monto_pago: val[1] , codigo_pago: val[2] , tipo_recaudacion: val[3] , fecha_pago: val[4] , estado_pago: val[5] , numero_servicio: val[6] , terminal: val[7] , sync_date: date_sync, servicio: accountItem.service)
                                detailPaymentList.append(detailPayment_temp)
                            }
                        }
                        
                    }
                    
                    if !q1 && !q2 && !q3 && !q4 && !q5 {
                        return error( false,message)
                    }
                    
                    let status = dbase.connect_db()
                    if( status.value ){
                        self.db = status.conec
                        if q1{
                            do{
                                try self.db.execute("DELETE FROM cuenta_detalle where servicio = '\(accountItem.service)';")
                                self.dbase.insertDetailsAccounts(list: detailAccountList)
                                
                            }catch let Result.error(message, code, statement){
                                print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
                            }catch {
                                print("error en q1")
                            }
                        }
                        if q2{
                            do{
                                try self.db.execute("DELETE FROM deudas where servicio = '\(accountItem.service)';")
                                self.dbase.insertDebs(list: detailDebsList)
                                
                            }catch let Result.error(message, code, statement){
                                print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
                            }catch {
                                print("error en q2")
                            }
                        }
                        if q3{
                            do{
                                try self.db.execute("DELETE FROM facturas where servicio = '\(accountItem.service)';")
                                self.dbase.insertBillsAccount(list: billsAccountList)
                                
                            }catch let Result.error(message, code, statement){
                                print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
                            }catch {
                                print("error en q3")
                            }
                        }
                        if q4{
                            do{
                                try self.db.execute("DELETE FROM tramites where servicio = '\(accountItem.service)';")
                                self.dbase.insertDetailProcedure(list: detailProcedureList)
                                
                                
                            }catch let Result.error(message, code, statement){
                                print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
                            }catch {
                                print("error en q4")
                            }
                        }
                        if q5{
                            do{
                                try self.db.execute("DELETE FROM pagos where servicio = '\(accountItem.service)';")
                                self.dbase.insertDetailPaymentT(list: detailPaymentList)
                                
                            }catch let Result.error(message, code, statement){
                                print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
                            }catch {
                                print("error en q5")
                            }
                        }
                        
                        
                    }
                    
                    print(detailAccountList)
                    print(billsAccountList)
                    print(detailDebsList)
                    print(detailProcedureList)
                    print(detailPaymentList)
                    
                    
                }catch let errJson {
                    print(errJson)
                    return error( false,"Error \(errJson)")
                }
                
            }
            
            
        }//end for
        
        return success(true)
        
    }
    
    func loadNotifications(id_user: String, date: String, success: @escaping (_ list: Array<notification>) -> Void, error: @escaping (_ list: Array<Any>, _ message: String) -> Void) {
        
        print("entra en load notifications")
        
        let n_key = key.md5()
        
        var notificationsList:[notification] = []
        
        if !Connectivity.isConnectedToInternet {
            return error( notificationsList,"No cuenta con conexión a Internet")
        }
        
        let url_part = "action=query&id_query=65&id_user=\(id_user)&ID_USER=\(id_user)&FECHA=\(date)"
        let encode = try! url_part.aesEncrypt(key: n_key, iv: iv)
        
        print("codificado: \(encode)")
        
        let jsn_url = url_master + (encode.urlEncode() as String)
        print(jsn_url)
        
        guard var url = try? URLRequest(url: NSURL(string: jsn_url) as! URL) else {
            print("error Notificaciones")
            return error(notificationsList,"Error al generar la url Notificaciones")
            
        }
        
        //var request = URLRequest(url: url1)
        //url.httpBody = body
        url.httpMethod = "POST"
        let (data, response, err) = URLSession.shared.synchronousDataTask(urlrequest: url)
        if err != nil {
            print("Synchronous task ended with error: \(String(describing: err))")
            return error(notificationsList,"Error de comunicación con el servidor. Por favor contacte al administrador del sistema.")
        }
        else {
            print("Synchronous task ended without errors.")
            //print(data)
            guard let data = data else { return error(notificationsList,"Error al obtener la data") }
            
            do{
                guard let data_received = String(data: data, encoding: .utf8) else{ return error(notificationsList,"Error encodign utf8") }
                print("data received: \(data_received)")
                
                let data2 = try! data_received.aesDecrypt(key: n_key, iv: self.iv)
                print("datos decript notificaciones \(data2)")
                
                let dictionary: Dictionary<NSObject, AnyObject> = try JSONSerialization.jsonObject(with: data2.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<NSObject, AnyObject>
                
                var date_sync = ""
                var list: NSArray = []
                var message = ""
                var err = false
                for (key,value) in dictionary {
                    if key as! String == "sync_date" {
                        date_sync = value as! String
                    }
                    if key as! String == "row"{
                        list = value as! NSArray
                    }
                    if key as! String == "error"{
                        err = true
                        message = value as! String
                    }
                }
                
                if err {
                    return error([], message)
                }
                
                for value in list {
                    let val = value as! NSArray
                    
                    let notification_temp = notification.init(contract: val[0] as! String, type: val[1] as! String, document_code: val[2] as! String, message: val[3] as! String, date_gen: val[4] as! String, date_sync: date_sync)
                    notificationsList.append(notification_temp)
                }
                
                success(notificationsList)
                
            }catch let errJson {
                print(errJson)
                error( [],"Error \(errJson)")
            }
            
        }
        
        
    }
    
    
    func loadAgencies( success: @escaping (_ list: Array<Any>) -> Void, error: @escaping (_ list: Array<Any>, _ message: String) -> Void){
        print("entra en loadagencies")
        let n_key = key.md5()
        
        var places: [place] = []
        if !Connectivity.isConnectedToInternet {
            return error( places,"No cuenta con conexión a Internet")
        }
        
        let url_part="action=query&id_query=60"
        let encode = try! url_part.aesEncrypt(key: n_key, iv: iv)
        
        print("codificado: \(encode)")
        
        let jsn_url = url_master + (encode.urlEncode() as String)
        print(jsn_url)
        
        guard let url = try? URL(string: jsn_url) else {
            return error(places, "Error al general la url para cargar agencias")
        }
        
        URLSession.shared.dataTask(with: url!){ (data , response ,err ) in
            
            
            print(data)
            guard let data = data else {return error(places, "data recibida invalida")}
            print("data : \(data.base64EncodedData())")
            
            
            do{
                guard let data_received = String(data: data, encoding: .utf8) else{ return error(places, "data recibida invalida") }
                print("data received: \(data_received)")
                
                let data2 = try! data_received.aesDecrypt(key: n_key, iv: self.iv)
                print("datos decript agencias \(data2)")
                
                let dictionary: Dictionary<NSObject, AnyObject> = try JSONSerialization.jsonObject(with: data2.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<NSObject, AnyObject>
                
                var date_sync = ""
                var list: NSArray = []
                var message = ""
                var err = false
                for (key,value) in dictionary {
                    if key as! String == "sync_date" {
                        date_sync = value as! String
                    }
                    if key as! String == "row"{
                        list = value as! NSArray
                    }
                    
                    if key as! String == "error"{
                        err = true
                        message = value as! String
                    }
                }
                
                if err {
                    return error(places, message)
                }
                
                print(date_sync)
                
                for value in list {
                    let val = value as! NSArray
                    if val[4] as! String != "-"{
                        
                        let place_temp = place.init(name: val[1] as! String, street: val[2] as! String, attention: val[6] as! String, coordinate: CLLocationCoordinate2D(latitude: Double(val[4] as! String)!, longitude: Double(val[5] as! String)!), selected: false, date_sync: date_sync)
                        
                        places.append(place_temp)
                    }
                }
                
                success(places)
                
            }catch let errJson {
                print(errJson)
                error(places, "data recibida invalida")
            }
            }.resume()
        
    }
    
    
    func registerUser(user: Dictionary<String, String>, success: @escaping (_ message: String) -> Void, error: @escaping (_ message: String) -> Void) {
        
        print("entra en register user")
        
        let n_key = key.md5()
        
        var url_part = "action=register"
        for item in user{
            url_part = url_part+"&\(item.key)=\(item.value)"
        }
        print(url_part)
        
        if !Connectivity.isConnectedToInternet {
            return error("No cuenta con conexión a Internet")
        }
        
        let encode = try! url_part.aesEncrypt(key: n_key, iv: iv)
        
        print("codificado: \(encode)")
        
        let jsn_url = url_master + (encode.urlEncode() as String)
        print(jsn_url)
        
        guard var url = try? URLRequest(url: NSURL(string: jsn_url) as! URL) else {
            print("Error al generar la url para registro de usuario")
            return error("Error al generar la url para registro de usuario")
            
        }
        
        //var request = URLRequest(url: url1)
        //url.httpBody = body
        url.httpMethod = "POST"
        let (data, response, err) = URLSession.shared.synchronousDataTask(urlrequest: url)
        if let error2 = err {
            print("Synchronous task ended with error register user: \(error2)")
            return error("Error de comunicación con el servidor. Por favor contacte al administrador del sistema.")
        }
        else {
            print("Synchronous task ended without errors.")
            //print(data)
            guard let data = data else { return error("Error al obtener la data") }
            
            do{
                guard let data_received = String(data: data, encoding: .utf8) else{ return error("Error encodign utf8") }
                print("data received register user: \(data_received)")
                
                let data2 = try! data_received.aesDecrypt(key: n_key, iv: self.iv)
                print("datos decript register user \(data2)")
                
                let dictionary: Dictionary<NSObject, AnyObject> = try JSONSerialization.jsonObject(with: data2.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<NSObject, AnyObject>
                
                var status = 0
                var message = ""
                for (key,value) in dictionary {
                    if key as! String == "status" {
                        status = value as! Int
                    }
                    if key as! String == "error"{
                        message = value as! String
                    }
                }
                
                if status == 1{
                    success("succ")
                }else{
                    error( message )
                }
                
                
            }catch let errJson {
                print(errJson)
                error( "Error \(errJson)")
            }
            
        }
        
        
    }
    
    func reSendEmail(email: String, success: @escaping (_ message: String) -> Void, error: @escaping (_ message: String) -> Void) {
        let n_key = key.md5()
        
        print("Entra en resend email")
        
        let url_part = "action=reSendMail&mail=\(email)"
        print(url_part)
        
        if !Connectivity.isConnectedToInternet {
            return error("No cuenta con conexión a Internet")
        }
        
        let encode = try! url_part.aesEncrypt(key: n_key, iv: iv)
        
        print("codificado: \(encode)")
        
        let jsn_url = url_master + (encode.urlEncode() as String)
        print(jsn_url)
        
        guard var url = try? URLRequest(url: NSURL(string: jsn_url) as! URL) else {
            print("Error al generar la url para reenvio de correo")
            return error("Error al generar la url para reenvio de correo")
            
        }
        
        //var request = URLRequest(url: url1)
        //url.httpBody = body
        url.httpMethod = "POST"
        let (data, response, err) = URLSession.shared.synchronousDataTask(urlrequest: url)
        if let error2 = err {
            print("Synchronous task ended with error resend email: \(error2)")
            return error("Error de comunicación con el servidor. Por favor contacte al administrador del sistema.")
        }
        else {
            print("Synchronous task ended without errors.")
            //print(data)
            guard let data = data else { return error("Error al obtener la data") }
            
            do{
                guard let data_received = String(data: data, encoding: .utf8) else{ return error("Error encodign utf8") }
                print("data received: \(data_received)")
                
                let data2 = try! data_received.aesDecrypt(key: n_key, iv: self.iv)
                print("datos decript reesend email \(data2)")
                
                let dictionary: Dictionary<NSObject, AnyObject> = try JSONSerialization.jsonObject(with: data2.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<NSObject, AnyObject>
                
                var status = 0
                var message = ""
                for (key,value) in dictionary {
                    if key as! String == "status" {
                        status = value as! Int
                    }
                    if key as! String == "error"{
                        message = value as! String
                    }
                }
                
                if status == 1{
                    success("succ")
                }else{
                    error( message )
                }
                
                
            }catch let errJson {
                print(errJson)
                error( "Error \(errJson)")
            }
            
        }
        
        
    }
    
    
    func resetPass(email: String, success: @escaping (_ message: String) -> Void, error: @escaping (_ message: String) -> Void) {
        let n_key = key.md5()
        
        print("entra en reset pass")
        
        let url_part =  "action=resetPass&os_type=2&mail=\(email)"
        print(url_part)
        
        if !Connectivity.isConnectedToInternet {
            return error("No cuenta con conexión a Internet")
        }
        
        let encode = try! url_part.aesEncrypt(key: n_key, iv: iv)
        
        print("codificado: \(encode)")
        
        let jsn_url = url_master + (encode.urlEncode() as String)
        print(jsn_url)
        
        guard var url = try? URLRequest(url: NSURL(string: jsn_url) as! URL) else {
            print("Error al generar la url para cambio de contraseña")
            return error("Error al generar la url para cambio de contraseña")
            
        }
        
        //var request = URLRequest(url: url1)
        //url.httpBody = body
        url.httpMethod = "POST"
        let (data, response, err) = URLSession.shared.synchronousDataTask(urlrequest: url)
        if let error2 = err {
            print("Synchronous task ended with error reset pass: \(error2)")
            return error("Error de comunicación con el servidor. Por favor contacte al administrador del sistema.")
        }
        else {
            print("Synchronous task ended without errors.")
            //print(data)
            guard let data = data else { return error("Error al obtener la data") }
            
            do{
                guard let data_received = String(data: data, encoding: .utf8) else{ return error("Error encodign utf8") }
                print("data received: \(data_received)")
                
                let data2 = try! data_received.aesDecrypt(key: n_key, iv: self.iv)
                print("datos decript resetpass \(data2)")
                
                let dictionary: Dictionary<NSObject, AnyObject> = try JSONSerialization.jsonObject(with: data2.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<NSObject, AnyObject>
                
                var status = 0
                var message = ""
                for (key,value) in dictionary {
                    if key as! String == "status" {
                        status = value as! Int
                    }
                    if key as! String == "error"{
                        message = value as! String
                    }
                }
                
                if status == 1{
                    success("succ")
                }else{
                    error( message)
                }
                
                
            }catch let errJson {
                print(errJson)
                error( "Error \(errJson)")
            }
            
        }
        
        
    }
    
    func searchService(user: String, id: String, service: String , success: @escaping (_ status: Int, _ contratos: [detailContract], _ message: String) -> Void, error: @escaping (_ message: String) -> Void) {
        let n_key = key.md5()
        
        print("entra en search service")
        
        var contratos = [detailContract]()
        let url_part = "action=query&id_query=41&ID=\(id)&CONTRATO=\(service)&id_user=\(user)&os_type=2&TYPE=2&id_ws_soap=8"
        print(url_part)
        
        if !Connectivity.isConnectedToInternet {
            return error("No cuenta con conexión a Internet")
        }
        
        let encode = try! url_part.aesEncrypt(key: n_key, iv: iv)
        
        print("codificado: \(encode)")
        
        let jsn_url = url_master + (encode.urlEncode() as String)
        print(jsn_url)
        
        guard var url = try? URLRequest(url: NSURL(string: jsn_url) as! URL) else {
            print("Error al generar la url  para buscar el servicio")
            return error("Error al generar la url  para buscar el servicio")
            
        }
        
        //var request = URLRequest(url: url1)
        //url.httpBody = body
        url.httpMethod = "POST"
        let (data, response, err) = URLSession.shared.synchronousDataTask(urlrequest: url)
        if let error2 = err {
            print("Synchronous task ended with error serch service: \(error2)")
            return error("Error de comunicación con el servidor. Por favor contacte al administrador del sistema.")
        }
        else {
            print("Synchronous task ended without errors.")
            //print(data)
            guard let data = data else { return error("Error al obtener la data") }
            
            do{
                guard let data_received = String(data: data, encoding: .utf8) else{ return error("Error encodign utf8") }
                print("data received: \(data_received)")
                
                let data2 = try! data_received.aesDecrypt(key: n_key, iv: self.iv)
                print("datos decript searchService \(data2)")
                
                let dictionary: Dictionary<NSObject, AnyObject> = try JSONSerialization.jsonObject(with: data2.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<NSObject, AnyObject>
                
                var list: NSArray = []
                var message = ""
                var status = 1
                for (key,value) in dictionary {
                    if key as! String == "row"{
                        list = value as! NSArray
                    }
                    
                    if key as! String == "error"{
                        message = value as! String
                        status = 0
                    }
                }
                
                
                
                for value in list {
                    let val = value as! NSArray
                    
                    let contrato = detailContract.init(id_cliente: val[0] as! String, id_contrato: val[1] as! String, direccion_tradicional: val[2] as! String, nombre_beneficiario: val[3] as! String, identificacion_benef: val[4] as! String, nombre_propietario: val[5] as! String, identifiacion_propietario: val[6] as! String, id_cliente_propietario: val[7] as! String, factcodi: val[8] as! String, factnufi: val[9] as! String, fecha_emision: val[10] as! String, id_producto: val[11] as! String, fecha_venc_fact: val[12] as! String, numdoc: val[13] as! String, tipodocu: val[14] as! String, rucempresa: val[15] as! String, deuda_pendiente: val[16] as! String, account_with_balance: val[17] as! String, def_balance: val[18] as! String, consumo: val[19] as! String, sbitemtipo: val[20] as! String, sbitem: val[21] as! String, sbserie: val[22] as! String, categoria: val[23] as! String, subcategoria: val[24] as! String, estado_corte: val[25] as! String, ult_fecha_pago: val[26] as! String, id_direccion_contrato: val[27] as! String, address_id: val[28] as! String, telefono: val[29] as! String, status: false)
                    
                    contratos.append(contrato)
                    
                }
                
                success( status, contratos ,message )
                
                
            }catch let errJson {
                print(errJson)
                error( "Error \(errJson)")
            }
            
        }
    }
    
    
    func addService(id: Int,document: String, alias: String, service: String, success: @escaping (_ message: String) -> Void, error: @escaping (_ message: String) -> Void) {
        let n_key = key.md5()
        
        print("entra en add service")
        
        let url_part = "action=addservice&id_user=\(id)&service=\(service)&document=\(document)&alternative=\(alias)&os_type=2"
        print(url_part)
        
        if !Connectivity.isConnectedToInternet {
            return error("No cuenta con conexión a Internet")
        }
        
        let encode = try! url_part.aesEncrypt(key: n_key, iv: iv)
        
        print("codificado: \(encode)")
        
        let jsn_url = url_master + (encode.urlEncode() as String)
        print(jsn_url)
        
        guard var url = try? URLRequest(url: NSURL(string: jsn_url) as! URL) else {
            print("error agregando servicio")
            return error("Error al generar la url para agregar servicio")
            
        }
        
        //var request = URLRequest(url: url1)
        //url.httpBody = body
        url.httpMethod = "POST"
        let (data, response, err) = URLSession.shared.synchronousDataTask(urlrequest: url)
        if let error2 = err {
            print("Synchronous task ended with error add service: \(error2)")
            return error("Error de comunicación con el servidor. Por favor contacte al administrador del sistema.")
        }
        else {
            print("Synchronous task ended without errors.")
            //print(data)
            guard let data = data else { return error("Error al obtener la data") }
            
            do{
                guard let data_received = String(data: data, encoding: .utf8) else{ return error("Error encodign utf8") }
                print("data received: \(data_received)")
                
                let data2 = try! data_received.aesDecrypt(key: n_key, iv: self.iv)
                print("datos decript addservice \(data2)")
                
                let dictionary: Dictionary<NSObject, AnyObject> = try JSONSerialization.jsonObject(with: data2.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<NSObject, AnyObject>
                
                var status = 0
                var message = ""
                var sync_date = ""
                for (key,value) in dictionary {
                    if key as! String == "sync_date"{
                        sync_date = value as! String
                    }
                    if key as! String == "status" {
                        status = value as! Int
                    }
                    if key as! String == "error"{
                        message = value as! String
                    }
                }
                
                if status == 1{
                    success(sync_date)
                }else{
                    error( message )
                }
                
                
            }catch let errJson {
                print(errJson)
                error( "Error \(errJson)")
            }
            
        }
        
        
    }
    
    func updateService(id: Int, alias: String, service: String, success: @escaping (_ message: String) -> Void, error: @escaping (_ message: String) -> Void) {
        let n_key = key.md5()
        
        print("entra en update service")
        
        let url_part = "action=changeAlias&id=\(id)&service=\(service)&alternative=\(alias)&os_type=2"
        print(url_part)
        
        if !Connectivity.isConnectedToInternet {
            return error("No cuenta con conexión a Internet")
        }
        
        let encode = try! url_part.aesEncrypt(key: n_key, iv: iv)
        
        print("codificado: \(encode)")
        
        let jsn_url = url_master + (encode.urlEncode() as String)
        print(jsn_url)
        
        guard var url = try? URLRequest(url: NSURL(string: jsn_url) as! URL) else {
            print("Error al generar la url de actualizacion de servicio")
            return error("Error al generar la url de actualizacion de servicio")
            
        }
        
        //var request = URLRequest(url: url1)
        //url.httpBody = body
        url.httpMethod = "POST"
        let (data, response, err) = URLSession.shared.synchronousDataTask(urlrequest: url)
        if let error2 = err {
            print("Synchronous task ended with error update service: \(error2)")
            return error("Error de comunicación con el servidor. Por favor contacte al administrador del sistema.")
        }
        else {
            print("Synchronous task ended without errors.")
            //print(data)
            guard let data = data else { return error("Error al obtener la data") }
            
            do{
                guard let data_received = String(data: data, encoding: .utf8) else{ return error("Error encodign utf8") }
                print("data received: \(data_received)")
                
                let data2 = try! data_received.aesDecrypt(key: n_key, iv: self.iv)
                print("datos decript update service \(data2)")
                
                let dictionary: Dictionary<NSObject, AnyObject> = try JSONSerialization.jsonObject(with: data2.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<NSObject, AnyObject>
                
                var status = 0
                var message = ""
                var sync_date = ""
                for (key,value) in dictionary {
                    if key as! String == "sync_date"{
                        sync_date = value as! String
                    }
                    if key as! String == "status" {
                        status = value as! Int
                    }
                    if key as! String == "error"{
                        message = value as! String
                    }
                }
                
                if status == 1{
                    return success(sync_date)
                }else{
                    return error( message )
                }
                
                
            }catch let errJson {
                print(errJson)
                error( "Error \(errJson)")
            }
        }
    }
    
    func deleteService(id: Int, service: String, success: @escaping (_ message: String) -> Void, error: @escaping (_ message: String) -> Void) {
        let n_key = key.md5()
        
        print("entra en delete service")
        
        let url_part = "action=deleteservice&id_user=\(id)&service=\(service)&os_type=2"
        print(url_part)
        
        if !Connectivity.isConnectedToInternet {
            return error("No cuenta con conexión a Internet")
        }
        
        let encode = try! url_part.aesEncrypt(key: n_key, iv: iv)
        
        print("codificado: \(encode)")
        
        let jsn_url = url_master + (encode.urlEncode() as String)
        print(jsn_url)
        
        guard var url = try? URLRequest(url: NSURL(string: jsn_url) as! URL) else {
            print("Error al generar la url de eliminacion de servicio")
            return error("Error al generar la url de eliminacion de servicio")
            
        }
        
        //var request = URLRequest(url: url1)
        //url.httpBody = body
        url.httpMethod = "POST"
        let (data, response, err) = URLSession.shared.synchronousDataTask(urlrequest: url)
        if let error2 = err {
            print("Synchronous task ended with error delete service: \(error2)")
            return error("Error de comunicación con el servidor. Por favor contacte al administrador del sistema.")
        }
        else {
            print("Synchronous task ended without errors.")
            //print(data)
            guard let data = data else { return error("Error al obtener la data") }
            
            do{
                guard let data_received = String(data: data, encoding: .utf8) else{ return error("Error encodign utf8") }
                print("data received: \(data_received)")
                
                let data2 = try! data_received.aesDecrypt(key: n_key, iv: self.iv)
                print("datos decript delete service \(data2)")
                
                let dictionary: Dictionary<NSObject, AnyObject> = try JSONSerialization.jsonObject(with: data2.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<NSObject, AnyObject>
                
                var status = 0
                var message = ""
                var sync_date = ""
                for (key,value) in dictionary {
                    if key as! String == "sync_date"{
                        sync_date = value as! String
                    }
                    if key as! String == "status" {
                        status = value as! Int
                    }
                    if key as! String == "error"{
                        message = value as! String
                    }
                }
                
                if status == 1{
                    success(sync_date)
                }else{
                    error( message )
                }
                
                
            }catch let errJson {
                print(errJson)
                error( "Error \(errJson)")
            }
            
        }
        
        
    }
    
    func  sendSuggest(id_user: Int, message: String, success: @escaping (_ message: String) -> Void, error: @escaping (_ message: String) -> Void){
        
        let n_key = key.md5()
        
        print("entra en send suggest")
        
        let url_part = "action=suggestion&os_type=2&msg=\(message)&user=\(id_user)"
        print(url_part)
        
        if !Connectivity.isConnectedToInternet {
            return error("No cuenta con conexión a Internet")
        }
        
        let encode = try! url_part.aesEncrypt(key: n_key, iv: iv)
        
        print("codificado: \(encode)")
        
        let jsn_url = url_master + (encode.urlEncode() as String)
        print(jsn_url)
        
        guard var url = try? URLRequest(url: NSURL(string: jsn_url) as! URL) else {
            print("error generando url para envio de sugerencia")
            return error("Error al generar la url para envio de sugerencia")
            
        }
        
        //var request = URLRequest(url: url1)
        //url.httpBody = body
        url.httpMethod = "POST"
        let (data, response, err) = URLSession.shared.synchronousDataTask(urlrequest: url)
        if let error2 = err {
            print("Synchronous task ended with error send suggest: \(error2)")
            return error("Error de comunicación con el servidor. Por favor contacte al administrador del sistema.")
        }
        else {
            print("Synchronous task ended without errors.")
            //print(data)
            guard let data = data else { return error("Error al obtener la data") }
            
            do{
                guard let data_received = String(data: data, encoding: .utf8) else{ return error("Error encodign utf8") }
                print("data received: \(data_received)")
                
                let data2 = try! data_received.aesDecrypt(key: n_key, iv: self.iv)
                print("datos decript send suggest \(data2)")
                
                let dictionary: Dictionary<NSObject, AnyObject> = try JSONSerialization.jsonObject(with: data2.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<NSObject, AnyObject>
                
                var status = 0
                var message = ""
                var sync_date = ""
                for (key,value) in dictionary {
                    if key as! String == "sync_date"{
                        sync_date = value as! String
                    }
                    if key as! String == "status" {
                        status = value as! Int
                    }
                    if key as! String == "error"{
                        message = value as! String
                    }
                }
                
                if status == -1{
                    error( message )
                }else{
                    success(sync_date)
                    
                }
                
                
            }catch let errJson {
                print(errJson)
                error( "Error \(errJson)")
            }
            
        }
        
    }
    
    
    
}

