//
//  SugerenciaViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 15/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit

class SugerenciaViewController: UIViewController {
    
    //let ws = WService();
    //let dbase = DBase();
    //var db: Connection!
    
    @IBOutlet weak var texto: UITextView!
    
    var user = User.init(id_user: 0, document: "", person: "", email: "", phone: "", sync_date: "", adress: "", status: 1, error: 1)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        /*let status = dbase.connect_db()
        if( status.value ){
            print("entra a buscar usuario")
            user = self.dbase.loadUsersDB()
        }*/
        
    }
    

    @IBAction func enviar(_ sender: Any) {
        if texto.text.trimmingCharacters(in: .whitespaces) != ""{
            
            /*self.ws.sendSuggest(id_user: self.user.id_user, message: self.text.text,
                                success:{ (message) -> Void in
                                    self.showAlert(message: "Se enviaron sus comentarios",tipo: 2)
                                    print("\(message)")
                                    //self.showAlert(message: message)
                                    
            }, error:{ (message) -> Void in
                print("\(message)")
                if message != ""{
                    self.showAlert(message: message,tipo: 1)
                }else{
                    self.showAlert(message: "Se genero un problema al enviar los comentarios",tipo: 1)
                }
                
                
            })*/
            
        }else{
            showAlert(message: "Por favor ingrese sus comentarios",tipo: 1)
        }
    }
    
    func showAlert(message: String, tipo: Int){
        print("entra a alerta")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert);
        let btn_alert = UIAlertAction(title: "Aceptar", style: .default) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        let btn_alert1 = UIAlertAction(title: "Aceptar", style: .default) { (UIAlertAction) in
            
        }
        
        if tipo == 1 {
            alert.addAction(btn_alert1);
        }else{
            alert.addAction(btn_alert);
        }
        
        self.present(alert, animated: true, completion: nil);
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func regresar(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
