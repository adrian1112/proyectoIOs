//
//  ReclamosViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 16/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit
import SQLite
import Zip

class ReclamosViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let dbase = DBase();
    var db: Connection!
    
    var bills : [Bill] = [Bill]() // list of options
    
    
    
    @IBOutlet weak var select1: UITextField!
    @IBOutlet weak var select2: UITextField!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var telefono: UITextField!
    @IBOutlet weak var obs: UITextView!
    
    
    @IBOutlet weak var textView_label: UITextView!
    
    @IBOutlet weak var tableBills: UITableView!
    
    
    //let options=["","Opcion1","Opcion2","Opcion3","Opcion4","Opcion5"]
    var options = [String]()
    var options_services = [String]()
    
    let options2=["","Alta Facturacion","Inexistencia de Alcantarillado","Inexistencia de guía","Diámetro de guía errado"]
    
    let options3=["","Incremento de consumo en planilla de agua potable, recuerde siempre mantener en buen estado sus instalaciones internas para evitar un consumo no justificado de agua potable.","Predio no descarga en redes de aguas servidas.","Guía no instalada en el predio.","Cuando el diámetro de conexión del predio no es el que fue solicitado."]
    
    let myBackgroundColor1 = UIColor(red: 121/255.0, green: 190/255.0, blue: 255/255.0, alpha: 1.0)
    
    let myBackgroundColor = UIColor(red: 235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1.0)
    
    var pickerView1 = UIPickerView()
    var pickerView2 = UIPickerView()
    
    var servicio = ""
    
    var accounts = [account]()
    
    var bills_list = [billsAccount]()
    
    var account_selected = ""
    var id_account_selected = ""
    
    @IBOutlet weak var tickButton: UIButton!
    
    let image_r = UIImage(named: "tick-2.png")
    var selectAll = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsWhenKeyboardAppears = false
        
        
        pickerView1.delegate = self
        pickerView1.dataSource = self
        pickerView1.backgroundColor = myBackgroundColor
        pickerView2.delegate = self
        pickerView2.dataSource = self
        pickerView2.backgroundColor = myBackgroundColor
        select1.inputView = pickerView1
        select2.inputView = pickerView2
        
        tableBills.delegate = self
        tableBills.dataSource = self
        
        obs.layer.borderWidth = 1
        obs.layer.borderColor = UIColor.lightGray.cgColor
        
        let status = dbase.connect_db()
        if( status.value ){
            print("entra a buscar contratos")
            accounts = self.dbase.getAccounts()
            for item in accounts{
                options.append(item.alias)
                options_services.append(item.service)
            }
            
            bills_list = self.dbase.getAllBillsAccount()
            
        }
        
        select2.isEnabled = false
        
        if servicio != "" {
            for item in accounts{
                if item.service == servicio{
                    self.account_selected = item.alias
                    self.id_account_selected = item.service
                    select1.text = item.alias
                    select1.isEnabled = false
                    select2.isEnabled = true
                    
                    self.account_selected = item.alias
                    self.id_account_selected = item.service
                    
                    var i = 0
                    self.bills = []
                    for item in bills_list{
                        if( self.id_account_selected == item.servicio){
                            self.bills.append(Bill.init(name: getMonthString(date: item.fecha_emision,2), enabled: false, index: i, date_ini: getLabelDate(date: item.fecha_emision,2), date_end: getLabelDate(date: item.fecha_vencimiento,2), value: item.monto_factura, type: item.estado_factura, code: item.codigo_factura))
                            
                            i += 1
                        }
                        
                    }
                    self.tableBills.reloadData()
                    
                }
            }
            
        }
        
    }
    
    @IBAction func tickAction(_ sender: UIButton) {
        if selectAll {
            self.tickButton.setImage(nil, for: UIControl.State.normal)
            self.selectAll = false
            if self.bills.count > 0{
                for index in 0...self.bills.count-1 {
                    self.bills[index].enabled = false
                }
                self.tableBills.reloadData()
            }
            
        }else{
            self.tickButton.setImage(self.image_r, for: UIControl.State.normal)
            self.selectAll = true
            
            if self.bills.count > 0{
                for index in 0...self.bills.count-1 {
                    self.bills[index].enabled = true
                }
                self.tableBills.reloadData()
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("CustomTableViewCell2", owner: self, options: nil)?.first as! CustomTableViewCell2
        
        
        cell.title.text = bills[indexPath.row].name
        cell.accessoryType = bills[indexPath.row].enabled ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        //cell.mainMessage.text = data[indexPath.row].message
        //cell.mainDate.text = ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected", indexPath.row)
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
        // save the value in the array
        let index = (indexPath as NSIndexPath).row
        bills[index].enabled = !bills[index].enabled
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerView == pickerView1 {
            return self.options.count
        } else if pickerView == pickerView2{
            return self.options2.count
        }else{
            return 0
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: 12)
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.textColor = UIColor.blue
        //pickerLabel?.textColor = UIColor(red: 62/255.0, green: 160/255.0, blue: 230/255.0, alpha: 1.0)
        
        if pickerView == pickerView1 {
            pickerLabel?.text = self.options[row]
        } else if pickerView == pickerView2{
            pickerLabel?.text = self.options2[row]
        }
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return ""
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == pickerView1 {
            self.select1.text = self.options[row]
            self.select1.resignFirstResponder()
            self.select2.isEnabled = true
            
            self.account_selected = self.options[row]
            self.id_account_selected = self.options_services[row]
            
            var i = 0
            self.bills = []
            for item in bills_list{
                
                if( self.id_account_selected == item.servicio){
                    self.bills.append(Bill.init(name: getMonthString(date: item.fecha_emision,2), enabled: false, index: i, date_ini: getLabelDate(date: item.fecha_emision,2), date_end: getLabelDate(date: item.fecha_vencimiento,2), value: item.monto_factura, type: item.estado_factura, code: item.codigo_factura))
                    
                    i += 1
                }
                
            }
            self.tableBills.reloadData()
            
        } else if pickerView == pickerView2{
            self.select2.text = self.options2[row]
            self.select2.resignFirstResponder()
            self.textView_label.text = self.options3[row]
            
            /*self.bills = [Bill.init(name: "Factura1", enabled: false,index: 1, date_ini: "", date_end: "", value: "", type: ""),Bill.init(name: "Factura2", enabled: false,index: 2, date_ini: "", date_end: "", value: "", type: ""),Bill.init(name: "Factura3", enabled: false,index: 3, date_ini: "", date_end: "", value: "", type: ""),Bill.init(name: "Factura4", enabled: false,index: 4, date_ini: "", date_end: "", value: "", type: "")]*/
            
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        
        self.picture.image = image
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Origen de la foto", message: "Escoja una opción", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cámara", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }else{
                print("camara no disponible")
                self.showAlert(txt_alert: "Cámara no disponible")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Galeria", style: .default, handler: { (action: UIAlertAction) in imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func Back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func Send(_ sender: UIButton) {
        let service = self.id_account_selected
        let telefono = self.telefono.text?.trimmingCharacters(in: .whitespaces)
        let obs = self.obs.text
        let tipo = select2.text
        var facturas = [String]()
        
        for item in self.bills{
            if item.enabled {
                facturas .append(item.code)
            }
        }
        if service == ""{
            showAlert(txt_alert: "Por favor, seleccione el contrato")
            return
        }
        if telefono == ""{
            showAlert(txt_alert: "El campo Teléfono no puede quedar vacío")
            return
        }
        if (telefono?.count)! < 7{
            showAlert(txt_alert: "Por favor, ingrese un teléfono válido")
            return
        }
        if obs?.trimmingCharacters(in: .whitespaces) == ""{
            showAlert(txt_alert: "Por favor, seleccione el contrato")
            return
        }
        if service == ""{
            showAlert(txt_alert: "Por favor, seleccione el contrato")
            return
        }
        if facturas.count == 0{
            showAlert(txt_alert: "Por favor, seleccione la(s) facturas relacionadas")
            return
        }
        
        print("ok")
        
        
        //dismiss(animated: true)
    }
    
    //HABILITA LA OPCION DE OCULTAR EL TECLADO CUANDO SE LE DA EN CUALQUIER PARTE DE LA PANTALLA Y PARA MOVER LA VIEW SI EL TECLADO OCULTA EL TEXTFIELD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func showAlert(txt_alert: String){
        print("entra a alerta")
        let alert = UIAlertController(title: nil, message: txt_alert, preferredStyle: .alert);
        let btn_alert = UIAlertAction(title: "Cerrar", style: .cancel)
        alert.addAction(btn_alert);
        self.present(alert, animated: true, completion: nil);
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        
        do {
            try data.write(to: directory.appendingPathComponent("rec_facturacion.png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func zipImage() -> Bool{
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        
        let n_directory = directory.appendingPathComponent("rec_facturacion.png")
        do {
            let zipFilePath = try Zip.quickZipFiles([n_directory!], fileName: "archive") // Zip
            
        }
        catch {
            print("Something went wrong")
            return false
        }
        
        return true
    }
    
    
    
}
