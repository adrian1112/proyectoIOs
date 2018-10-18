//
//  RegistroInicialViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 16/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit

class RegistroInicialViewController: UIViewController {

    @IBOutlet weak var identifier_txt: UITextField!
    @IBOutlet weak var email_txt: UITextField!
    @IBOutlet weak var pass1_txt: UITextField!
    @IBOutlet weak var pass2_txt: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var label_error: UILabel!
    
    var identifier = ""
    var email = ""
    var pass = ""
    var contract = ""
    var names = ""
    var address = ""
    var telephone = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("first")
        identifier_txt.text = self.identifier
        email_txt.text = self.email
        pass1_txt.text = self.pass
        pass2_txt.text = self.pass
        
        label_error.text = "Ingrese todos los parámetros"
        
        
    }
    
 
    
    //HABILITA LA OPCION DE OCULTAR EL TECLADO CUANDO SE LE DA EN CUALQUIER PARTE DE LA PANTALLA
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func Longin(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func validatePass(_ sender: Any) {
        let txt1 = self.pass1_txt.text
        let txt2 = self.pass2_txt.text
        let email = self.email_txt.text!.trimmingCharacters(in: .whitespaces)
        let cedula = self.identifier_txt.text!.trimmingCharacters(in: .whitespaces)
        var pass_ok = false
        var text = "* "
        if( (txt1 == txt2) && txt1 != "" && txt2 != "" && txt1?.count ?? 0 > 7){
            pass_ok = true
            self.pass1_txt.layer.borderWidth = 0
            self.pass2_txt.layer.borderWidth = 0
        }else{
            let myColor = UIColor.red
            self.pass1_txt.layer.borderColor = myColor.cgColor
            self.pass2_txt.layer.borderColor = myColor.cgColor
            self.pass1_txt.layer.borderWidth = 1.0
            self.pass2_txt.layer.borderWidth = 1.0
            pass_ok = false
            if txt1?.count ?? 0 > 7{
                text = text + "Las contraseñas no coinciden"
            }else{
                text = text + "Las contraseñas deben tener un mínimo de 7 caracteres"
            }
            
        }
        
        let identifier_ok = verificarCedula(cedula: cedula)
        if !identifier_ok {
            let myColor = UIColor.red
            self.identifier_txt.layer.borderColor = myColor.cgColor
            self.identifier_txt.layer.borderWidth = 1.0
            
            if text == "* " {
                text = text + "Ingrese una cédula válida"
            }else{
                text = text + ", Ingrese una cédula válida"
            }
        }else{
            self.identifier_txt.layer.borderWidth = 0
        }
        
        
        let email_ok = isValidEmail(string: email)
        
        if !email_ok {
            
            let myColor = UIColor.red
            self.email_txt.layer.borderColor = myColor.cgColor
            self.email_txt.layer.borderWidth = 1.0
            
            
            if text == "* " {
                text = text + "Ingrese un correo válido"
            }else{
                text = text + ", Ingrese un correo válido"
            }
        }else{
            self.email_txt.layer.borderWidth = 0
        }
        
        
        if pass_ok && identifier_ok && email_ok{
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "RegistroSecViewController") as! RegistroSecViewController
            viewController.identifier = cedula
            viewController.email = email
            viewController.pass = pass1_txt.text!
            viewController.contract = self.contract
            viewController.names = self.names
            viewController.address = self.address
            viewController.telephone = self.telephone
            self.present(viewController, animated: true)
        }else{
            self.label_error.text = text
        }
    }

    @IBAction func regresar(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
