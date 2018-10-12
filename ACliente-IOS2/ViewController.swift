//
//  ViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 12/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var midView: UIView!
    @IBOutlet weak var mid2View: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.midView.isHidden = false
        self.mid2View.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func IniciarSesion(_ sender: Any) {
        self.midView.isHidden = true
        self.mid2View.isHidden = false
        
        navigateToApp()
    }
    
    @IBAction func salir(_ sender: Any) {
        self.midView.isHidden = false
        self.mid2View.isHidden = true
    }
    
    @IBAction func accederServicios(_ sender: Any) {
        
        print("entra en servicios")
        navigateToApp()
    }
    
    @IBAction func registrar(_ sender: Any) {
        print("entra en registrar")
    }
    
    @IBAction func recuperarContrasenia(_ sender: Any) {
        print("entra en recuperar pass")
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
}

