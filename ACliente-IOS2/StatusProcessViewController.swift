//
//  StatusProcessViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 15/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit

class StatusProcessViewController: UIViewController {
    
    
    @IBOutlet weak var estado1: UILabel!
    @IBOutlet weak var estado2: UILabel!
    @IBOutlet weak var estado3: UILabel!
    
    
    @IBOutlet weak var proceso: UILabel!
    @IBOutlet weak var descripcion: UILabel!
    @IBOutlet weak var tramite: UILabel!
    @IBOutlet weak var fecha_ini: UILabel!
    @IBOutlet weak var fecha_fin: UILabel!
    @IBOutlet weak var estado: UILabel!
    
    @IBOutlet weak var anchoEstadoCentral: NSLayoutConstraint!
    
    @IBOutlet weak var titulo: UILabel!
    
    var titleView = ""
    var process = Process.init("", "", "", "", "", UIImage(named: "proceso")!, false, "", "")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let width = UIScreen.main.bounds.size.width
        anchoEstadoCentral.constant = width*0.27
        
        titulo.text = titleView
        
        self.proceso.text =  process.title
        self.descripcion.text = process.subtitle
        self.tramite.text = process.code
        self.fecha_ini.text = process.date
        self.estado.text = process.status
        self.fecha_fin.text = process.date_end
        
        if(process.status == "ATENDIDO"){
            estado1.backgroundColor =  UIColor.green
            estado2.backgroundColor =  UIColor.green
            estado3.backgroundColor =  UIColor.green
        }else if(process.status == "ANULADO"){
            estado1.backgroundColor =  UIColor.green
            estado2.backgroundColor =  UIColor.red
            estado3.backgroundColor = UIColor.red
        }else{
            estado1.backgroundColor =  UIColor.green
        }
        
    }
    
    
    @IBAction func regresar(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
