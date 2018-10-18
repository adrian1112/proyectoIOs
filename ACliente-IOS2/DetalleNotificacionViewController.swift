//
//  DetalleNotificacionViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 15/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit

class DetalleNotificacionViewController: UIViewController {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var bodyView: UITextView!
    
    var title_string = ""
    var image = UIImage(named: "altura")
    var body_string = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleView.text = title_string
        imgView.image = image
        bodyView.text = body_string
        
    }
    
    @IBAction func exit(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    //HABILITA LA OPCION DE OCULTAR EL TECLADO CUANDO SE LE DA EN CUALQUIER PARTE DE LA PANTALLA
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }

}
