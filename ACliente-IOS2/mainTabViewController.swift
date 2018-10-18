//
//  mainTabViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 10/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit
import CoreLocation
import SQLite

class mainTabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let ws = WService()
    let dbase = DBase();
    var db: Connection!
    
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
    
    @IBOutlet weak var viewalias: UIView!
    @IBOutlet weak var titleAlias: UILabel!
    @IBOutlet weak var newAlias: UITextField!
    @IBOutlet weak var errAlias: UILabel!
    
    var txt_alert = ""
    @IBOutlet weak var spin: UIView!
    
    @IBOutlet weak var nuevoContrato: UIView!
    
    
    //++++++++++ SECCION PARA CONTRATOS +++++++++++++++++++++++
    @IBOutlet weak var tableViewContratos: UITableView!
    var dataContratos = [cellData]()
    var selectedAcount = ""
    
    lazy var refreshControlContratos: UIRefreshControl = {
        let refreshControlContratos = UIRefreshControl()
        refreshControlContratos.addTarget(self, action: #selector(refreshCoreData(_:)), for: .valueChanged)
        refreshControlContratos.tintColor = UIColor.blue
        
        return refreshControlContratos
    }()
    
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    

    
    //++++++++++++++++ secicon buzon +++++++++++++
    @IBOutlet weak var tableViewBuzon: UITableView!
    var dataBuzon = [cellData]()
    lazy var refreshControlBuzon: UIRefreshControl = {
        let refreshControlBuzon = UIRefreshControl()
        refreshControlBuzon.addTarget(self, action: #selector(refreshNotificationData(_:)), for: .valueChanged)
        refreshControlBuzon.tintColor = UIColor.blue
        
        return refreshControlBuzon
    }()
    
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
    
    
    var user = User.init(id_user: 0, document: "", person: "", email: "", phone: "", sync_date: "", adress: "", status: 1, error: 1)
    var listaDetalleCuentas = [detailAccount]()
    var listaNotificaciones = [notification]()
    
    
    
    var ventanaSeleccionada = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let leftswipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        leftswipe.direction = UISwipeGestureRecognizer.Direction.left
        let rigthswipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        rigthswipe.direction = UISwipeGestureRecognizer.Direction.right
        
        self.view.addGestureRecognizer(leftswipe)
        self.view.addGestureRecognizer(rigthswipe)
        
        
        
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
        
        let status = dbase.connect_db()
        
        
        //++++++++++++++++ secicon contratos +++++++++++++
        tableViewContratos.delegate = self
        tableViewContratos.dataSource = self
        
        //self.dataContratos.append(cellData.init(image: UIImage(named: "llave_agua.png"), message: "mensaje", title: "alias", date: "2018-10-11", service: "servicio"))
        
        if( status.value ){
            self.db = status.conec;
            print("entra a buscar detalles de cuenta")
            listaDetalleCuentas = self.dbase.getAllDetailsAccounts()
            
            for item in listaDetalleCuentas{
                print(item)
                self.dataContratos.append(cellData.init(image: #imageLiteral(resourceName: "llave_agua"), message: "\(item.servicio) - \(item.direccion)", title: item.alias, date: "", service: item.servicio))
            }
            
            user = self.dbase.loadUsersDB()
        }
        
        self.tableViewContratos.addSubview(refreshControlContratos)
        
        self.viewalias.isHidden = true
        
        
        //++++++++++++++++++++++++++++++++++++++++++++++++

        //++++++++++++++++ secicon buzon +++++++++++++
        tableViewBuzon.delegate = self
        tableViewBuzon.dataSource = self
        
        if( status.value ){
            //self.db = status.conec;
            self.refreshTable()
        }
        
        self.tableViewBuzon.addSubview(refreshControlBuzon)
        
        //++++++++++++++++++++++++++++++++++++++++++++++++
        
        //++++++++++++++++ secicon agencias +++++++++++++
        tableViewAgencias.delegate = self
        tableViewAgencias.dataSource = self
        
        SearchBar.delegate = self
        
        self.dataAgencias = [
            place.init(name: "AGENCIA CENTRO", street: "Coronel y Maldonado", attention: "Lunes a viernes: 07:30 a 17:00 y Sábados: 09:00 a 13:00", coordinate: CLLocationCoordinate2D(latitude: -2.204457, longitude: -79.886952),selected: false, date_sync: ""),
            place.init(name: "MUNICIPIO DE GUAYAQUIL", street: "10 de Agosto y Pichincha, entrando por el callejon arosemena", attention: "Lunes a viernes: 08:30 a 16:30", coordinate: CLLocationCoordinate2D(latitude: -2.195159, longitude: -79.880961),selected: false, date_sync: "")
        ]
        
        if status.value {
            let places_temp = dbase.getAgencies()
            if places_temp.count > 0{
                self.dataAgencias = places_temp
            }
        }
        
        self.filteredPlaces = self.dataAgencias
        
        //++++++++++++++++++++++++++++++++++++++++++++++++
        
        //++++++++++++++++ secicon tramites +++++++++++++
        tableViewTramites.delegate = self
        tableViewTramites.dataSource = self
        
        self.dataTramites = [ cellData.init(image: #imageLiteral(resourceName: "procesoTerminado"), message: "Ingrese su reclamo técnico", title: "SOLICITUDES TÉCNICAS", date: "", service: ""),cellData.init(image: #imageLiteral(resourceName: "procesoTerminado"), message: "Ingrese su reclamo de primera instancia", title: "RECLAMOS POR FACTURACIÓN", date: "", service: "")]
        //++++++++++++++++++++++++++++++++++++++++++++++++
        
        
        self.spin.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refreshTableContratos()
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
        ventanaSeleccionada = 1
    }
    
    @IBAction func buzonAccion(_ sender: Any) {
        btn_contratos.setTitleColor(UIColor.white, for: .normal)
        btn_buzon.setTitleColor(UIColor.orange, for: .normal)
        btn_agencias.setTitleColor(UIColor.white, for: .normal)
        btn_tramites.setTitleColor(UIColor.white, for: .normal)
        
        border.frame = CGRect(x: width/4, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        moverViewScroll(valor: -1*width)
        ventanaSeleccionada = 2
    }
    
    @IBAction func agenciasAccion(_ sender: Any) {
        btn_contratos.setTitleColor(UIColor.white, for: .normal)
        btn_buzon.setTitleColor(UIColor.white, for: .normal)
        btn_agencias.setTitleColor(UIColor.orange, for: .normal)
        btn_tramites.setTitleColor(UIColor.white, for: .normal)
        
        border.frame = CGRect(x: 2*(width/4), y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        moverViewScroll(valor: -2*width)
        ventanaSeleccionada = 3
    }
    
    @IBAction func tramitesAccion(_ sender: Any) {
        btn_contratos.setTitleColor(UIColor.white, for: .normal)
        btn_buzon.setTitleColor(UIColor.white, for: .normal)
        btn_agencias.setTitleColor(UIColor.white, for: .normal)
        btn_tramites.setTitleColor(UIColor.orange, for: .normal)
        
        border.frame = CGRect(x: 3*(width/4), y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        moverViewScroll(valor: -3*width)
        ventanaSeleccionada = 4
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
            
            let title_string = dataBuzon[indexPath.row].title
            let body_string = dataBuzon[indexPath.row].message
            let image_string =  dataBuzon[indexPath.row].image
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetalleNotificacionViewController") as! DetalleNotificacionViewController
            viewController.title_string = title_string!
            viewController.image = image_string
            viewController.body_string = body_string!
            self.present(viewController, animated: true, completion: nil)
            
        }else
            if tableView == tableViewContratos{
                print("Contratos selected", indexPath.row)
                
                let contrato_temp = dataContratos[indexPath.row].service
                
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetalleCuentaViewController") as! DetalleCuentaViewController
                viewController.contrato = contrato_temp!
                viewController.detailAccountItem = listaDetalleCuentas[indexPath.row]
                self.present(viewController, animated: true)
                
        }else
                if tableView == tableViewAgencias{
                    print("Agencias selected", indexPath.row)
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomMapViewController") as! CustomMapViewController
                    
                    var lugar = self.filteredPlaces[indexPath.row]
                    lugar.selected = true
                    viewController.seleccionado = lugar
                    self.present(viewController, animated: true)
        }else
                    if tableView == tableViewTramites{
                        print("tramites selected", indexPath.row)
                        switch indexPath.row {
                        case 0:
                            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SolTecnicasViewController") as! SolTecnicasViewController
                            self.present(viewController, animated: true, completion: nil)
                        case 1:
                            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ReclamosViewController") as! ReclamosViewController
                            self.present(viewController, animated: true, completion: nil)
                        default:
                            break
                        }
                        
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
                    self.ws.deleteService(id: self.user.id_user, service: self.dataContratos[indexPath.row].service as! String,
                     success: {
                     (message) -> Void in
                     print("eliminado \(message)")
                     
                     _ = self.dbase.deleteDetaillsAccount(account: self.dataContratos[indexPath.row].service as! String)
                     _ = self.dbase.deleteAccount(account: self.dataContratos[indexPath.row].service as! String)
                     
                     
                     self.dataContratos.remove(at: indexPath.row)
                     tableView.deleteRows(at: [indexPath], with: .fade)
                     print(self.dataContratos)
                     
                     
                     
                     },error: {
                     (message) -> Void in
                     print("eliminado err \(message)")
                     self.showAlert(message: "Se produjo un error al eliminar la cuenta \(self.dataContratos[indexPath.row].service as! String)")
                     })
                    
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
                self.selectedAcount = self.dataContratos[indexPath.row].service as! String
                
                self.viewalias.isHidden = false
                self.errAlias.isHidden = true
                self.titleAlias.text = "Cambiar Alias a cuenta \(self.dataContratos[indexPath.row].service as! String)"
                print("I want to share: \(self.dataContratos[indexPath.row])")
            }
            
            share.backgroundColor = UIColor.lightGray
            
            return [delete, share]
        }
        
        return []
    }
    
    @IBAction func agregarContrato(_ sender: Any) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "NuevoContratoViewController") as! NuevoContratoViewController
        viewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(viewController, animated: true)
        
    }
    
    @objc func refreshCoreData(_ refreshControl: UIRefreshControl){
        print("actualiza data core")
        self.spin.isHidden = false
        DispatchQueue.global(qos: .background).async{
            self.ws.loadAcounts(id_user: String(describing: self.user.id_user), date: self.user.sync_date,
                                success: {
                                    (accounts) -> Void in
                                    //self.text_spin.text = " Procesando Datos: Cuentas"
                                    
                                    if accounts.count > 0 {
                                        
                                        do{
                                            
                                            try self.db.execute("DELETE FROM cuentas;")
                                            self.dbase.insertAccounts(accounts: accounts as! [account])
                                            
                                            self.syncAllDataCore(accounts: accounts as! [account])
                                            
                                        }catch let Result.error(message, code, statement){
                                            print("mensaje: \(message), codigo: \(code), statment: \(String(describing: statement)) ")
                                            
                                            DispatchQueue.main.async{
                                                self.refreshControlContratos.endRefreshing()
                                                self.spin.isHidden = true
                                                self.txt_alert = "Se genero un error al momento de actualizar las cuentas";
                                                self.showAlert();
                                            }
                                            
                                        }catch {
                                            print(error)
                                            
                                            DispatchQueue.main.async{
                                                self.refreshControlContratos.endRefreshing()
                                                self.spin.isHidden = true
                                                self.txt_alert = "Se genero un error al momento de actualizar las cuentas";
                                                self.showAlert();
                                            }
                                        }
                                        
                                        
                                    }
                                    
                                    
                                    
            },error: {
                (accounts,message) -> Void in
                //self.spin.stopAnimating()
                DispatchQueue.main.async{
                    self.refreshControlContratos.endRefreshing()
                    self.spin.isHidden = true
                    self.txt_alert = message;
                    self.showAlert();
                }
                
            })
        }
        
    }
    
    func syncAllDataCore( accounts: [account]){
        self.ws.loadCore(id_user: String(describing: self.user.id_user), accounts: accounts,
                         success: {
                            (notifications) -> Void in
                            print("ok load core")
                            //self.spin.stopAnimating()
                            DispatchQueue.main.async{
                                self.refreshControlContratos.endRefreshing()
                                self.spin.isHidden = true
                                self.refreshTableContratos()
                            }
                            
                            
        },error: {
            (accounts,message) -> Void in
            //self.spin.stopAnimating()
            
            DispatchQueue.main.async{
                self.refreshControlContratos.endRefreshing()
                self.spin.isHidden = true
                self.txt_alert = message;
                self.showAlert();
            }
            
        })
        
    }
    
    func refreshTableContratos(){
        
        self.dataContratos = []
        listaDetalleCuentas = self.dbase.getAllDetailsAccounts()
        
        for item in listaDetalleCuentas{
            print(item)
            self.dataContratos.append(cellData.init(image: #imageLiteral(resourceName: "llave_agua"), message: "\(item.servicio) - \(item.direccion)", title: item.alias, date: "", service: item.servicio))
        }
        
        self.tableViewContratos.reloadData()
        
        self.newAlias.text = ""
        self.titleAlias.text = "Cambiar Alias a cuenta"
        self.viewalias.isHidden = true
        
    }
    
    
    
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    //++++++++++++++++++++++++++++++ SECCION BUZZON++++++++++++++++++++++++++++++++++++++++
    func refreshTable(){
        
        print("entra a buscar detalles de cuenta")
        self.dataBuzon = []
        listaNotificaciones = self.dbase.getNotifications()
        
        var i = 0
        for item in listaNotificaciones{
            print(item)
            i += 1
            var img = UIImage(named: "alerta_mensaje_2"  )
            if(item.type == "1"){
                img = UIImage(named: "alerta_mensaje_2" )
            }else{
                img = UIImage(named: "info_mensaje_2" )
            }
            
            self.dataBuzon.append(cellData.init(image: img, message: item.message, title: "titulo", date: item.date_gen, service: item.contract))
        }
        if i == 0{
            self.dataBuzon = [ cellData.init(image: #imageLiteral(resourceName: "yWarning"), message: "Interrupción Programada del servicio: A partir del 01/01/1991 se realizarán trabajos en RECINTO POSORJA por trabajo programado. Agradecemos si compresion", title: "INTERRUPCIÓN PROGRAMADA DE SERVICIO", date: "29 Jun", service: ""),cellData.init(image: #imageLiteral(resourceName: "pago"), message: "INTERAGUA,informa que se ha generado en su contrato No.111 -222-3333333 por el valor de USD 15.26 correspondiente a JUNIO de 2018 con fecha de vencimiento 01/01/1991", title: "EMISIÓN DE FACTURA", date: "29 Jun", service: "")]
        }
        
        self.tableViewBuzon.reloadData()
        
        
    }
    
    @IBAction func aceptAlias(_ sender: Any) {
        self.view.endEditing(true)
        if self.newAlias.text?.trimmingCharacters(in: .whitespaces) != ""{
            let id_usuario = self.user.id_user
            let alias = self.newAlias.text?.trimmingCharacters(in: .whitespaces)
            let num_contrato = self.selectedAcount
            
            print("entra en actualizar servicio")
            
            //DispatchQueue.global(qos: .background).async
            // {
            self.ws.updateService(id: id_usuario, alias: alias!, service: num_contrato, success:{
                (message) -> Void in
                print(message)
                
                let ok = self.dbase.updateAccount(account: num_contrato, alias: alias!)
                if ok{
                    self.refreshTable()
                    
                }
                
            }, error:{
                (message) -> Void in
                print(message)
                
                DispatchQueue.main.async {
                    //self.spin.stopAnimating()
                    //self.spinView.isHidden = true
                    self.showAlert(message: "Se produjo un error al cambiar el alias a la cuenta \(num_contrato)")
                }
                
            })
            //}
            
            
        }else{
            
            self.errAlias.isHidden = false
            
        }
    }
    
    @IBAction func cancelAlias(_ sender: Any) {
        self.view.endEditing(true)
        self.newAlias.text = ""
        self.titleAlias.text = "Cambiar Alias a cuenta"
        self.viewalias.isHidden = true
    }
    
    @objc func refreshNotificationData(_ refreshControl: UIRefreshControl){
        print("actualiza data notificaciones")
        
        self.spin.isHidden = false
        DispatchQueue.global(qos: .background).async{
            self.ws.loadNotifications(id_user: String(describing: self.user.id_user), date: self.user.sync_date,
                                      success: {
                                        (notifications) -> Void in
                                        print("ok notificacion")
                                        
                                        DispatchQueue.main.async {
                                            self.dbase.insertNotifications(notificationsList: notifications as! [notification])
                                            self.refreshControlBuzon.endRefreshing()
                                            self.spin.isHidden = true
                                            self.refreshTable()
                                            
                                            
                                        }
            },error: {
                (accounts,message) -> Void in
                DispatchQueue.main.async {
                    self.refreshControlBuzon.endRefreshing()
                    self.spin.isHidden = true
                    self.txt_alert = message
                    self.showAlert()
                }
            })
            
        }
        
    }
    
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
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
    
    @IBAction func menuInicial(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Interagua App", message: "Escoja una opción", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Sugerencias", style: .default, handler: { (action: UIAlertAction) in
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SugerenciaViewController") as! SugerenciaViewController
            self.present(viewController, animated: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cerrar sesión", style: .default, handler: { (action: UIAlertAction) in
            
            let alert = UIAlertController(title: nil, message: "Seguro que desea Cerrar Sesión?", preferredStyle: .alert);
            let btn_alert = UIAlertAction(title: "Aceptar", style: .default) { (UIAlertAction) in
                
                
                let status = self.dbase.encerarTables()
                if status{ print("ok")}else{print("error encerando")}
                
                
                //self.dismiss(animated: true, completion: nil)
                let viewController = self.storyboard?.instantiateInitialViewController()
                self.present(viewController!, animated: true)
            }
            let btn_cancel = UIAlertAction(title: "Cancelar", style: .destructive) { (UIAlertAction) in
                
            }
            alert.addAction(btn_alert);
            alert.addAction(btn_cancel);
            self.present(alert, animated: true, completion: nil);
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showAlert(){
        print("entra a alerta")
        let alert = UIAlertController(title: "Error", message: self.txt_alert, preferredStyle: .alert);
        let btn_cancel = UIAlertAction(title: "Aceptar", style: .destructive) { (UIAlertAction) in
            
        }
        alert.addAction(btn_cancel);
        self.present(alert, animated: true, completion: nil);
    }
    
    func showAlert(message: String){
        print("entra a alerta")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert);
        let btn_alert = UIAlertAction(title: "Aceptar", style: .default) { (UIAlertAction) in
            
        }
        
        alert.addAction(btn_alert);
        self.present(alert, animated: true, completion: nil);
    }
    
    //+++++++++++++++++++++ acciones del swipe +++++++++++++++++++++++++++++++
    
    @objc func swipeAction(swipe: UISwipeGestureRecognizer){
        
        print("direccion swipe \(swipe.direction.rawValue)")
        switch swipe.direction.rawValue {
        case 1:
            print("rigth")
            if ventanaSeleccionada == 1{
                print("limite iz")
            }else
                if ventanaSeleccionada == 2{
                    
                    btn_contratos.setTitleColor(UIColor.orange, for: .normal)
                    btn_buzon.setTitleColor(UIColor.white, for: .normal)
                    btn_agencias.setTitleColor(UIColor.white, for: .normal)
                    btn_tramites.setTitleColor(UIColor.white, for: .normal)
                    
                    border.frame = CGRect(x: 0, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
                    
                    moverViewScroll(valor: CGFloat(0.0))
                    ventanaSeleccionada = 1
                    
                    
            }else
                    if ventanaSeleccionada == 3{
                        btn_contratos.setTitleColor(UIColor.white, for: .normal)
                        btn_buzon.setTitleColor(UIColor.orange, for: .normal)
                        btn_agencias.setTitleColor(UIColor.white, for: .normal)
                        btn_tramites.setTitleColor(UIColor.white, for: .normal)
                        
                        border.frame = CGRect(x: width/4, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
                        
                        UIApplication.shared.applicationIconBadgeNumber = 0
                        
                        moverViewScroll(valor: -1*width)
                        ventanaSeleccionada = 2
                        
                        
            }else
                        if ventanaSeleccionada == 4{
                            btn_contratos.setTitleColor(UIColor.white, for: .normal)
                            btn_buzon.setTitleColor(UIColor.white, for: .normal)
                            btn_agencias.setTitleColor(UIColor.orange, for: .normal)
                            btn_tramites.setTitleColor(UIColor.white, for: .normal)
                            
                            border.frame = CGRect(x: 2*(width/4), y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
                            
                            moverViewScroll(valor: -2*width)
                            ventanaSeleccionada = 3
            }
            
            
        case 2:
            print("left")
            if ventanaSeleccionada == 1{
                btn_contratos.setTitleColor(UIColor.white, for: .normal)
                btn_buzon.setTitleColor(UIColor.orange, for: .normal)
                btn_agencias.setTitleColor(UIColor.white, for: .normal)
                btn_tramites.setTitleColor(UIColor.white, for: .normal)
                
                border.frame = CGRect(x: width/4, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
                
                UIApplication.shared.applicationIconBadgeNumber = 0
                
                moverViewScroll(valor: -1*width)
                ventanaSeleccionada = 2
            }else
                if ventanaSeleccionada == 2{
                    btn_contratos.setTitleColor(UIColor.white, for: .normal)
                    btn_buzon.setTitleColor(UIColor.white, for: .normal)
                    btn_agencias.setTitleColor(UIColor.orange, for: .normal)
                    btn_tramites.setTitleColor(UIColor.white, for: .normal)
                    
                    border.frame = CGRect(x: 2*(width/4), y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
                    
                    moverViewScroll(valor: -2*width)
                    ventanaSeleccionada = 3
                }else
                    if ventanaSeleccionada == 3{
                        btn_contratos.setTitleColor(UIColor.white, for: .normal)
                        btn_buzon.setTitleColor(UIColor.white, for: .normal)
                        btn_agencias.setTitleColor(UIColor.white, for: .normal)
                        btn_tramites.setTitleColor(UIColor.orange, for: .normal)
                        
                        border.frame = CGRect(x: 3*(width/4), y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
                        
                        moverViewScroll(valor: -3*width)
                        ventanaSeleccionada = 4
                    }else
                        if ventanaSeleccionada == 4{
                         print("limite der")
            }
        default:
            break
        }
    }
    
}
