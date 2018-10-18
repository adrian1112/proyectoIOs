//
//  RegistroSecViewController.swift
//  
//
//  Created by adrian aguilar on 16/10/18.
//

import UIKit
import WebKit

class RegistroSecViewController: UIViewController {

    let ws = WService();
    
    
    @IBOutlet weak var contract_txt: UITextField!
    @IBOutlet weak var names_txt: UITextField!
    @IBOutlet weak var address_txt: UITextField!
    @IBOutlet weak var telephone_txt: UITextField!
    
    @IBOutlet weak var acept_term_select: UISwitch!
    @IBOutlet weak var send_data_select: UISwitch!
    
    @IBOutlet weak var send: UIButton!
    
    
    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var termspage: WKWebView!
    @IBOutlet weak var btnterms: UIButton!
    
    var txt_alert=""
    
    var identifier = ""
    var email = ""
    var pass = ""
    var contract = ""
    var names = ""
    var address = ""
    var telephone = ""
    
    
    let url = "https://www.google.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("second")
        contract_txt.text = self.contract
        names_txt.text = self.names
        address_txt.text = self.address
        telephone_txt.text = self.telephone
        
        
        
        self.termsView.isHidden = true
        let url_page = URL(string: self.url)
        let request = URLRequest(url: url_page!)
        termspage.load(request)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "register" {
            let registro = segue.destination as! RegistroInicialViewController
            registro.identifier = self.identifier
            registro.email = self.email
            registro.pass = self.pass
            registro.contract = self.contract_txt.text!
            registro.names = self.names_txt.text!
            registro.address = self.address_txt.text!
            registro.telephone = self.telephone_txt.text!
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func registerUser(_ sender: Any) {
        
        let identifier = self.identifier
        let email = self.email.trimmingCharacters(in: .whitespaces)
        let pass = self.pass
        let contract = self.contract_txt.text!
        let names = self.names_txt.text!
        let address = self.address_txt.text!
        let telephone = self.telephone_txt.text!
        
        let myColor = UIColor.red
        var texto = "* "
        
        if(names == "" ){
            self.names_txt.layer.borderColor = myColor.cgColor
            self.names_txt.layer.borderWidth = 1.0
        }else{
            self.names_txt.layer.borderWidth = 0
        }
        
        var term_ok = false
        if send_data_select.isOn && acept_term_select.isOn{
            term_ok = true
            self.send_data_select.layer.borderWidth = 0
            self.acept_term_select.layer.borderWidth = 0
        }else{
            if !send_data_select.isOn {
                self.send_data_select.layer.borderColor = myColor.cgColor
                self.send_data_select.layer.borderWidth = 1.0
            }else{
                self.send_data_select.layer.borderWidth = 0
            }
            if !acept_term_select.isOn {
                self.acept_term_select.layer.borderColor = myColor.cgColor
                self.acept_term_select.layer.borderWidth = 1.0
            }else{
                self.acept_term_select.layer.borderWidth = 0
            }
            
        }
        
        if( names != "" && term_ok){
            
            let imei = UserDefaults.standard.object(forKey: "token") != nil ? UserDefaults.standard.object(forKey: "token") as! String : ""
            
            let document = ["document" : identifier,
                            "mail" : email,
                            "pass" : pass,
                            "phone" : telephone,
                            "imei" : imei,
                            "person" : names,
                            "adress" : address,
                            "service" : contract]
            
            ws.registerUser(user: document, success:{
                (message) -> Void in
                print(message)
                self.txt_alert = "Ya estas a un paso de completar el registro, INTERAGUA enviará un correo electrónico para que puedas activar tu cuenta"
                self.showAlert(status: 1)
                
            }, error: {
                (message) -> Void in
                print(message)
                self.txt_alert = message
                self.showAlert(status: 0)
                
            })
        }
        
        
    }
    
    func redirectLogin(status: Int){
        if(status == 1){
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "initController") as! ViewController
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    //funcion para mostrar alerta
    func showAlert(status: Int){
        print("entra a alerta")
        let alert = UIAlertController(title: nil, message: self.txt_alert, preferredStyle: .alert);
        let btn_alert = UIAlertAction(title: "Aceptar", style: .default) { (UIAlertAction) in  self.redirectLogin(status: status);
        }
        alert.addAction(btn_alert);
        self.present(alert, animated: true, completion: nil);
    }
    
    @IBAction func showTerms(_ sender: Any) {
        
        self.termsView.isHidden = false
    }
    
    @IBAction func hiddenTerms(_ sender: Any) {
        self.termsView.isHidden = true
    }

}
