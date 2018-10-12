//
//  DetalleCuentaViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 12/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit

class DetalleCuentaViewController: UIViewController {
    
    @IBOutlet weak var aliasTitle: UILabel!
    @IBOutlet weak var cuentaTitle: UILabel!
    
    
    @IBOutlet weak var Btn_deuda: UIButton!
    @IBOutlet weak var Btn_facturas: UIButton!
    @IBOutlet weak var Btn_consumos: UIButton!
    @IBOutlet weak var Btn_tramites: UIButton!
    
    @IBOutlet weak var deuda_width: NSLayoutConstraint!
    @IBOutlet weak var facturas_width: NSLayoutConstraint!
    @IBOutlet weak var consumo_width: NSLayoutConstraint!
    @IBOutlet weak var tramites_width: NSLayoutConstraint!
    
    
    let border = CALayer()
    var width = CGFloat(0.0)
    let width2 = CGFloat(3.0)
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var widthScrollView: NSLayoutConstraint!
    @IBOutlet weak var containerScrollLEading: NSLayoutConstraint!
    
    //++++++++++ SECCION PARA DEUDAS +++++++++++++++++++++++
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    //++++++++++ SECCION PARA FACTURAS +++++++++++++++++++++++
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    //++++++++++ SECCION PARA CONSUMOS +++++++++++++++++++++++
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    //++++++++++ SECCION PARA TRAMITES +++++++++++++++++++++++
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        width = UIScreen.main.bounds.size.width
        self.deuda_width.constant = width/4
        self.facturas_width.constant = width/4
        self.consumo_width.constant = width/4
        self.tramites_width.constant = width/4
        
        Btn_deuda.setTitleColor(UIColor.orange, for: .normal)
        
        widthScrollView.constant = 4*width
        
        border.borderColor = UIColor.orange.cgColor
        border.frame = CGRect(x: 0, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        border.borderWidth = width2
        menuView.layer.addSublayer(border)
        menuView.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func deudaAccion(_ sender: Any) {
        Btn_deuda.setTitleColor(UIColor.orange, for: .normal)
        Btn_facturas.setTitleColor(UIColor.white, for: .normal)
        Btn_consumos.setTitleColor(UIColor.white, for: .normal)
        Btn_tramites.setTitleColor(UIColor.white, for: .normal)
        
        border.frame = CGRect(x: 0, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        moverViewScroll(valor: CGFloat(0.0))
    }
    
    @IBAction func facturasAccion(_ sender: Any) {
        Btn_deuda.setTitleColor(UIColor.white, for: .normal)
        Btn_facturas.setTitleColor(UIColor.orange, for: .normal)
        Btn_consumos.setTitleColor(UIColor.white, for: .normal)
        Btn_tramites.setTitleColor(UIColor.white, for: .normal)
        
        border.frame = CGRect(x: width/4, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        moverViewScroll(valor: -1*width)
    }
    
    @IBAction func consumoAccion(_ sender: Any) {
        Btn_deuda.setTitleColor(UIColor.white, for: .normal)
        Btn_facturas.setTitleColor(UIColor.white, for: .normal)
        Btn_consumos.setTitleColor(UIColor.orange, for: .normal)
        Btn_tramites.setTitleColor(UIColor.white, for: .normal)
        
        border.frame = CGRect(x: 2*(width/4), y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        moverViewScroll(valor: -2*width)
    }
    
    @IBAction func tramitesAccion(_ sender: Any) {
        Btn_deuda.setTitleColor(UIColor.white, for: .normal)
        Btn_facturas.setTitleColor(UIColor.white, for: .normal)
        Btn_consumos.setTitleColor(UIColor.white, for: .normal)
        Btn_tramites.setTitleColor(UIColor.orange, for: .normal)
        
        border.frame = CGRect(x: 3*(width/4), y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        moverViewScroll(valor: -3*width)
    }
    
    func moverViewScroll( valor: CGFloat){
        UIView.animate(withDuration: 0.2) {
            self.containerScrollLEading.constant = valor
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func callCenter(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
        self.present(viewController, animated: true)
    }
    
    @IBAction func regresar(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
