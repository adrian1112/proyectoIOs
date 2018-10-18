//
//  DetalleCuentaViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 12/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit
import Charts
import SQLite

class DetalleCuentaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource {
    
    let ws = WService()
    let dbase = DBase();
    var db: Connection!
    
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
    
    @IBOutlet weak var widthView1: NSLayoutConstraint!
    @IBOutlet weak var widthView2: NSLayoutConstraint!
    
    @IBOutlet weak var cliente: UILabel!
    @IBOutlet weak var uso_comercial: UILabel!
    @IBOutlet weak var ci_ruc: UILabel!
    @IBOutlet weak var direccion: UITextView!
    
    @IBOutlet weak var facturas_vencidas: UILabel!
    @IBOutlet weak var max_fecha_pago: UILabel!
    @IBOutlet weak var deuda_diferido: UILabel!
    
    @IBOutlet weak var tipo_medidor: UILabel!
    @IBOutlet weak var serie_medidor: UILabel!
    @IBOutlet weak var ultimo_consumo: UILabel!
    
    @IBOutlet weak var contenedor1_1: UIView!
    @IBOutlet weak var contenedor1_2: UIView!
    
    @IBOutlet weak var cem_label: UILabel!
    @IBOutlet weak var iva_label: UILabel!
    @IBOutlet weak var interes_label: UILabel!
    @IBOutlet weak var interagua_label: UILabel!
    @IBOutlet weak var trb_label: UILabel!
    
    @IBOutlet weak var btn_cambioView: UIButton!
    let img_chartPie = UIImage(named: "ic_pie_chart_black_24dp")
    let img_detallePie = UIImage(named: "ic_menu_black_24dp")
    
    var detalleSeleccionado1 = true
    
    var detailAccountItem = detailAccount.init(facturas_vencidas: "", deuda_diferida: "", max_fecha_pago: "", tipo_medidor: "", serie_medidor: "", consumo: "", estado_corte: "", contrato: "", cliente: "", uso_servicio: "", direccion: "", ci_ruc: "", id_direccion: "", id_direccion_contrato: "", id_producto: "", id_cliente: "", deuda_pendiente: "", servicio: "", alias: "")
    
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var collection: UICollectionView!
    
    
    var colors:[UIColor] = []
    var total_deb = 0.0
    var dataPie = [PieChartDataEntry]()
    @IBOutlet weak var saldo: UILabel!
    @IBOutlet weak var imgButton: UIButton!
    
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    //++++++++++ SECCION PARA FACTURAS +++++++++++++++++++++++
    
    let img_dolares = UIImage(named: "iconoDolar")
    let img_recaudacion = UIImage(named: "recaudacionAzul")
    let img_facturas = UIImage(named: "iconoFacturaAmarillo")
    var facturas : [Bill] = [Bill]() // list of options
    var pagos : [Bill] = [Bill]() // list of options
    
    @IBOutlet weak var tablaContenedor2: UITableView!
    
    var moneyC2 = false
    
    @IBOutlet weak var btn_cambioVistaC2: UIButton!
    
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    //++++++++++ SECCION PARA CONSUMOS +++++++++++++++++++++++
    
    @IBOutlet weak var barView: BarChartView!
    @IBOutlet weak var btn_cambioViewC3: UIButton!
    
    var dataChartC3 = [BarChartDataEntry]()
    var moneyC3:[Double] = []
    var money_mesesC3:[String] = []
    var consumoC3:[Double] = []
    var consumo_mesesC3:[String] = []
    
    var typeC3 = true
    
    let meses = ["Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"]
    
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    //++++++++++ SECCION PARA TRAMITES +++++++++++++++++++++++
    
    @IBOutlet weak var tableViewC4: UITableView!
    
    
    var listaProcesos : [Process] = [Process]()
    
    var contrato = ""
    var servicio = ""
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    var listaFacturas = [billsAccount]()
    
    
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
        
        let status = dbase.connect_db()
        
        //+++++++++++++++++++++++++++DEUDA+++++++++++++++++++++++++++++
        
        //collection.delegate = self
        collection.dataSource = self
        
        widthView1.constant = (self.view.bounds.width/2)-12
        widthView2.constant = (self.view.bounds.width/2)-12
        
        //llenar pestaña DETALLES
        cliente.text = detailAccountItem.cliente
        uso_comercial.text = detailAccountItem.uso_servicio
        ci_ruc.text = detailAccountItem.ci_ruc
        direccion.text = detailAccountItem.direccion
        
        facturas_vencidas.text = detailAccountItem.facturas_vencidas
        max_fecha_pago.text = detailAccountItem.max_fecha_pago
        deuda_diferido.text = detailAccountItem.deuda_diferida
        
        tipo_medidor.text = detailAccountItem.tipo_medidor
        serie_medidor.text = detailAccountItem.serie_medidor
        ultimo_consumo.text = detailAccountItem.consumo
        
        cuentaTitle.text = detailAccountItem.contrato
        aliasTitle.text = detailAccountItem.alias
        
        
        btn_cambioView.layer.cornerRadius = 0.5 * btn_cambioView.bounds.size.width
        btn_cambioView.clipsToBounds = true
        
        
        if( status.value ){
            print("entra a buscar detalles de cuenta")
            let debs_list = self.dbase.getDetailDebs(service: contrato)
            
            for item in debs_list{
                let detail_data = PieChartDataEntry(value: Double(item.valor)!)
                detail_data.label = item.nombre
        
                dataPie.append(detail_data)
                
                total_deb = total_deb + Double(item.valor)!
                
            }
        }
        
        if total_deb == 0.0{
            saldo.text = "Al Dia"
            saldo.textColor = UIColor.black
            imgButton.setImage(UIImage(named: "check_verde.png" ), for: .normal)
            dataPie = []
            let detail_data = PieChartDataEntry(value: Double(100))
            detail_data.label = "No tiene deuda"
            dataPie.append(detail_data)
            
        }else{
            saldo.text = "Saldo $\(total_deb)"
            imgButton.setImage(UIImage(named: "ic_money.png" ), for: .normal)
            saldo.textColor = UIColor.red
        }
        
        colors.append(UIColor(red:0.00/255.00, green:140.00/255.00, blue:0.00/255.00, alpha: 1))
        colors.append(UIColor(red:103.00/255.00, green:58.00/255.00, blue:183.00/255.00, alpha: 1))
        colors.append(UIColor(red:255.00/255.00, green:152.00/255.00, blue:0.00/255.00, alpha: 1))
        colors.append(UIColor(red:63.00/255.00, green:81.00/255.00, blue:181.00/255.00, alpha: 1))
        colors.append(UIColor(red:33.00/255.00, green:150.00/255.00, blue:243.00/255.00, alpha: 1))
        colors.append(UIColor(red:255.00/255.00, green:193.00/255.00, blue:7.00/255.00, alpha: 1))
        colors.append(UIColor(red:0.00/255.00, green:188.00/255.00, blue:212.00/255.00, alpha: 1))
        colors.append(UIColor(red:205.00/255.00, green:220.00/255.00, blue:57.00/255.00, alpha: 1))
        colors.append(UIColor(red:49.00/255.00, green:27.00/255.00, blue:146.00/255.00, alpha: 1))
        colors.append(UIColor(red:230.00/255.00, green:81.00/255.00, blue:0.00/255.00, alpha: 1))       //#E65100
        colors.append(UIColor(red:26.00/255.00, green:35.00/255.00, blue:126.00/255.00, alpha: 1))      //#1A237E
        colors.append(UIColor(red:21.00/255.00, green:101.00/255.00, blue:192.00/255.00, alpha: 1))     //#1565C0
        colors.append(UIColor(red:255.00/255.00, green:111.00/255.00, blue:0.00/255.00, alpha: 1))      //#FF6F00
        colors.append(UIColor(red:230.00/255.00, green:81.00/255.00, blue:0.00/255.00, alpha: 1))       //#E65100
        colors.append(UIColor(red:26.00/255.00, green:35.00/255.00, blue:126.00/255.00, alpha: 1))      //#1A237E
        colors.append(UIColor(red:21.00/255.00, green:101.00/255.00, blue:192.00/255.00, alpha: 1))     //#1565C0
        colors.append(UIColor(red:255.00/255.00, green:111.00/255.00, blue:0.00/255.00, alpha: 1))      //#FF6F00
        colors.append(UIColor(red:230.00/255.00, green:81.00/255.00, blue:0.00/255.00, alpha: 1))       //#E65100
        colors.append(UIColor(red:26.00/255.00, green:35.00/255.00, blue:126.00/255.00, alpha: 1))      //#1A237E
        colors.append(UIColor(red:21.00/255.00, green:101.00/255.00, blue:192.00/255.00, alpha: 1))     //#1565C0
        colors.append(UIColor(red:255.00/255.00, green:111.00/255.00, blue:0.00/255.00, alpha: 1))      //#FF6F00
        
        updateChartData()
        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        //++++++++++++++++++++++++++++FACTURAS+++++++++++++++++++++++++++++++++
        tablaContenedor2.delegate = self
        tablaContenedor2.dataSource = self
        
        btn_cambioVistaC2.layer.cornerRadius = 0.5 * btn_cambioVistaC2.bounds.size.width
        btn_cambioVistaC2.clipsToBounds = true
        
        if( status.value ){
            print("entra a buscar detalles faturas y pagos")
            let detail_payment_list = self.dbase.getDetailPaymentT(service: contrato)
            
            listaFacturas = self.dbase.getBillsAccount(service: contrato)
            var i = 0
            for item in detail_payment_list{
                self.pagos.append(Bill.init(name: getMonthString(date: item.fecha_pago,1), enabled: false, index: i, date_ini: getLabelDate(date: item.fecha_pago,1), date_end: "", value: item.monto_pago, type: "", code: item.codigo_pago))
                
                i += 1
            }
            
            i = 0
            for item in listaFacturas{
                self.facturas.append(Bill.init(name: getMonthString(date: item.fecha_emision,2), enabled: false, index: i, date_ini: getLabelDate(date: item.fecha_emision,2), date_end: getLabelDate(date: item.fecha_vencimiento,2), value: item.monto_factura, type: item.estado_factura, code: item.codigo_factura))
                
                i += 1
            }
        }

        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        //++++++++++++++++++++++++++++++CONSUMOS+++++++++++++++++++++++++++++++
        
        btn_cambioViewC3.layer.cornerRadius = 0.5 * btn_cambioViewC3.bounds.size.width
        btn_cambioViewC3.clipsToBounds = true
        
        if( status.value ){
            print("entra a buscar detalles faturas")
            
            //let bills_list = self.dbase.getBillsAccount(service: detailAccountItem.servicio)
            
            for item in listaFacturas{
                print(item.consumo_kwh)
                print(Double(item.consumo_kwh)!)
                
                moneyC3.append(Double(item.monto_factura)!)
                money_mesesC3.append(getOnlyMonthString(date: item.fecha_emision,2))
                
                consumoC3.append(Double(item.consumo_kwh)!)
                consumo_mesesC3.append(getOnlyMonthString(date: item.fecha_emision,2))
                
            }
        
            moneyC3.reverse()
            money_mesesC3.reverse()
            consumoC3.reverse()
            consumo_mesesC3.reverse()
            
        }
        
        barView.drawBarShadowEnabled = false
        barView.drawValueAboveBarEnabled = false
        
        updateChartDataC3()
        
        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        
        //+++++++++++++++++++++++++++++++TRAMITES++++++++++++++++++++++++++++++
        
        tableViewC4.delegate = self
        tableViewC4.dataSource = self
        
        if( status.value ){
            print("entra en buscar tramites")
            
            let list = self.dbase.getDetailsProcedures(service: detailAccountItem.servicio)
            for item in list{
                print(item)
                
                var title = ""
                var descripcion = ""
                var estado = ""
                var new_date_ini = ""
                var new_date_end = ""
                
                do{
                    if item.descripcion != ""{
                        title = try subStringProcess(text: item.descripcion, char: "-").uppercased()
                    }
                }catch{
                    print("error convirtiendo titulo")
                }
                do{
                    if item.descripcion3 != ""{
                        descripcion = subStringProcess(text: item.descripcion3, char: "-").uppercased()
                    }
                }catch{
                    print("error convirtiendo descripcion")
                }
                
                do{
                    if item.estado != ""{
                        estado = subStringProcess(text: item.estado, char: "-").uppercased()
                    }
                    
                }catch{
                    print("error convirtiendo estado")
                }
                
                do{
                    if item.fecha_inicio != ""{
                        new_date_ini = getLabelDate(date: item.fecha_inicio,3)
                    }
                }catch{
                    print("error convirtiendo fecha ini")
                }
                
                do{
                    if item.fecha_fin != ""{
                        new_date_end = getLabelDate(date: item.fecha_fin,3)
                    }
                }catch{
                    print("error convirtiendo fecha ini")
                }
                
                
                listaProcesos.append(Process.init(title, descripcion, item.codigo, estado , new_date_ini, UIImage(named: "proceso")!, false, new_date_end , item.json))
                
            }
        }
        
        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
    }
    
    
    
    @IBAction func deudaAccion(_ sender: Any) {
        Btn_deuda.setTitleColor(UIColor.orange, for: .normal)
        Btn_facturas.setTitleColor(UIColor.white, for: .normal)
        Btn_consumos.setTitleColor(UIColor.white, for: .normal)
        Btn_tramites.setTitleColor(UIColor.white, for: .normal)
        
        border.frame = CGRect(x: 0, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        moverViewScroll(valor: CGFloat(0.0))
        ventanaSeleccionada = 1
    }
    
    @IBAction func facturasAccion(_ sender: Any) {
        Btn_deuda.setTitleColor(UIColor.white, for: .normal)
        Btn_facturas.setTitleColor(UIColor.orange, for: .normal)
        Btn_consumos.setTitleColor(UIColor.white, for: .normal)
        Btn_tramites.setTitleColor(UIColor.white, for: .normal)
        
        border.frame = CGRect(x: width/4, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        moverViewScroll(valor: -1*width)
        ventanaSeleccionada = 2
    }
    
    @IBAction func consumoAccion(_ sender: Any) {
        Btn_deuda.setTitleColor(UIColor.white, for: .normal)
        Btn_facturas.setTitleColor(UIColor.white, for: .normal)
        Btn_consumos.setTitleColor(UIColor.orange, for: .normal)
        Btn_tramites.setTitleColor(UIColor.white, for: .normal)
        
        border.frame = CGRect(x: 2*(width/4), y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        moverViewScroll(valor: -2*width)
        ventanaSeleccionada = 3
    }
    
    @IBAction func tramitesAccion(_ sender: Any) {
        Btn_deuda.setTitleColor(UIColor.white, for: .normal)
        Btn_facturas.setTitleColor(UIColor.white, for: .normal)
        Btn_consumos.setTitleColor(UIColor.white, for: .normal)
        Btn_tramites.setTitleColor(UIColor.orange, for: .normal)
        
        border.frame = CGRect(x: 3*(width/4), y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
        
        moverViewScroll(valor: -3*width)
        ventanaSeleccionada = 4
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
    
    
    
    //++++++++++++++++++++++++++++++++++++++++++DEUDA+++++++++++++++++++++
    func updateChartData(){
        let dataSet = PieChartDataSet(values: self.dataPie, label: nil)
        dataSet.drawValuesEnabled = false
        dataSet.colors = colors
        dataSet.selectionShift = 0
        let charData = PieChartData(dataSet: dataSet)
        
        
        
        pieChart.data = charData
        pieChart.drawEntryLabelsEnabled = false
        
        pieChart.legend.enabled = false
        
        //legend.horizontalAlignment = .center
        
        //legend.verticalAlignment = .bottom
        //legend.orientation = .vertical
        //legend.form = .circle
        
        //legend.yEntrySpace = 2
        //legend.xEntrySpace = 10
        //legend.formLineWidth = width
        
        //legend.drawInside = false
        //legend.font = UIFont(name: "HelveticaNeue", size: 13.0)!
        
        pieChart.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
        
    }
    
    @IBAction func cambiarVista(_ sender: Any) {
        
        if self.detalleSeleccionado1{
            self.contenedor1_1.isHidden = false
            self.contenedor1_2.isHidden = true
            self.btn_cambioView.setImage(self.img_chartPie, for: .normal)
        }else{
            self.contenedor1_1.isHidden = true
            self.contenedor1_2.isHidden = false
            self.btn_cambioView.setImage(self.img_detallePie, for: .normal)
        }
        
        self.detalleSeleccionado1 = !self.detalleSeleccionado1
    }
    
    @IBAction func pagar(_ sender: Any) {
        if total_deb != 0.0{
            let alert = UIAlertController(title: nil, message: "Seguro que desea pagar su deuda de manera Online?", preferredStyle: .alert);
            let btn_alert = UIAlertAction(title: "Aceptar", style: .default) { (UIAlertAction) in
                print("pagar deuda")
            }
            let btn_cancel = UIAlertAction(title: "Cancelar", style: .destructive) { (UIAlertAction) in
                
            }
            alert.addAction(btn_alert);
            alert.addAction(btn_cancel);
            self.present(alert, animated: true, completion: nil);
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return dataPie.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! Custom2CollectionViewCell
        
        cell.detalle.text = dataPie[indexPath.row].label
        if total_deb == 0.0{
            cell.valor.text = ""
        }else{
            cell.valor.text = "\(dataPie[indexPath.row].value)"
        }
        
        cell.vista.backgroundColor = colors[indexPath.row]
        cell.vista.layer.cornerRadius = 0.5 * cell.vista.bounds.size.width
        cell.vista.clipsToBounds = true
        
        return cell
    }
    
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    
    //++++++++++++++++++++++++++++++++++++++++++FACTURAS+++++++++++++++++++++
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tablaContenedor2{
            if moneyC2{
                return self.pagos.count
            }else{
                return self.facturas.count
            }
        }else
            if tableView == tableViewC4 {
                return listaProcesos.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tablaContenedor2{
            if !moneyC2{
                let cell = Bundle.main.loadNibNamed("CustomTableViewCell2", owner: self, options: nil)?.first as! CustomTableViewCell2
                
                
                cell.title.text = facturas[indexPath.row].name
                cell.label_cost.text = facturas[indexPath.row].type
                cell.cost.text = facturas[indexPath.row].value
                cell.date_first.text = facturas[indexPath.row].date_ini
                cell.date_second.text = facturas[indexPath.row].date_end
                //cell.img.image = UIImage(named: "iconoFactura")
                
                return cell
            }else{
                let cell = Bundle.main.loadNibNamed("CustomTableViewCell2", owner: self, options: nil)?.first as! CustomTableViewCell2
                
                
                cell.title.text = pagos[indexPath.row].name
                cell.label_cost.text = pagos[indexPath.row].date_ini
                cell.cost.text = pagos[indexPath.row].value
                cell.label_date_first.text = ""
                cell.label_date_second.text = ""
                cell.date_first.text = ""
                cell.date_second.text = ""
                cell.img.image = UIImage(named: "iconoDolar")
                return cell
            }
        }else
            if tableView == tableViewC4 {
                let cell = Bundle.main.loadNibNamed("CustomTableViewCell4", owner: self, options: nil)?.first as! CustomTableViewCell4
                
                
                cell.titleView.text = listaProcesos[indexPath.row].title
                cell.subtitleView.text = listaProcesos[indexPath.row].subtitle
                cell.codeView.text = listaProcesos[indexPath.row].code
                cell.statusView.text = listaProcesos[indexPath.row].status
                cell.dateView.text = listaProcesos[indexPath.row].date
                cell.imgView.image = listaProcesos[indexPath.row].img
                
                return cell
        }
        
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //if money{
        //    return 50
        //}else{
            return 60
        //}
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       if tableView == tableViewC4 {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "StatusProcessViewController") as! StatusProcessViewController
        let nombre = self.aliasTitle.text
        let cod = self.cuentaTitle.text
        viewController.titleView = "\(nombre ?? "") - \(cod ?? "")"
        viewController.process = listaProcesos[indexPath.row]
        self.present(viewController, animated: true)
        }
        
        
    }
    
    @IBAction func cambiarVistaC2(_ sender: Any) {
        if moneyC2{
            moneyC2 = false
            tablaContenedor2.reloadData()
            btn_cambioVistaC2.setImage(nil, for: .normal)
            Btn_facturas.setTitle("Facturas Emitidas", for: .normal)
        }else{
            moneyC2 = true
            tablaContenedor2.reloadData()
            btn_cambioVistaC2.setImage(self.img_facturas, for: .normal)
            Btn_facturas.setTitle("Pagos Realizados", for: .normal)
        }
    }
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    //++++++++++++++++++++++++++++++++++++++++++CONSUMOS+++++++++++++++++++++
    
    func updateChartDataC3(){
        
        let xAxis = barView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        
        let l = barView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formSize = 9
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.xEntrySpace = 4
        
        let leftAxisFormatter = NumberFormatter()
        
        var i = 0
        dataChartC3 = []
        var months = [String]()
        if typeC3 {
            
            leftAxisFormatter.minimumFractionDigits = 0
            leftAxisFormatter.maximumFractionDigits = 1
            leftAxisFormatter.positivePrefix = ""
            leftAxisFormatter.negativePrefix = ""
            
            months = consumo_mesesC3
            for item in consumoC3{
                
                let detail = BarChartDataEntry(x: Double(i), y: item)
                dataChartC3.append(detail)
                i+=1
            }
        }else{
            
            leftAxisFormatter.minimumFractionDigits = 0
            leftAxisFormatter.maximumFractionDigits = 1
            leftAxisFormatter.negativePrefix = "$ "
            leftAxisFormatter.positivePrefix = "$ "
            
            months = money_mesesC3
            for item in moneyC3{
                
                let detail = BarChartDataEntry(x: Double(i), y: item)
                dataChartC3.append(detail)
                i+=1
            }
        }
        
        let leftAxis = barView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
        
        let rightAxis = barView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelFont = .systemFont(ofSize: 10)
        rightAxis.labelCount = 8
        rightAxis.valueFormatter = leftAxis.valueFormatter
        rightAxis.spaceTop = 0.15
        rightAxis.axisMinimum = 0
        
        let dataSet = BarChartDataSet(values: self.dataChartC3, label: nil)
        let charData = BarChartData(dataSet: dataSet)
        
        
        
        dataSet.colors = colors
        
        barView.data = charData
        barView.xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        barView.xAxis.granularity = 1
        
        barView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
        
    }
    
    @IBAction func cambiarVistaC3(_ sender: Any) {
        
        if self.typeC3{
            self.typeC3 = false
            updateChartDataC3()
            btn_cambioViewC3.setTitle("m3", for: .normal)
            Btn_consumos.setTitle("Consumos $", for: .normal)
        }else{
            self.typeC3 = true
            updateChartDataC3()
            btn_cambioViewC3.setTitle("$", for: .normal)
            Btn_consumos.setTitle("Consumos m3", for: .normal)
        }
        
    }
    
    
    
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    //++++++++++++++++++++++++++++++++++++++++++TRAMITES+++++++++++++++++++++
    
    @IBAction func nuevoTramite(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Nuevo Trámite", message: "Escoja el tipo de trámite que desea crear", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Solicitudes Técnicas", style: .default, handler: { (action: UIAlertAction) in
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SolTecnicasViewController") as! SolTecnicasViewController
            viewController.servicio = self.contrato
            self.present(viewController, animated: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Reclamos por Facturación", style: .default, handler: { (action: UIAlertAction) in
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ReclamosViewController") as! ReclamosViewController
            viewController.servicio = self.contrato
            self.present(viewController, animated: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
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
                    
                    Btn_deuda.setTitleColor(UIColor.orange, for: .normal)
                    Btn_facturas.setTitleColor(UIColor.white, for: .normal)
                    Btn_consumos.setTitleColor(UIColor.white, for: .normal)
                    Btn_tramites.setTitleColor(UIColor.white, for: .normal)
                    
                    border.frame = CGRect(x: 0, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
                    
                    moverViewScroll(valor: CGFloat(0.0))
                    ventanaSeleccionada = 1
                    
                    
                }else
                    if ventanaSeleccionada == 3{
                        Btn_deuda.setTitleColor(UIColor.white, for: .normal)
                        Btn_facturas.setTitleColor(UIColor.orange, for: .normal)
                        Btn_consumos.setTitleColor(UIColor.white, for: .normal)
                        Btn_tramites.setTitleColor(UIColor.white, for: .normal)
                        
                        border.frame = CGRect(x: width/4, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
                        
                        UIApplication.shared.applicationIconBadgeNumber = 0
                        
                        moverViewScroll(valor: -1*width)
                        ventanaSeleccionada = 2
                        
                        
                    }else
                        if ventanaSeleccionada == 4{
                            Btn_deuda.setTitleColor(UIColor.white, for: .normal)
                            Btn_facturas.setTitleColor(UIColor.white, for: .normal)
                            Btn_consumos.setTitleColor(UIColor.orange, for: .normal)
                            Btn_tramites.setTitleColor(UIColor.white, for: .normal)
                            
                            border.frame = CGRect(x: 2*(width/4), y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
                            
                            moverViewScroll(valor: -2*width)
                            ventanaSeleccionada = 3
            }
            
            
        case 2:
            print("left")
            if ventanaSeleccionada == 1{
                Btn_deuda.setTitleColor(UIColor.white, for: .normal)
                Btn_facturas.setTitleColor(UIColor.orange, for: .normal)
                Btn_consumos.setTitleColor(UIColor.white, for: .normal)
                Btn_tramites.setTitleColor(UIColor.white, for: .normal)
                
                border.frame = CGRect(x: width/4, y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
                
                UIApplication.shared.applicationIconBadgeNumber = 0
                
                moverViewScroll(valor: -1*width)
                ventanaSeleccionada = 2
            }else
                if ventanaSeleccionada == 2{
                    Btn_deuda.setTitleColor(UIColor.white, for: .normal)
                    Btn_facturas.setTitleColor(UIColor.white, for: .normal)
                    Btn_consumos.setTitleColor(UIColor.orange, for: .normal)
                    Btn_tramites.setTitleColor(UIColor.white, for: .normal)
                    
                    border.frame = CGRect(x: 2*(width/4), y: menuView.frame.size.height - width2, width: width/4, height: menuView.frame.size.height)
                    
                    moverViewScroll(valor: -2*width)
                    ventanaSeleccionada = 3
                }else
                    if ventanaSeleccionada == 3{
                        Btn_deuda.setTitleColor(UIColor.white, for: .normal)
                        Btn_facturas.setTitleColor(UIColor.white, for: .normal)
                        Btn_consumos.setTitleColor(UIColor.white, for: .normal)
                        Btn_tramites.setTitleColor(UIColor.orange, for: .normal)
                        
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
