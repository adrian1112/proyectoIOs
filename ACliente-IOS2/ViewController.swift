//
//  ViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 12/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit
import SQLite
import CryptoSwift
import UserNotifications

class ViewController: UIViewController {

    let ws = WService();
    let dbase = DBase();
    var db: Connection!
    
    @IBOutlet weak var midView: UIView!
    @IBOutlet weak var mid2View: UIView!
    
    @IBOutlet weak var user_txt: UITextField!
    @IBOutlet weak var pass_txt: UITextField!
    @IBOutlet weak var btn_ini: UIButton!
    @IBOutlet weak var btn_reg: UIButton!
    
    
    @IBOutlet weak var indicadorView: UIView!
    @IBOutlet weak var spin: UIActivityIndicatorView!
    @IBOutlet weak var text_spin: UILabel!
    
    @IBOutlet weak var labelVersion: UILabel!
    
    var txt_alert=""
    var title_msg=""
    var title_btn="Reintentar"
    
    var re_confirm = false
    let status: Bool = false
    
    
    var complete = false
    var error = true
    
    
    
    var user_in = User(id_user: 0, document: "", person: "", email: "", phone: "", sync_date: "", adress: "", status: 1, error: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.labelVersion.text = "Versión \(version)"
        }
        
        let status = dbase.connect_db()
        if( status.value ){
            self.db = status.conec;
            
            let status_t = dbase.createTables()
            if(status_t){
                self.btn_ini.isEnabled = true
                self.btn_reg.isEnabled = true
                dbase.printAllUsers()
                print("Tablas creadas correctamente")
                
                let user_temp = dbase.loadUsersDB()
                print("usuario temporal \(user_temp)")
                if user_temp.error == 1 {
                    
                    self.midView.isHidden = false
                    self.mid2View.isHidden = true
                    
                    ws.loadAgencies(success: {
                        (agencies) -> Void in
                        
                        do{
                            try self.db.execute("DELETE FROM agencias;")
                            try self.db.execute("DELETE FROM notificaciones;")
                            try self.db.execute("DELETE FROM cuentas;")
                            try self.db.execute("DELETE FROM cuenta_detalle;")
                            try self.db.execute("DELETE FROM facturas;")
                            try self.db.execute("DELETE FROM deudas;")
                            try self.db.execute("DELETE FROM tramites;")
                            try self.db.execute("DELETE FROM pagos;")
                            print("Se vacio la tabla agenicas correctamente")
                        }catch let Result.error(message, code, statement){
                            print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
                        }catch {
                            print(error)
                        }
                        
                        self.dbase.insertAgencies(places: agencies as! [place])
                        print("se inserto correctamente las agencias")
                    }, error: {
                        (agencies,message) -> Void in
                        print("devolvio null en las agencias")
                    })
                }else{
                    
                    self.midView.isHidden = true
                    self.mid2View.isHidden = false
                    
                }
                
                
            }else{
                self.midView.isHidden = false
                self.mid2View.isHidden = true
                self.btn_ini.isEnabled = false
                self.btn_reg.isEnabled = false
                print("Error creando tablas")
            }
        }else{
            self.midView.isHidden = false
            self.mid2View.isHidden = true
            self.btn_ini.isEnabled = false
            self.btn_reg.isEnabled = false
            print("No se pudo conectar a la base")
        }
        
        
        indicadorView.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func IniciarSesion(_ sender: Any) {
        
        self.view.endEditing(true)
        let user_name = user_txt.text!.trimmingCharacters(in: .whitespaces)
        let pass = pass_txt.text!
        print(user_name,pass)
        
        var internet = false
        if Connectivity.isConnectedToInternet {
            print("Connected")
            internet = true
            
        } else {
            print("No Internet")
            let alert = UIAlertController(title: nil, message: "No tiene acceso a Internet", preferredStyle: .alert);
            let btn_alert = UIAlertAction(title: "Cerrar", style: .default) { (UIAlertAction) in
            }
            alert.addAction(btn_alert);
            self.present(alert, animated: true, completion: nil);
        }
        
        if(user_name != "" && pass != "" && internet){
            self.indicadorView.isHidden = false
            self.spin.startAnimating();
            
            print("usuario: \(user_name) , contraseña: \(pass)")
            
            
            self.complete = false
            self.error = true
            
            ws.loadUser(usr_id: user_name, pass: pass, success: {
                (value,user) -> Void in
                DispatchQueue.main.async {
                    print("entra en success: \(value) , \(user)")
                    self.user_in = user
                    self.user_in.email = user_name
                    
                    self.syncAllDataInit()
                }
            }, error: {
                (value,user) -> Void in
                DispatchQueue.main.async {
                    self.spin.stopAnimating()
                    self.indicadorView.isHidden = true
                    
                    print("entra en error: \(value) , \(user)")
                    if(value == 2){
                        self.txt_alert = "Falta de confirmar su cuenta de correo electrónico, desea reenviar el correo de confirmación?"
                        self.re_confirm = true
                        
                    }else if( value == 3){
                        self.txt_alert = "Usuario no registrado"
                        self.re_confirm = false
                    }else{
                        self.txt_alert = "Usuario o Contraseña Inválidos"
                        self.re_confirm = false
                    }
                    //self.error = true
                    //self.complete = true
                    print("sale en error: \(value) , \(user)")
                    print("entra en alerta")
                    self.showAlert()
                }
                
            })
            
        }

    }
    
    func syncAllDataInit(){
        
        self.ws.loadNotifications(id_user: String(describing: self.user_in.id_user), date: self.user_in.sync_date,
                                  success: {
                                    (notifications) -> Void in
                                    print("ok notificacion")
                                    self.text_spin.text = " Procesando Datos: Notificaciones"
                                    DispatchQueue.main.async {
                                        self.dbase.insertNotifications(notificationsList: notifications as! [notification])
                                    }
        },error: {
            (accounts,message) -> Void in
            self.txt_alert = message;
            self.showAlert();
        })
        
        self.ws.loadAcounts(id_user: String(describing: self.user_in.id_user), date: self.user_in.sync_date,
                            success: {
                                (accounts) -> Void in
                                
                                let acccounts_list = accounts as! [account]
                                var cuentas = ""
                                for item in acccounts_list {
                                    cuentas = "\(cuentas) - \(item.alias)"
                                }
                                
                                self.text_spin.text = " Procesando Datos: Cuentas \(cuentas)"
                                DispatchQueue.main.async {
                                    self.dbase.insertAccounts(accounts: acccounts_list)
                                    
                                    self.syncAllDataCore(accounts: acccounts_list)
                                }
                                
        },error: {
            (accounts,message) -> Void in
            self.spin.stopAnimating()
            self.indicadorView.isHidden = true
            self.txt_alert = message;
            self.showAlert();
        })
        
    }
    
    func syncAllDataCore( accounts: [account]){
        self.ws.loadCore(id_user: String(describing: self.user_in.id_user), accounts: accounts,
                         success: {
                            (notifications) -> Void in
                            print("ok load core")
                            self.spin.stopAnimating()
                            self.indicadorView.isHidden = true
                            
                            self.dbase.insertUserLogin(user_in: self.user_in)
                            
                            DispatchQueue.main.async {
                                self.midView.isHidden = true
                                self.mid2View.isHidden = false
                                self.setValues()
                                self.navigateToApp()
                            }
                            
                            
        },error: {
            (accounts,message) -> Void in
            self.spin.stopAnimating()
            self.indicadorView.isHidden = true
            
            self.txt_alert = message;
            
            do{
                try self.db.execute("DELETE FROM usuarios_logeados;")
                try self.db.execute("DELETE FROM notificaciones;")
                try self.db.execute("DELETE FROM cuentas;")
                try self.db.execute("DELETE FROM cuenta_detalle;")
                try self.db.execute("DELETE FROM facturas;")
                try self.db.execute("DELETE FROM deudas;")
                try self.db.execute("DELETE FROM tramites;")
                try self.db.execute("DELETE FROM pagos;")
                print("Se vacio la tabla agenicas correctamente")
            }catch let Result.error(message, code, statement){
                print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
            }catch {
                print(error)
            }
            
            self.showAlert();
            
        })
        
    }
    
    @IBAction func salir(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: "Seguro que desea Cerrar Sesión?", preferredStyle: .alert);
        let btn_alert = UIAlertAction(title: "Aceptar", style: .default) { (UIAlertAction) in
            
            
            let status = self.dbase.encerarTables()
            if status{ print("ok")}else{print("error encerando")}
            
            self.midView.isHidden = false
            self.mid2View.isHidden = true
        }
        let btn_cancel = UIAlertAction(title: "Cancelar", style: .destructive) { (UIAlertAction) in
            
        }
        alert.addAction(btn_alert);
        alert.addAction(btn_cancel);
        self.present(alert, animated: true, completion: nil);
        
        
    }
    
    @IBAction func accederServicios(_ sender: Any) {
        
        print("entra en servicios")
        navigateToApp()
    }
    
    @IBAction func registrar(_ sender: Any) {
        print("entra en registrar")
    }
    
    @IBAction func recuperarContrasenia(_ sender: Any) {
        let email = user_txt.text?.trimmingCharacters(in: .whitespaces);
        let ok = isValidEmail(string: email!)
        
        var internet = false
        if Connectivity.isConnectedToInternet {
            print("Connected")
            internet = true
            
        } else {
            print("No Internet")
            let alert = UIAlertController(title: nil, message: "No tiene acceso a Internet", preferredStyle: .alert);
            let btn_alert = UIAlertAction(title: "Cerrar", style: .default) { (UIAlertAction) in
            }
            alert.addAction(btn_alert);
            self.present(alert, animated: true, completion: nil);
        }
        
        if email != "" && internet{
            if ok{
                
                self.ws.resetPass(email: email!, success: {
                    (message) -> Void in
                    
                    print("ok : \(message)")
                    self.title_msg = "Confirmación"
                    self.txt_alert = "Por favor revise el buzón de su correo electrónico, su contraseña fue enviada exitosamente";
                    self.title_btn="Aceptar"
                    self.showAlert()
                    self.title_msg = ""
                    self.title_btn="Reintentar"
                    
                }, error: {
                    (message) -> Void in
                    
                    print("erro : \(message)")
                    self.title_msg = "Hubo un problema"
                    self.txt_alert = message;
                    self.showAlert()
                    self.title_msg = ""
                    
                    
                })
                
            }else{
                
                self.txt_alert = "Por favor, ingrese un correo electrónico válido";
                self.showAlert();
            }
            
        }else{
            self.title_msg = "Ingrese su correo electrónico"
            self.txt_alert = "Para recuperar su contraseña es necesario que se ingrese el correo electrónico de su cuenta";
            self.showAlert()
            self.title_msg = ""
        }
    }
    
    private func navigateToApp(){
        let mainTabViewController = self.storyboard?.instantiateViewController(withIdentifier: "mainTabViewController") as! mainTabViewController
        self.present(mainTabViewController, animated: true, completion: nil)
    }

    @IBAction func verAgencias(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomMapViewController") as! CustomMapViewController
        self.present(viewController, animated: true)
    }
    
    @IBAction func puntosRecaudo(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomCollectionViewController") as! CustomCollectionViewController
        self.present(viewController, animated: true)
        
    }
    
    @IBAction func callCenter(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
        self.present(viewController, animated: true)
    }
    
    @IBAction func yoReporto(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "YoReportoViewController") as! YoReportoViewController
        self.present(viewController, animated: true)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //funcion para mostrar alerta
    func showAlert(){
        print("entra a alerta")
        let alert = UIAlertController(title: self.title_msg, message: self.txt_alert, preferredStyle: .alert);
        let btn_alert = UIAlertAction(title: self.title_btn, style: .default) { (UIAlertAction) in
            self.setValues()
        }
        let btn_acept = UIAlertAction(title: "Aceptar", style: .default) { (UIAlertAction) in
            
            self.ws.reSendEmail(email: self.user_txt.text!,
                                success: {
                                    (message) -> Void in
                                    print(message)
                                    self.title_msg = "Confirmación"
                                    self.txt_alert = "Se reenvio el correo de confirmación. Por favor ingrese a su correo y active su cuenta para tener acceso a la aplicación"
                                    self.title_btn="Aceptar"
                                    self.re_confirm = false
                                    self.showAlert()
                                    self.title_msg = ""
                                    self.title_btn="Reintentar"
                                    self.setValues()
                                    
            },error: {
                (message) -> Void in
                print(message)
                self.title_msg = "Hubo un problema"
                self.txt_alert = message
                self.re_confirm = false
                self.showAlert()
                self.title_msg = ""
                
            })
            
            print("reenvio de correo")
        }
        let btn_cancel = UIAlertAction(title: "Cancelar", style: .destructive) { (UIAlertAction) in
            self.setValues()
        }
        
        if re_confirm {
            alert.addAction(btn_cancel);
            alert.addAction(btn_acept);
        }else{
            alert.addAction(btn_alert);
        }
        
        self.present(alert, animated: true, completion: nil);
    }
    
    func setValues(){
        self.pass_txt.text = ""
    }
}

