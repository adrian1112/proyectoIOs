//
//  DBase.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 15/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import Foundation
import SQLite
import GoogleMaps

class DBase {
    
    //tabla Usuarios-----------------------------------------------
    let usersT = Table("usuarios")
    let id_usersT = Expression<Int>("id")
    let name_userT = Expression<String>("nombre")
    var email_user_T = Expression<String>("email")
    let identifier_user_T = Expression<String>("cedula")
    let address_user_T = Expression<String>("direccion")
    let telephone_user_T = Expression<String>("telefono")
    let contract_user_T = Expression<String>("contrato")
    let password_user_T = Expression<String>("contrasena")
    
    //tabla usuario logeados--------------------------------------
    let usersLoginT = Table("usuarios_logeados")
    let id_users_l_T = Expression<Int>("id")
    let person_l_T = Expression<String>("persona")
    let document_l_T = Expression<String>("documento")
    let email_l_T = Expression<String>("email")
    let phone_l_T = Expression<String>("telefono")
    let sync_date_l_T = Expression<String>("fecha_ingreso")
    let adress_l_T = Expression<String>("direccion")
    
    //tabla agencias--------------------------------------
    let agenciesT = Table("agencias")
    let name_agenciesT = Expression<String>("nombre")
    let street_agenciesT = Expression<String>("calle")
    let attention_agenciesT = Expression<String>("atencion")
    let latitude_agenciesT = Expression<Double>("latitud")
    let longitude_agenciesT = Expression<Double>("longitud")
    let date_sync_agenciesT = Expression<String>("date_sync")
    
    //tabla notificaciones----------------------------------------------
    let notificationsT = Table("notificaciones")
    let contract_notificationsT = Expression<String>("contrato")
    let type_notificationsT = Expression<String>("tipo")
    let document_code_notificationsT = Expression<String>("cod_documento")
    let message_notificationsT = Expression<String>("mensaje")
    let date_gen_notificationsT = Expression<String>("fecha_generacion")
    let date_sync_notificationsT = Expression<String>("date_sync")
    
    //tabla cuentas----------------------------------------------
    let accountsT = Table("cuentas")
    let service_accountsT = Expression<String>("servicio")
    let alias_accountsT = Expression<String>("nombre")
    let document_accountsT = Expression<String>("documento")
    let date_sync_accountsT = Expression<String>("date_sync")
    
    
    //tabla detalle de cuentas----------------------------------------------
    let detailsAccountT = Table("cuenta_detalle")
    let facturas_vencidas_detailsAccountT = Expression<String>("facturas_vencidas")
    let deuda_diferida_detailsAccountT = Expression<String>("deuda_diferida")
    let max_fecha_pago_detailsAccountT = Expression<String>("max_fecha_pago")
    let tipo_medidor_detailsAccountT = Expression<String>("tipo_medidor")
    let serie_medidor_detailsAccountT = Expression<String>("serie_medidor")
    let consumo_detailsAccountT = Expression<String>("consumo")
    let estado_corte_detailsAccountT = Expression<String>("estado_corte")
    let contrato_detailsAccountT = Expression<String>("contrato")
    let cliente_detailsAccountT = Expression<String>("cliente")
    let uso_servicio_detailsAccountT = Expression<String>("uso_servicio")
    let direccion_detailsAccountT = Expression<String>("direccion")
    let ci_ruc_detailsAccountT = Expression<String>("ci_ruc")
    let id_direccion_detailsAccountT = Expression<String>("id_direccion")
    let id_direccion_contrato_detailsAccountT = Expression<String>("id_direccion_contrato")
    let id_producto_detailsAccountT = Expression<String>("id_producto")
    let id_cliente_detailsAccountT = Expression<String>("id_cliente")
    let deuda_pendiente_detailsAccountT = Expression<String>("deuda_pendiente")
    let servicio_detailsAccountT = Expression<String>("servicio")
    let alias_servicio_detailsAccountT = Expression<String>("alias")
    
    
    // Tabla facturas de contrato --------------------------------------
    let billsAccountT = Table("facturas")
    let cod_factura_billsAccountT = Expression<String>("cod_factura")
    let fecha_emision_billsAccountT = Expression<String>("fecha_emision")
    let fecha_vencimiento_billsAccountT = Expression<String>("fecha_vencimiento")
    let monto_factura_billsAccountT = Expression<String>("monto_factura")
    let saldo_factura_billsAccountT = Expression<String>("saldo_factura")
    let estado_factura_billsAccountT = Expression<String>("estado_factura")
    let consumo_kwh_billsAccountT = Expression<String>("consumo_kwh")
    let lectura_actual_billsAccountT = Expression<String>("lectura_actual")
    let servicio_billsAccountT = Expression<String>("servicio")
    
    // Tabla detalle de deudas --------------------------------------
    let detailDebsT = Table("deudas")
    let nombre_detailDebsT = Expression<String>("nombre")
    let descripcion_detailDebsT = Expression<String>("descripcion")
    let valor_detailDebsT = Expression<String>("valor")
    let servicio_detailDebsT = Expression<String>("servicio")
    
    // Tabla detalle de tramites --------------------------------------
    let detailProcedureT = Table("tramites")
    let codigo_detailProcedureT = Expression<String>("codigo")
    let descripcion_detailProcedureT = Expression<String>("descripcion")
    let fecha_inicio_detailProcedureT = Expression<String>("fecha_inicio")
    let fecha_fin_detailProcedureT = Expression<String>("fecha_fin")
    let estado_detailProcedureT = Expression<String>("estado")
    let json_detailProcedureT = Expression<String>("json")
    let descripcion2_detailProcedureT = Expression<String>("descripcion2")
    let descripcion3_detailProcedureT = Expression<String>("descripcion3")
    let servicio_detailProcedureT = Expression<String>("servicio")
    
    // Tabla detalle de pagos --------------------------------------
    let detailPaymentT = Table("pagos")
    let meses_detailPaymentT = Expression<String>("meses")
    let monto_pago_detailPaymentT = Expression<String>("monto_pago")
    let codigo_pago_detailPaymentT = Expression<String>("codigo_pago")
    let tipo_recaudacion_detailPaymentT = Expression<String>("tipo_recaudacion")
    let fecha_pago_detailPaymentT = Expression<String>("fecha_pago")
    let estado_pago_detailPaymentT = Expression<String>("estado_pago")
    let numero_servicio_detailPaymentT = Expression<String>("numero_servicio")
    let terminal_detailPaymentT = Expression<String>("terminal")
    let sync_date_detailPaymentT = Expression<String>("sync_date")
    let servicio_detailPaymentT = Expression<String>("servicio")
    
    
    
    
    var db: Connection!
    
    //creo conexion a la base
    func connect_db() -> (value:Bool, conec:Connection){
        do{
            let directoryBase = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let file_db = directoryBase.appendingPathComponent("altura").appendingPathExtension("sqlite3")
            
            let database = try Connection(file_db.path)
            self.db = database
            return (true,db)
        }catch{
            print(error)
            return (false,db)
        }
    }
    
    
    func createTables() -> Bool{
        var ok = true
        
        print("Creando tablas ..")
        let createTableUsers = self.usersT.create { (table) in
            table.column(self.id_usersT, primaryKey: .autoincrement)
            table.column(self.name_userT)
            table.column(self.email_user_T, unique: true)
            table.column(self.identifier_user_T)
            table.column(self.address_user_T)
            table.column(self.telephone_user_T)
            table.column(self.contract_user_T)
            table.column(self.password_user_T)
        }
        
        do{
            try self.db.run(createTableUsers)
            print("Tabla creada")
        }catch let Result.error(message, code, statement){
            if( code == 1){
                print("tabla ya existe")
            }else{
                ok = false
                print(" * constraint failed: \(message), in \(String(describing: statement)) , code \(code)")
            }
        }catch{
            ok = false
            print(error)
        }
        
        
        let createTableUsersLogin = self.usersLoginT.create { (table) in
            table.column(self.id_users_l_T)
            table.column(self.person_l_T)
            table.column(self.email_l_T)
            table.column(self.phone_l_T)
            table.column(self.document_l_T)
            table.column(self.sync_date_l_T)
            table.column(self.adress_l_T)
        }
        
        do{
            try self.db.run(createTableUsersLogin)
            print("Tabla creada")
        }catch let Result.error(message, code, statement){
            if( code == 1){
                print("tabla ya existe")
            }else{
                ok = false
                print(" * constraint failed: \(message), in \(String(describing: statement)) , code \(code)")
            }
        }catch{
            ok = false
            print(error)
        }
        
        let createTableAgencies = self.agenciesT.create { (table) in
            table.column(self.name_agenciesT)
            table.column(self.street_agenciesT)
            table.column(self.attention_agenciesT)
            table.column(self.latitude_agenciesT)
            table.column(self.longitude_agenciesT)
            table.column(self.date_sync_agenciesT)
        }
        
        do{
            try self.db.run(createTableAgencies)
            print("Tabla agencias creada")
        }catch let Result.error(message, code, statement){
            if( code == 1){
                print("tabla agencias ya existe")
            }else{
                ok = false
                print(" * constraint failed: \(message), in \(String(describing: statement)) , code \(code)")
            }
        }catch{
            ok = false
            print(error)
        }
        
        let createTableNotifications = self.notificationsT.create { (table) in
            table.column(self.contract_notificationsT)
            table.column(self.type_notificationsT)
            table.column(self.document_code_notificationsT)
            table.column(self.message_notificationsT)
            table.column(self.date_gen_notificationsT)
            table.column(self.date_sync_notificationsT)
        }
        
        do{
            try self.db.run(createTableNotifications)
            print("Tabla notificaciones creada")
        }catch let Result.error(message, code, statement){
            if( code == 1){
                print("tabla notificaciones ya existe")
            }else{
                ok = false
                print(" * constraint failed: \(message), in \(String(describing: statement)) , code \(code)")
            }
        }catch{
            ok = false
            print(error)
        }
        
        let createTableAccounts = self.accountsT.create { (table) in
            table.column(self.service_accountsT)
            table.column(self.alias_accountsT)
            table.column(self.document_accountsT)
            table.column(self.date_sync_accountsT)
        }
        
        do{
            try self.db.run(createTableAccounts)
            print("Tabla cuentas creada")
        }catch let Result.error(message, code, statement){
            if( code == 1){
                print("tabla cuentas ya existe")
            }else{
                ok = false
                print(" * constraint failed: \(message), in \(String(describing: statement)) , code \(code)")
            }
        }catch{
            ok = false
            print(error)
        }
        
        
        let createTableDetailAccount = self.detailsAccountT.create { (table) in
            table.column(self.facturas_vencidas_detailsAccountT)
            table.column(self.deuda_diferida_detailsAccountT)
            table.column(self.max_fecha_pago_detailsAccountT)
            table.column(self.tipo_medidor_detailsAccountT)
            table.column(self.serie_medidor_detailsAccountT)
            table.column(self.consumo_detailsAccountT)
            table.column(self.estado_corte_detailsAccountT)
            table.column(self.contrato_detailsAccountT)
            table.column(self.cliente_detailsAccountT)
            table.column(self.uso_servicio_detailsAccountT)
            table.column(self.direccion_detailsAccountT)
            table.column(self.ci_ruc_detailsAccountT)
            table.column(self.id_direccion_detailsAccountT)
            table.column(self.id_direccion_contrato_detailsAccountT)
            table.column(self.id_producto_detailsAccountT)
            table.column(self.id_cliente_detailsAccountT)
            table.column(self.deuda_pendiente_detailsAccountT)
            table.column(self.servicio_detailsAccountT)
            table.column(self.alias_servicio_detailsAccountT)
            
        }
        
        do{
            try self.db.run(createTableDetailAccount)
            print("Tabla detalle cuentas creada")
        }catch let Result.error(message, code, statement){
            if( code == 1){
                print("tabla detalle cuentas ya existe")
            }else{
                ok = false
                print(" * constraint failed: \(message), in \(String(describing: statement)) , code \(code)")
            }
        }catch{
            ok = false
            print(error)
        }
        
        
        
        // Tabla facturas de contrato --------------------------------------
        let createTablebillsAccountT = self.billsAccountT.create { (table) in
            table.column(self.cod_factura_billsAccountT)
            table.column(self.fecha_emision_billsAccountT)
            table.column(self.fecha_vencimiento_billsAccountT)
            table.column(self.monto_factura_billsAccountT)
            table.column(self.saldo_factura_billsAccountT)
            table.column(self.estado_factura_billsAccountT)
            table.column(self.consumo_kwh_billsAccountT)
            table.column(self.lectura_actual_billsAccountT)
            table.column(self.servicio_billsAccountT)
        }
        
        do{
            try self.db.run(createTablebillsAccountT)
            print("Tabla facturas creada")
        }catch let Result.error(message, code, statement){
            if( code == 1){
                print("tabla facturas ya existe")
            }else{
                ok = false
                print(" * constraint failed: \(message), in \(String(describing: statement)) , code \(code)")
            }
        }catch{
            ok = false
            print(error)
        }
        
        // Tabla detalle de deudas --------------------------------------
        let createTabledetailDebsT = self.detailDebsT.create { (table) in
            table.column(self.nombre_detailDebsT)
            table.column(self.descripcion_detailDebsT)
            table.column(self.valor_detailDebsT)
            table.column(self.servicio_detailDebsT)
        }
        
        do{
            try self.db.run(createTabledetailDebsT)
            print("Tabla deudas creada")
        }catch let Result.error(message, code, statement){
            if( code == 1){
                print("tabla deudas ya existe")
            }else{
                ok = false
                print(" * constraint failed: \(message), in \(String(describing: statement)) , code \(code)")
            }
        }catch{
            ok = false
            print(error)
        }
        
        
        // Tabla detalle de tramites --------------------------------------
        let createTabledetailProcedureT = self.detailProcedureT.create { (table) in
            table.column(self.codigo_detailProcedureT)
            table.column(self.descripcion_detailProcedureT)
            table.column(self.fecha_inicio_detailProcedureT)
            table.column(self.fecha_fin_detailProcedureT)
            table.column(self.estado_detailProcedureT)
            table.column(self.json_detailProcedureT)
            table.column(self.descripcion2_detailProcedureT)
            table.column(self.descripcion3_detailProcedureT)
            table.column(self.servicio_detailProcedureT)
        }
        
        do{
            try self.db.run(createTabledetailProcedureT)
            print("Tabla tramites creada")
        }catch let Result.error(message, code, statement){
            if( code == 1){
                print("tabla tramites ya existe")
            }else{
                ok = false
                print(" * constraint failed: \(message), in \(String(describing: statement)) , code \(code)")
            }
        }catch{
            ok = false
            print(error)
        }
        
        
        // Tabla detalle de pagos --------------------------------------
        let createTabledetailPaymentT = self.detailPaymentT.create { (table) in
            table.column(self.meses_detailPaymentT)
            table.column(self.monto_pago_detailPaymentT)
            table.column(self.codigo_pago_detailPaymentT)
            table.column(self.tipo_recaudacion_detailPaymentT)
            table.column(self.fecha_pago_detailPaymentT)
            table.column(self.estado_pago_detailPaymentT)
            table.column(self.numero_servicio_detailPaymentT)
            table.column(self.terminal_detailPaymentT)
            table.column(self.sync_date_detailPaymentT)
            table.column(self.servicio_detailPaymentT)
        }
        
        do{
            try self.db.run(createTabledetailPaymentT)
            print("Tabla pagos creada")
        }catch let Result.error(message, code, statement){
            if( code == 1){
                print("tabla pagos ya existe")
            }else{
                ok = false
                print(" * constraint failed: \(message), in \(String(describing: statement)) , code \(code)")
            }
        }catch{
            ok = false
            print(error)
        }
        return ok
    }
    
    //Cargar usuario mediante DB
    func loadUsersDB() -> User {
        var user = User.init(id_user: 0, document: "", person: "", email: "", phone: "", sync_date: "", adress: "", status: 1, error: 1);
        
        //let sql = self.usersLoginT.select(id_usersT,name_userT,email_user_T,identifier_user_T,address_user_T,telephone_user_T,contract_user_T,password_user_T).filter(email_user_T == usr)
        let sql = self.usersLoginT.select(id_users_l_T,person_l_T,document_l_T,email_l_T,phone_l_T,sync_date_l_T,adress_l_T)
        
        do{
            let request = Array(try self.db.prepare(sql))
            if(request.count > 0){
                for us in request {
                    do {
                        let date = try us.get(sync_date_l_T)
                        let base_date = getLabelDate(date: date,4)
                        print("fecha_base: \(base_date)")
                        
                        let now = getDate()
                        print("fecha_actual: \(now)")
                        
                        if base_date == now {
                            print("name: \(try us.get(id_users_l_T))")
                            user.id_user = try us.get(id_users_l_T)
                            user.document = try us.get(document_l_T)
                            user.person = try us.get(person_l_T)
                            user.email = try us.get(email_l_T)
                            user.phone = try us.get(phone_l_T)
                            user.sync_date = date
                            user.adress = try us.get(adress_l_T)
                            user.error = 0
                        }
                        
                        
                    } catch {
                        print(error)
                        
                    }
                }
                
                
            }else{
                return user // usuario no existe
            }
            
        }catch{
            print(error)
        }
        
        return user
    }
    
    //inserta en base el usuario logeado
    func insertUserLogin(user_in:User){
        print("entra log")
        print("usuario: \(String(describing: user_in.id_user)) ,email: \(String(describing: user_in.email)), persona: \(String(describing: user_in.person)), fecha: \(String(describing: user_in.sync_date))")
        
        let insertUser_l = usersLoginT.insert(self.id_users_l_T <- user_in.id_user,self.document_l_T <- user_in.document!,self.email_l_T <- user_in.email!, self.person_l_T <- user_in.person, self.sync_date_l_T <- user_in.sync_date, self.phone_l_T <- user_in.phone!, self.adress_l_T <- user_in.adress!)
        do{
            try self.db.run(insertUser_l)
            print("Se ingreso el usuario log correctamente")
        }catch let Result.error(message, code, statement){
            print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
        }catch {
            print(error)
        }
        
        
    }
    
    //imprime todos los usuarios registrados
    func printAllUsers(){
        
        print("muestra todos logins")
        do{
            for user in try db.prepare(usersLoginT) {
                print("id: \(user[id_users_l_T]), email: \(user[email_l_T]), name: \(user[person_l_T]),  date: \(user[sync_date_l_T])")
            }
        }catch{
            print("error whi")
            print(error)
        }
        
        print("muestra todas agencias")
        do{
            for agency in try db.prepare(agenciesT) {
                print("nombre: \(agency[name_agenciesT]), calle: \(agency[street_agenciesT]), atencion: \(agency[attention_agenciesT]),  latitud: \(agency[latitude_agenciesT]), longitud: \(agency[longitude_agenciesT]), date_sync: \(agency[date_sync_agenciesT])")
            }
        }catch{
            print("error whi")
            print(error)
        }
    }
    
    //inserta las agencias obtenidas del ws
    func insertAgencies(places:[place]){
        print("entra insert places")
        
        for placeItem in places{
            let insertagency = agenciesT.insert(self.name_agenciesT <- placeItem.name!,self.street_agenciesT <- placeItem.street!, self.attention_agenciesT <- placeItem.attention!, self.latitude_agenciesT <- placeItem.coordinate.latitude, self.longitude_agenciesT <- placeItem.coordinate.longitude, self.date_sync_agenciesT <- placeItem.date_sync)
            do{
                try self.db.run(insertagency)
                print("Se ingreso la agencia \(String(describing: placeItem.name)) correctamente")
            }catch let Result.error(message, code, statement){
                print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
            }catch {
                print(error)
            }
        }
    }
    
    //inserta las notificaciones obtenidas del ws
    func insertNotifications(notificationsList:[notification]){
        print("entra insert notifications")
        
        for notificationItem in notificationsList{
            
            let insertNotification = notificationsT.insert(self.contract_notificationsT <- notificationItem.contract,self.type_notificationsT <- notificationItem.type, self.document_code_notificationsT <- notificationItem.document_code, self.message_notificationsT <- notificationItem.message, self.date_gen_notificationsT <- notificationItem.date_gen, self.date_sync_notificationsT <- notificationItem.date_sync)
            do{
                try self.db.run(insertNotification)
                print("Se ingreso la notiificacion \(notificationItem.message) correctamente")
            }catch let Result.error(message, code, statement){
                print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
            }catch {
                print(error)
            }
        }
    }
    
    //inserta las cuentas obtenidas del ws
    func insertAccounts(accounts:[account]){
        print("entra insert acoount")
        
        for acountItem in accounts{
            
            let insertaccount = accountsT.insert(self.service_accountsT <- acountItem.service,self.alias_accountsT <- acountItem.alias, self.document_accountsT <- acountItem.document, self.date_sync_accountsT <- acountItem.date_sync)
            do{
                try self.db.run(insertaccount)
                print("Se ingreso la cuenta \(acountItem.alias) correctamente")
            }catch let Result.error(message, code, statement){
                print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
            }catch {
                print(error)
            }
        }
    }
    
    //inserta los detalles de cuentas obtenidas del ws
    func insertDetailsAccounts(list: [detailAccount]){
        print("entra insert  detailsacoount")
        
        for item in list{
            
            let insertItem = detailsAccountT.insert(self.facturas_vencidas_detailsAccountT <- item.facturas_vencidas,self.deuda_diferida_detailsAccountT <- item.deuda_diferida, self.max_fecha_pago_detailsAccountT <- item.max_fecha_pago, self.tipo_medidor_detailsAccountT <- item.tipo_medidor
                , self.serie_medidor_detailsAccountT <- item.serie_medidor
                , self.consumo_detailsAccountT <- item.consumo
                , self.estado_corte_detailsAccountT <- item.estado_corte
                , self.contrato_detailsAccountT <- item.contrato
                , self.cliente_detailsAccountT <- item.cliente
                , self.uso_servicio_detailsAccountT <- item.uso_servicio
                , self.direccion_detailsAccountT <- item.direccion
                , self.ci_ruc_detailsAccountT <- item.ci_ruc
                , self.id_direccion_detailsAccountT <- item.id_direccion
                , self.id_direccion_contrato_detailsAccountT <- item.id_direccion_contrato
                , self.id_producto_detailsAccountT <- item.id_producto
                , self.id_cliente_detailsAccountT <- item.id_cliente
                , self.deuda_pendiente_detailsAccountT <- item.deuda_pendiente
                , self.servicio_detailsAccountT <- item.servicio
                , self.alias_servicio_detailsAccountT <- item.alias)
            do{
                try self.db.run(insertItem)
                print("Se ingreso el detalle de cuenta \(item.facturas_vencidas) correctamente")
            }catch let Result.error(message, code, statement){
                print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
            }catch {
                print(error)
            }
        }
    }
    
    
    
    //inserta las facturas obtenidas del ws
    func insertBillsAccount(list: [billsAccount]){
        print("entra insert billsAccount")
        
        for item in list{
            let insert_item = billsAccountT.insert(self.cod_factura_billsAccountT <- item.codigo_factura,self.fecha_emision_billsAccountT <- item.fecha_emision, self.fecha_vencimiento_billsAccountT <- item.fecha_vencimiento, self.monto_factura_billsAccountT <- item.monto_factura, self.saldo_factura_billsAccountT <- item.saldo_factura, self.estado_factura_billsAccountT <- item.estado_factura , self.consumo_kwh_billsAccountT <- item.consumo_kwh , self.lectura_actual_billsAccountT <- item.lectura_actual , self.servicio_billsAccountT <- item.servicio)
            do{
                try self.db.run(insert_item)
                print("Se ingreso la deuda \(item.codigo_factura) correctamente")
            }catch let Result.error(message, code, statement){
                print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
            }catch {
                print(error)
            }
        }
    }
    
    
    //inserta las deudas obtenidas del ws
    func insertDebs(list: [detailDebs]){
        print("entra insert detailDebs")
        
        for item in list{
            let insert_item = detailDebsT.insert(self.nombre_detailDebsT <- item.nombre,self.descripcion_detailDebsT <- item.descripcion, self.valor_detailDebsT <- item.valor, self.servicio_detailDebsT <- item.servicio)
            do{
                try self.db.run(insert_item)
                print("Se ingreso la deuda \(item.nombre) correctamente")
            }catch let Result.error(message, code, statement){
                print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
            }catch {
                print(error)
            }
        }
    }
    
    
    //inserta los tramites obtenidos del ws
    func insertDetailProcedure(list: [detailProcedure]){
        print("entra insert detailProcedure")
        
        for item in list{
            let insert_item = detailProcedureT.insert(self.codigo_detailProcedureT <- item.codigo,self.descripcion_detailProcedureT <- item.descripcion, self.fecha_inicio_detailProcedureT <- item.fecha_inicio, self.fecha_fin_detailProcedureT <- item.fecha_fin, self.estado_detailProcedureT <- item.estado, self.json_detailProcedureT <- item.json , self.descripcion2_detailProcedureT <- item.descripcion2 , self.descripcion3_detailProcedureT <- item.descripcion3 , self.servicio_billsAccountT <- item.servicio)
            do{
                try self.db.run(insert_item)
                print("Se ingreso el tramite \(item.codigo) correctamente")
            }catch let Result.error(message, code, statement){
                print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
            }catch {
                print(error)
            }
        }
    }
    
    
    //inserta los pagos obtenidas del ws
    func insertDetailPaymentT(list: [detailPayment]){
        print("entra insert detailPayment")
        
        for item in list{
            let insert_item = detailPaymentT.insert(self.meses_detailPaymentT <- item.meses,self.monto_pago_detailPaymentT <- item.monto_pago, self.codigo_pago_detailPaymentT <- item.codigo_pago, self.tipo_recaudacion_detailPaymentT <- item.tipo_recaudacion, self.fecha_pago_detailPaymentT <- item.fecha_pago, self.estado_pago_detailPaymentT <- item.estado_pago , self.numero_servicio_detailPaymentT <- item.numero_servicio , self.terminal_detailPaymentT <- item.terminal , self.sync_date_detailPaymentT <- item.sync_date, self.servicio_billsAccountT <- item.servicio)
            do{
                try self.db.run(insert_item)
                print("Se ingreso el pago \(item.codigo_pago) correctamente")
            }catch let Result.error(message, code, statement){
                print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
            }catch {
                print(error)
            }
        }
    }
    
    //imprime todos los usuarios registrados
    func getAgencies() -> [place]{
        print("consulta de agencias")
        var places:[place] = []
        do{
            for agency in try db.prepare(agenciesT) {
                places.append( place.init(name: agency[name_agenciesT], street: agency[street_agenciesT], attention: agency[attention_agenciesT], coordinate: CLLocationCoordinate2D(latitude: agency[latitude_agenciesT], longitude: agency[longitude_agenciesT]), selected: false, date_sync: agency[date_sync_agenciesT]))
            }
        }catch{
            print("error get places")
            print(error)
        }
        return places
    }
    
    //devuelve todos los contratos registrados
    func getAccounts() -> [account]{
        print("get de account")
        var List:[account] = []
        do{
            
            for item in try db.prepare(accountsT) {
                List.append( account.init(service: item[service_accountsT]
                    , alias: item[alias_accountsT]
                    , document: item[document_accountsT]
                    , date_sync: item[date_sync_accountsT]))
            }
        }catch{
            print("error get account")
            print(error)
        }
        return List
    }
    
    // actualiza un contrato de la base
    func updateAccount(account: String, alias: String) -> Bool{
        print("update de account")
        
        do{
            
            let account_item = accountsT.filter(service_accountsT == account)
            try db.run(account_item.update(alias_accountsT <- alias))
            
            return true
            
        }catch{
            print("error update account")
            print(error)
            
        }
        return false
    }
    
    // elimina detalles de un contrato de la base
    func deleteDetaillsAccount(account: String) -> Bool{
        print("delete details de account")
        
        do{
            try self.db.execute("DELETE FROM cuenta_detalle where servicio = \(account);")
            try self.db.execute("DELETE FROM facturas where servicio = \(account);")
            try self.db.execute("DELETE FROM deudas where servicio = \(account);")
            try self.db.execute("DELETE FROM tramites where servicio = \(account);")
            try self.db.execute("DELETE FROM pagos where servicio = \(account);")
            
            print("Se elimino los registros de la cuenta")
            
            return true
            
        }catch let Result.error(message, code, statement){
            print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
        }catch {
            print(error)
        }
        return false
    }
    
    // elimina detalles de un contrato de la base
    func deleteAccount(account: String) -> Bool{
        print("delete details de account")
        
        do{
            try self.db.execute("DELETE FROM cuentas where servicio = \(account);")
            
            print("Se elimino el registro de la cuenta")
            
            return true
            
        }catch let Result.error(message, code, statement){
            print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
        }catch {
            print(error)
        }
        return false
    }
    
    //obtiene todos los detalles de cuentas registrados en la DB
    func getAllDetailsAccounts()-> [detailAccount]{
        print("get detalle cuentas")
        
        var List:[detailAccount] = []
        
        do{
            
            for item in try db.prepare(detailsAccountT) {
                
                List.append( detailAccount.init(facturas_vencidas: item[facturas_vencidas_detailsAccountT]
                    , deuda_diferida: item[deuda_diferida_detailsAccountT]
                    , max_fecha_pago: item[max_fecha_pago_detailsAccountT]
                    , tipo_medidor: item[tipo_medidor_detailsAccountT]
                    , serie_medidor: item[serie_medidor_detailsAccountT]
                    , consumo: item[consumo_detailsAccountT]
                    , estado_corte: item[estado_corte_detailsAccountT]
                    , contrato: item[contrato_detailsAccountT]
                    , cliente: item[cliente_detailsAccountT]
                    , uso_servicio: item[uso_servicio_detailsAccountT]
                    , direccion: item[direccion_detailsAccountT]
                    , ci_ruc: item[ci_ruc_detailsAccountT]
                    , id_direccion: item[id_direccion_detailsAccountT]
                    , id_direccion_contrato: item[id_direccion_contrato_detailsAccountT]
                    , id_producto: item[id_producto_detailsAccountT]
                    , id_cliente: item[id_cliente_detailsAccountT]
                    , deuda_pendiente: item[deuda_pendiente_detailsAccountT]
                    , servicio: item[servicio_detailsAccountT]
                    , alias: item[alias_servicio_detailsAccountT]))
                
            }
        }catch{
            print("error get detail cuentas")
            print(error)
        }
        return List
    }
    
    //devuelve los detalles de deudas de un contrato en especifico
    func getDetailDebs(service: String) -> [detailDebs]{
        print("get detalle deudas")
        
        var List:[detailDebs] = []
        
        do{
            for item in try db.prepare(detailDebsT) {
                if( item[servicio_detailDebsT] == service){
                    List.append(detailDebs.init(nombre: item[nombre_detailDebsT], descripcion: item[descripcion_detailDebsT], valor: item[valor_detailDebsT], servicio: item[servicio_detailDebsT]))
                }
                
            }
            
        }catch{
            print("error get detail debs")
            print(error)
        }
        
        return List
    }
    
    
    
    func getBillsAccount(service: String)-> [billsAccount]{
        print("entra get billsAccount")
        
        var List:[billsAccount] = []
        
        do{
            for item in try db.prepare(billsAccountT) {
                if( item[servicio_billsAccountT] == service){
                    List.append(billsAccount.init(codigo_factura: item[cod_factura_billsAccountT], fecha_emision: item[fecha_emision_billsAccountT], fecha_vencimiento: item[fecha_vencimiento_billsAccountT], monto_factura: item[monto_factura_billsAccountT], saldo_factura: item[saldo_factura_billsAccountT], estado_factura: item[estado_factura_billsAccountT], consumo_kwh: item[consumo_kwh_billsAccountT], lectura_actual: item[lectura_actual_billsAccountT], servicio: item[servicio_billsAccountT]))
                }
            }
            
        }catch{
            print("error get billsAccount")
            print(error)
        }
        return List
    }
    
    func getAllBillsAccount()-> [billsAccount]{
        print("entra get billsAccount")
        
        var List:[billsAccount] = []
        
        do{
            for item in try db.prepare(billsAccountT) {
                
                List.append(billsAccount.init(codigo_factura: item[cod_factura_billsAccountT], fecha_emision: item[fecha_emision_billsAccountT], fecha_vencimiento: item[fecha_vencimiento_billsAccountT], monto_factura: item[monto_factura_billsAccountT], saldo_factura: item[saldo_factura_billsAccountT], estado_factura: item[estado_factura_billsAccountT], consumo_kwh: item[consumo_kwh_billsAccountT], lectura_actual: item[lectura_actual_billsAccountT], servicio: item[servicio_billsAccountT]))
                
            }
            
        }catch{
            print("error get billsAccount")
            print(error)
        }
        return List
    }
    
    func getDetailPaymentT(service: String)-> [detailPayment]{
        print("entra get detailPayment")
        var List:[detailPayment] = []
        
        do{
            for item in try db.prepare(detailPaymentT) {
                if( item[servicio_detailPaymentT] == service){
                    List.append(detailPayment.init(meses: item[meses_detailPaymentT], monto_pago: item[monto_pago_detailPaymentT], codigo_pago: item[codigo_pago_detailPaymentT], tipo_recaudacion: item[tipo_recaudacion_detailPaymentT], fecha_pago: item[fecha_pago_detailPaymentT], estado_pago: item[estado_pago_detailPaymentT], numero_servicio: item[numero_servicio_detailPaymentT], terminal: item[terminal_detailPaymentT], sync_date: item[sync_date_detailPaymentT], servicio: item[servicio_billsAccountT]))
                }
            }
            
        }catch{
            print("error get detailPayment")
            print(error)
        }
        return List
    }
    
    //devuelve todos los tramites de las cuentas registradas
    func getDetailsProcedures(service: String)-> [detailProcedure]{
        print("entra get getDetailsProcedures")
        var List:[detailProcedure] = []
        
        do{
            for item in try db.prepare(detailProcedureT) {
                if( item[servicio_billsAccountT] == service){
                    List.append(detailProcedure.init(codigo: item[codigo_detailProcedureT], descripcion: item[descripcion_detailProcedureT], fecha_inicio: item[fecha_inicio_detailProcedureT], fecha_fin: item[fecha_fin_detailProcedureT], estado: item[estado_detailProcedureT], json: item[json_detailProcedureT], descripcion2: item[descripcion2_detailProcedureT], descripcion3: item[descripcion3_detailProcedureT], servicio: item[servicio_billsAccountT]))
                }
            }
            
        }catch{
            print("error get detailPayment")
            print(error)
        }
        return List
    }
    
    //devuelve las notificaciones de la base
    func getNotifications() -> [notification]{
        print("entra get notifications")
        var List:[notification] = []
        
        do{
            for item in try db.prepare(notificationsT) {
                
                List.append(notification.init(contract: item[contract_notificationsT], type: item[type_notificationsT], document_code: item[document_code_notificationsT], message: item[message_notificationsT], date_gen: item[date_gen_notificationsT], date_sync: item[date_sync_notificationsT]))
            }
            
        }catch{
            print("error get notifications")
            print(error)
        }
        
        return List
    }
    
    func encerarTables()->Bool{
        
        do{
            try db.execute("DELETE FROM agencias;")
            try db.execute("DELETE FROM notificaciones;")
            try db.execute("DELETE FROM cuentas;")
            try db.execute("DELETE FROM cuenta_detalle;")
            try db.execute("DELETE FROM facturas;")
            try db.execute("DELETE FROM deudas;")
            try db.execute("DELETE FROM tramites;")
            try db.execute("DELETE FROM pagos;")
            try db.execute("DELETE FROM usuarios_logeados;")
            print("Se vacio las tablas")
        }catch let Result.error(message, code, statement){
            print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
            return false
        }catch {
            print(error)
            return false
        }
        
        return true
    }
    
    
}

