//
//  mainTabViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 10/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit
import CoreLocation

class mainTabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var btn_contratos: UIButton!
    @IBOutlet weak var btn_buzon: UIButton!
    @IBOutlet weak var btn_agencias: UIButton!
    @IBOutlet weak var btn_tramites: UIButton!
    
    
    @IBOutlet weak var contratos_width: NSLayoutConstraint!
    @IBOutlet weak var buzon_width: NSLayoutConstraint!
    @IBOutlet weak var agencias_width: NSLayoutConstraint!
    @IBOutlet weak var trmites_width: NSLayoutConstraint!
    
    @IBOutlet weak var menuView: UIView!
    let border = CALayer()
    var width = CGFloat(0.0)
    let width2 = CGFloat(3.0)
    
    @IBOutlet weak var containerScrollLeading: NSLayoutConstraint!
    @IBOutlet weak var contarinerScrollWidth: NSLayoutConstraint!
    
    //++++++++++ SECCION PARA CONTRATOS +++++++++++++++++++++++
    @IBOutlet weak var tableViewContratos: UITableView!
    var dataContratos = [cellData]()
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    //++++++++++++++++ secicon buzon +++++++++++++
    @IBOutlet weak var tableViewBuzon: UITableView!
    var dataBuzon = [cellData]()
    
    //++++++++++++++++++++++++++++++++++++++++++++++++
    
    //++++++++++++++++ secicon agencias +++++++++++++
    @IBOutlet weak var tableViewAgencias: UITableView!
    var dataAgencias = [place]()
    var filteredPlaces = [place]()
    @IBOutlet weak var SearchBar: UISearchBar!
    //++++++++++++++++++++++++++++++++++++++++++++++++
    
    //++++++++++++++++ secicon tramites +++++++++++++
    @IBOutlet weak var tableViewTramites: UITableView!
    var dataTramites = [cellData]()
    //++++++++++++++++++++++++++++++++++++++++++++++++
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        width = UIScreen.main.bounds.size.width
        self.contratos_width.constant = width/4
        self.buzon_width.constant = width/4
        self.agencias_width.constant = width/4
        self.trmites_width.constant = width/4
        
        btn_contratos.setTitleColor(UIColor.orange, for: .normal)
        
        contarinerScrollWidth.constant = 4*width
        
        
        border.borderColor = UIColor.orange.cgColor
        border.frame = CGRect(x: 0, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        border.borderWidth = width2
        menuView.layer.addSublayer(border)
        menuView.layer.masksToBounds = true
        
        //++++++++++++++++ secicon contratos +++++++++++++
        tableViewContratos.delegate = self
        tableViewContratos.dataSource = self
        
        self.dataContratos.append(cellData.init(image: UIImage(named: "llave_agua.png"), message: "mensaje", title: "alias", date: "2018-10-11", service: "servicio"))
        
        //++++++++++++++++++++++++++++++++++++++++++++++++

        //++++++++++++++++ secicon buzon +++++++++++++
        tableViewBuzon.delegate = self
        tableViewBuzon.dataSource = self
        
        self.dataBuzon = [ cellData.init(image: #imageLiteral(resourceName: "yWarning"), message: "Interrupción Programada del servicio: A partir del 01/01/1991 se realizarán trabajos en RECINTO POSORJA por trabajo programado. Agradecemos si compresion", title: "INTERRUPCIÓN PROGRAMADA DE SERVICIO", date: "29 Jun", service: ""),cellData.init(image: #imageLiteral(resourceName: "pago"), message: "INTERAGUA,informa que se ha generado en su contrato No.111 -222-3333333 por el valor de USD 15.26 correspondiente a JUNIO de 2018 con fecha de vencimiento 01/01/1991", title: "EMISIÓN DE FACTURA", date: "29 Jun", service: "")]
        
        //++++++++++++++++++++++++++++++++++++++++++++++++
        
        //++++++++++++++++ secicon agencias +++++++++++++
        tableViewAgencias.delegate = self
        tableViewAgencias.dataSource = self
        
        SearchBar.delegate = self
        
        self.dataAgencias = [
            place.init(name: "AGENCIA CENTRO", street: "Coronel y Maldonado", attention: "Lunes a viernes: 07:30 a 17:00 y Sábados: 09:00 a 13:00", coordinate: CLLocationCoordinate2D(latitude: -2.204457, longitude: -79.886952),selected: false, date_sync: ""),
            place.init(name: "MUNICIPIO DE GUAYAQUIL", street: "10 de Agosto y Pichincha, entrando por el callejon arosemena", attention: "Lunes a viernes: 08:30 a 16:30", coordinate: CLLocationCoordinate2D(latitude: -2.195159, longitude: -79.880961),selected: false, date_sync: "")
        ]
        
        self.filteredPlaces = self.dataAgencias
        
        //++++++++++++++++++++++++++++++++++++++++++++++++
        
        //++++++++++++++++ secicon tramites +++++++++++++
        tableViewTramites.delegate = self
        tableViewTramites.dataSource = self
        
        self.dataTramites = [ cellData.init(image: #imageLiteral(resourceName: "procesoTerminado"), message: "Ingrese su reclamo técnico", title: "SOLICITUDES TÉCNICAS", date: "", service: ""),cellData.init(image: #imageLiteral(resourceName: "procesoTerminado"), message: "Ingrese su reclamo de primera instancia", title: "RECLAMOS POR FACTURACIÓN", date: "", service: "")]
        //++++++++++++++++++++++++++++++++++++++++++++++++
        
    }
    
    @IBAction func regresar(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //++++++++++++++++++++ FUNCIONES PARA SCROLL VIEW ++++++++++++++++++++++++++++++
    
    @IBAction func contratoAccion(_ sender: Any) {
        btn_contratos.setTitleColor(UIColor.orange, for: .normal)
        btn_buzon.setTitleColor(UIColor.white, for: .normal)
        btn_agencias.setTitleColor(UIColor.white, for: .normal)
        btn_tramites.setTitleColor(UIColor.white, for: .normal)
        
        border.frame = CGRect(x: 0, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        moverViewScroll(valor: CGFloat(0.0))
    }
    
    @IBAction func buzonAccion(_ sender: Any) {
        btn_contratos.setTitleColor(UIColor.white, for: .normal)
        btn_buzon.setTitleColor(UIColor.orange, for: .normal)
        btn_agencias.setTitleColor(UIColor.white, for: .normal)
        btn_tramites.setTitleColor(UIColor.white, for: .normal)
        
        border.frame = CGRect(x: width/4, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        moverViewScroll(valor: -1*width)
    }
    
    @IBAction func agenciasAccion(_ sender: Any) {
        btn_contratos.setTitleColor(UIColor.white, for: .normal)
        btn_buzon.setTitleColor(UIColor.white, for: .normal)
        btn_agencias.setTitleColor(UIColor.orange, for: .normal)
        btn_tramites.setTitleColor(UIColor.white, for: .normal)
        
        border.frame = CGRect(x: 2*(width/4), y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        moverViewScroll(valor: -2*width)
    }
    
    @IBAction func tramitesAccion(_ sender: Any) {
        btn_contratos.setTitleColor(UIColor.white, for: .normal)
        btn_buzon.setTitleColor(UIColor.white, for: .normal)
        btn_agencias.setTitleColor(UIColor.white, for: .normal)
        btn_tramites.setTitleColor(UIColor.orange, for: .normal)
        
        border.frame = CGRect(x: 3*(width/4), y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        moverViewScroll(valor: -3*width)
    }
    
    func moverViewScroll( valor: CGFloat){
        UIView.animate(withDuration: 0.2) {
            self.containerScrollLeading.constant = valor
            self.view.layoutIfNeeded()
        }
    }
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    //+++++++++++++++++++++++ SECCION DE CONTRATOS +++++++++++++++++++++++++++++++++++++++++++++++++
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tableViewContratos{
                return dataContratos.count
        }else
            if tableView == tableViewBuzon{
            return dataBuzon.count
        }else
                if tableView == tableViewAgencias{
                    return filteredPlaces.count
        }else
                    if tableView == tableViewTramites{
                        print("cantidad \(dataTramites.count)" )
                        return dataTramites.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("CustomTableViewCell", owner: self, options: nil)?.first as! CustomTableViewCell
        
        if tableView == tableViewBuzon {
            
            cell.mainImage.image = dataBuzon[indexPath.row].image
            cell.mainTitle.text = dataBuzon[indexPath.row].title
            cell.mainMessage.text = dataBuzon[indexPath.row].message
            cell.mainDate.text = dataBuzon[indexPath.row].date
            return cell
        }else
            if tableView == tableViewContratos {
                cell.mainImage.image = dataContratos[indexPath.row].image
                cell.mainTitle.text = dataContratos[indexPath.row].title
                cell.mainMessage.text = dataContratos[indexPath.row].message
                cell.mainDate.text = dataContratos[indexPath.row].date
                return cell
        }else
                if tableView == tableViewAgencias{
                    cell.mainImage.image = UIImage(named: "menu_intergua_agencia.png")
                    cell.mainTitle.text = filteredPlaces[indexPath.row].name
                    cell.mainMessage.text = filteredPlaces[indexPath.row].street
                    cell.mainDate.text = ""
                    return cell
        }else
                    if tableView == tableViewTramites{
                        cell.mainImage.image = dataTramites[indexPath.row].image
                        cell.mainTitle.text = dataTramites[indexPath.row].title
                        cell.mainMessage.text = dataTramites[indexPath.row].message
                        cell.mainDate.text = dataTramites[indexPath.row].date
                        return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tableViewBuzon{
            print("Buzon selected", indexPath.row)
        }else
            if tableView == tableViewContratos{
                print("Contratos selected", indexPath.row)
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetalleCuentaViewController") as! DetalleCuentaViewController
                self.present(viewController, animated: true)
                
        }else
                if tableView == tableViewAgencias{
                    print("Agencias selected", indexPath.row)
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomMapViewController") as! CustomMapViewController
                    self.present(viewController, animated: true)
        }else
                    if tableView == tableViewTramites{
                        print("tramites selected", indexPath.row)
                        
        }
        
        /*
        let tabBarViewController = self.storyboard?.instantiateViewController(withIdentifier: "detaillsTabBarController") as! DetailsTabBarViewController
        tabBarViewController.contrato = data[indexPath.row].title!
        tabBarViewController.servicio = data[indexPath.row].service!
        tabBarViewController.detailtAccountItem = accounts_list[indexPath.row]
        self.present(tabBarViewController, animated: true)*/
        
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if tableView == tableViewContratos{
            let delete = UITableViewRowAction(style: .destructive, title: "Eliminar") { (action, indexPath) in
                // delete item at indexPath
                let alert = UIAlertController(title: nil, message: "Seguro desea eliminar la cuenta \(self.dataContratos[indexPath.row].service as! String)?", preferredStyle: .alert);
                let btn_alert = UIAlertAction(title: "Aceptar", style: .default) { (UIAlertAction) in
                    print("aceptar")
                    //funcion para eliminar cuenta
                    /*self.ws.deleteService(id: self.user.id_user, service: self.data[indexPath.row].service as! String,
                     success: {
                     (message) -> Void in
                     print("eliminado \(message)")
                     
                     _ = self.dbase.deleteDetaillsAccount(account: self.data[indexPath.row].service as! String)
                     _ = self.dbase.deleteAccount(account: self.data[indexPath.row].service as! String)
                     
                     
                     self.data.remove(at: indexPath.row)
                     tableView.deleteRows(at: [indexPath], with: .fade)
                     print(self.data)
                     
                     
                     
                     },error: {
                     (message) -> Void in
                     print("eliminado err \(message)")
                     self.showAlert(message: "Se produjo un error al eliminar la cuenta \(self.data[indexPath.row].service as! String)")
                     })*/
                    
                }
                let btn_cancel = UIAlertAction(title: "Cancelar", style: .destructive) { (UIAlertAction) in
                    print("cancelar")
                }
                alert.addAction(btn_alert);
                alert.addAction(btn_cancel);
                self.present(alert, animated: true, completion: nil);
                
                
            }
            
            let share = UITableViewRowAction(style: .default, title: "Alias") { (action, indexPath) in
                print("alias")
                // share item at indexPath
                //self.selectedAcount = self.data[indexPath.row].service as! String
                
                //self.viewalias.isHidden = false
                //self.errAlias.isHidden = true
                //self.titleAlias.text = "Cambiar Alias a cuenta \(self.data[indexPath.row].service as! String)"
                //print("I want to share: \(self.data[indexPath.row])")
            }
            
            share.backgroundColor = UIColor.lightGray
            
            return [delete, share]
        }
        
        return []
    }
    
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    //+++++++++++++++++++++++++++ SECCION AGENCIAS ++++++++++++++++++++++++++++++
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.filteredPlaces = self.dataAgencias
        self.tableViewAgencias.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print("entra en busqueda")
        filteredPlaces = dataAgencias.filter({ (place) -> Bool in
            let tmp: NSString = place.name! as NSString
            
            print(tmp)
            
            return tmp.localizedCaseInsensitiveContains(searchText)
            
            //return range.location != NSNotFound
        })
        
        if searchText == ""{
            self.filteredPlaces = self.dataAgencias
        }
        self.tableViewAgencias.reloadData()
    }
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    @IBAction func callCenter(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
        self.present(viewController, animated: true)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
