//
//  ContactViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 12/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func llamar(_ sender: Any) {
        let number = "134"
        Utils.call(number: number)
    }
    
    
    @IBAction func chat(_ sender: Any) {
        let mainTabViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        self.present(mainTabViewController, animated: true, completion: nil)
    }
    
    //HABILITA LA OPCION DE OCULTAR EL TECLADO CUANDO SE LE DA EN CUALQUIER PARTE DE LA PANTALLA
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
}

class Utils: NSObject {
    class func call(number: String) {
        print("entra en llamada")
        let num = "tel://" + number
        //if let url = NSURL(string: num) {
        if let url = URL(string: num) {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url , options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

}
