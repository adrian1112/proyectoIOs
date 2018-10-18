//
//  NuevoContratoViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 15/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit
import SQLite

class NuevoContratoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    let ws = WService()
    let dbase = DBase();
    var db: Connection!
    
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var number: UITextField!
    
    @IBOutlet weak var err_id: UILabel!
    @IBOutlet weak var err_number: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var aliasText: UITextField!
    
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    
    
    @IBOutlet weak var spin: UIActivityIndicatorView!
    @IBOutlet weak var spinView: UIView!
    
    var user = User.init(id_user: 0, document: "", person: "", email: "", phone: "", sync_date: "", adress: "", status: 1, error: 1)
    
    var contratos = [detailContract]()
    
    var accounts = [account]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let status = dbase.connect_db()
        if( status.value ){
            user = self.dbase.loadUsersDB()
        }
        
        self.spinView.isHidden = true
        
    }
    
    @IBAction func Next(_ sender: UIButton) {
        print("next")
        self.view.endEditing(true)
        
        DispatchQueue.main.async {
            self.spin.startAnimating()
            self.spinView.isHidden = false
        }
        
        
        let cedula = self.id.text?.trimmingCharacters(in: .whitespaces)
        let contrato = self.number.text?.trimmingCharacters(in: .whitespaces)
        let  ok_ced = verificarCedula(cedula: cedula!)
        
        if cedula != "" && contrato != "" && ok_ced{
            
            if user.error == 0 {
                
                DispatchQueue.global(qos: .background).async
                    {
                        self.loadDataTable(cedula: cedula!, contrato: contrato!)
                }
                
            }else{
                self.err_id.text = "Error obteniendo el usuario "
                self.spin.stopAnimating()
                self.spinView.isHidden = true
            }
            
        }else{
            
            if cedula == ""{
                self.err_id.text = "Por favor igrese la cédula o RUC"
            }else if !ok_ced{
                self.err_id.text = "Por favor igrese un número de cédula o RUC correcto"
            }else{
                self.err_id.text = ""
            }
            if contrato == ""{
                self.err_number.text = "Por favor igrese el número de contrato"
            }else{
                self.err_number.text = ""
            }
            
            DispatchQueue.main.async {
                self.spin.stopAnimating()
                self.spinView.isHidden = true
            }
            
        }
    }
    
    func loadDataTable(cedula: String, contrato: String){
        ws.searchService(user: "\(user.id_user)", id: cedula, service: contrato,
                         success: {
                            (status,list_contract,message) -> Void in
                            print("ok service")
                            if status == 1{
                                self.contratos = list_contract
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    
                                    self.view1.isHidden = true
                                    self.view2.isHidden = false
                                    
                                    self.spin.stopAnimating()
                                    self.spinView.isHidden = true
                                    
                                    self.err_number.text = ""
                                    self.err_id.text = ""
                                }
                                
                            }else{
                                //self.ok = false
                                print(message)
                                
                                DispatchQueue.main.async {
                                    self.spin.stopAnimating()
                                    self.spinView.isHidden = true
                                    self.showAlert(message: message)
                                }
                            }
        },
                         error: {
                            (message) -> Void in
                            print("error service: \(message)")
                            DispatchQueue.main.async {
                                self.spin.stopAnimating()
                                self.spinView.isHidden = true
                                self.showAlert(message: message)
                            }
                            
        })
        
        
    }
    
    @IBAction func exit(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    //HABILITA LA OPCION DE OCULTAR EL TECLADO CUANDO SE LE DA EN CUALQUIER PARTE DE LA PANTALLA
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func `return`(_ sender: Any) {
        self.view1.isHidden = false
        self.view2.isHidden = true
        
    }
    
    @IBAction func save(_ sender: Any) {
        print("accion guardar")
        
        DispatchQueue.main.async {
            self.spin.startAnimating()
            self.spinView.isHidden = false
        }
        
        var list_selected = [detailContract]()
        for item in contratos {
            if item.status {
                list_selected.append(item)
            }
        }
        if list_selected.count > 0{
            
            if aliasText.text?.trimmingCharacters(in: .whitespaces) != "" {
                
                for item in list_selected{
                    let id_usuario = self.user.id_user
                    let alias = aliasText.text?.trimmingCharacters(in: .whitespaces)
                    let documento = item.identificacion_benef
                    let num_contrato = item.id_contrato
                    //let now = getDate()
                    //verificar si se encuentra en la base
                    
                    self.accounts = self.dbase.getAccounts()
                    print("cuentas en base antes de agregar: \(self.accounts)")
                    var update = false
                    for item_ac in self.accounts{
                        if item_ac.service == num_contrato{
                            update = true
                        }
                    }
                    
                    if update{
                        print("entra en actualizar servicio")
                        
                        DispatchQueue.global(qos: .background).async
                            {
                                self.ws.updateService(id: id_usuario, alias: alias!, service: num_contrato, success:{
                                    (message) -> Void in
                                    print(message)
                                    
                                    let ok = self.dbase.updateAccount(account: num_contrato, alias: alias!)
                                    if ok{
                                        let ok2 = self.dbase.deleteDetaillsAccount(account: num_contrato)
                                        //vuelve a consultar los detalles de la cuenta actualizada
                                        if ok2{
                                            
                                            let new_account = account.init(service: num_contrato, alias: alias!, document: documento, date_sync: message)
                                            
                                            self.ws.loadCore(id_user: String(describing: self.user.id_user), accounts: [new_account],
                                                             success: {
                                                                (notifications) -> Void in
                                                                print("ok load core")
                                                                
                                                                DispatchQueue.main.async {
                                                                    self.spin.stopAnimating()
                                                                    self.spinView.isHidden = true
                                                                    
                                                                    self.dismiss(animated: true, completion: nil)
                                                                    
                                                                }
                                                                
                                                                
                                            },error: {
                                                (accounts,message) -> Void in
                                                print("error \(message)")
                                                
                                                DispatchQueue.main.async {
                                                    self.spin.stopAnimating()
                                                    self.spinView.isHidden = true
                                                    self.showAlert(message: "\(message) , Contrato \(num_contrato)")
                                                }
                                            })
                                            
                                        }
                                    }
                                    
                                    
                                    
                                }, error:{
                                    (message) -> Void in
                                    print(message)
                                    
                                    DispatchQueue.main.async {
                                        self.spin.stopAnimating()
                                        self.spinView.isHidden = true
                                        self.showAlert(message: "Se produjo un error al cambiar el alias a la cuenta \(num_contrato)")
                                    }
                                    
                                })
                        }
                        
                    }else{
                        print("entra en ingresar servicio")
                        
                        DispatchQueue.global(qos: .background).async
                            {
                                self.ws.addService(id: id_usuario,document: documento, alias: alias!, service: num_contrato, success:{
                                    (message) -> Void in
                                    print(message)
                                    
                                    // agregar la sincronización del core
                                    let new_account = account.init(service: num_contrato, alias: alias!, document: documento, date_sync: message)
                                    
                                    self.dbase.insertAccounts(accounts: [new_account] as! [account])
                                    
                                    self.ws.loadCore(id_user: String(describing: self.user.id_user), accounts: [new_account],
                                                     success: {
                                                        (notifications) -> Void in
                                                        print("ok load core")
                                                        
                                                        DispatchQueue.main.async {
                                                            
                                                            self.spin.stopAnimating()
                                                            self.spinView.isHidden = true
                                                            
                                                            
                                                            self.dismiss(animated: true, completion: nil)
                                                            
                                                        }
                                                        
                                    },error: {
                                        (accounts,message) -> Void in
                                        
                                        print("error \(message)")
                                        
                                        DispatchQueue.main.async {
                                            self.spin.stopAnimating()
                                            self.spinView.isHidden = true
                                            self.showAlert(message: message )
                                        }
                                    })
                                    
                                }, error:{
                                    (message) -> Void in
                                    print(message)
                                    
                                    DispatchQueue.main.async {
                                        self.spin.stopAnimating()
                                        self.spinView.isHidden = true
                                        self.showAlert(message: message )
                                    }
                                })
                        }
                        
                    }
                    
                    print(item)
                    
                    
                }
                
            }else{
                DispatchQueue.main.async {
                    self.spin.stopAnimating()
                    self.spinView.isHidden = true
                }
                showAlert(message: "Por favor ingrese un Alias para el contrato")
            }
        }else{
            DispatchQueue.main.async {
                self.spin.stopAnimating()
                self.spinView.isHidden = true
                self.showAlert(message: "Por favor seleccione un contrato")
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contratos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("customTableTableViewCell5", owner: self, options: nil)?.first as! customTableTableViewCell5
        
        cell.n_contrato.text = self.contratos[indexPath.row].id_contrato
        cell.usuario.text = self.contratos[indexPath.row].nombre_beneficiario
        cell.direccion.text = self.contratos[indexPath.row].direccion_tradicional
        
        if indexPath.row == 0{
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            contratos[indexPath.row].status = true
        }else{
            cell.accessoryType = UITableViewCell.AccessoryType.none
            contratos[indexPath.row].status = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected", indexPath.row)
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
        contratos[indexPath.row].status = !contratos[indexPath.row].status
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //funcion para mostrar alerta
    func showAlert(message: String){
        print("entra a alerta")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert);
        let btn_alert = UIAlertAction(title: "Aceptar", style: .default) { (UIAlertAction) in
            
        }
        
        alert.addAction(btn_alert);
        self.present(alert, animated: true, completion: nil);
    }
    

    

}
