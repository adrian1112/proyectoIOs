//
//  CustomCollectionViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 12/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit
import Alamofire

class CustomCollectionViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let items = [pagina.init(img: #imageLiteral(resourceName: "redfacilito"), url: "https://www.switchorm.com/es/index.php/es/"),
                 pagina.init(img: #imageLiteral(resourceName: "western-union"), url: "https://www.westernunion.com/ec/es/home.html"),
                 pagina.init(img: #imageLiteral(resourceName: "servipagos"), url: "http://www.servipagos.com/"),
                 pagina.init(img: #imageLiteral(resourceName: "banco_pacifico"), url: "https://www.bancodelpacifico.com/"),
                 pagina.init(img: #imageLiteral(resourceName: "bancomachala"), url: "https://www.bancomachala.com/"),
                 pagina.init(img: #imageLiteral(resourceName: "bancoguayaquil"), url: "https://www.bancoguayaquil.com/"),
                 pagina.init(img: #imageLiteral(resourceName: "bancobolivariano"), url: "https://www.bolivariano.com/"),
                 pagina.init(img: #imageLiteral(resourceName: "banco_pichincha"), url: "https://www.pichincha.com/portal/")]
    
    
    var selectItem = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsWhenKeyboardAppears = false
        
        collectionView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func Back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CustomCollectionViewCell
        
        cell.buttonCell.setImage(self.items[indexPath.row].img , for: .normal)
        
        
        
        cell.buttonCell.addTarget(self, action: #selector(action_btn), for: UIControl.Event.touchUpInside)
        cell.buttonCell.tag = indexPath.row
        return cell
    }
    
    
    @objc func action_btn(sender:UIButton! ) {
     print("entra en funcion de boton")
     if Connectivity.isConnectedToInternet {
     print("Connected")
     let btnsendtag: UIButton = sender
     self.selectItem = btnsendtag.tag
     let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomWebViewController") as! CustomWebViewController
     viewController.url_string = self.items[self.selectItem].url
     self.present(viewController, animated: true)
     
     } else {
     print("No Internet")
     let alert = UIAlertController(title: nil, message: "No tiene acceso a Internet", preferredStyle: .alert);
     let btn_alert = UIAlertAction(title: "Cerrar", style: .default) { (UIAlertAction) in
     }
     alert.addAction(btn_alert);
     self.present(alert, animated: true, completion: nil);
     }
     
     
     
     }

    


}
