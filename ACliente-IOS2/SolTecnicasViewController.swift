//
//  SolTecnicasViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 16/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit
import SQLite
import Zip

class SolTecnicasViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    let dbase = DBase();
    var db: Connection!
    
    @IBOutlet weak var select1: UITextField!
    @IBOutlet weak var select2: UITextField!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var telephone: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var textView_label: UITextView!
    
    //let options=["","Opcion1","Opcion2","Opcion3","Opcion4","Opcion5"]
    var options = [String]()
    var options_services = [String]()
    
    var servicio = ""
    
    let options2=["","Falta de tapa de alcantarilla","Fuga de agua en cajetin de medidor","Fuga de agua en la guía","Limpieza de caja de alcantarillado"]
    
    let options3=["","Instalación de tapa de alcantarilla domiciliaria.","Se observa fuga en el interior del cajetín medidor.","Se observa fuga en la guía domiciliaria, usualmente ubicada después del medidor o en a vereda","Limpieza de la caja que se encuentra fuera del domicilio y que corresponde a aguas servidas."]
    
    var pickerView1 = UIPickerView()
    var pickerView2 = UIPickerView()
    
    let myBackgroundColor1 = UIColor(red: 121/255.0, green: 190/255.0, blue: 255/255.0, alpha: 1.0)
    
    let myBackgroundColor = UIColor(red: 235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1.0)
    
    var keyboardHeight :CGFloat = 216.0
    
    
    var accounts = [account]()
    
    var account_selected = ""
    var id_account_selected = ""
    
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
        
        textView.delegate = self
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        
        let status = dbase.connect_db()
        if( status.value ){
            print("entra a buscar contratos")
            accounts = self.dbase.getAccounts()
            for item in accounts{
                options.append(item.alias)
                options_services.append(item.service)
            }
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
                }
            }
            
        }
        
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
            self.account_selected = self.options[row]
            self.id_account_selected = self.options_services[row]
            
            if( self.select1.text == ""){
                self.select2.text = ""
                select2.isEnabled = false
            }else{
                select2.isEnabled = true
            }
            self.select1.resignFirstResponder()
        } else if pickerView == pickerView2{
            self.select2.text = self.options2[row]
            self.select2.resignFirstResponder()
            self.textView_label.text = self.options3[row]
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        
        let success = saveImage(image: image)
        print("resultado: \(success)")
        
        let res = zipImage()
        print(res)
        
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
    
    func showAlert(txt_alert: String){
        print("entra a alerta")
        let alert = UIAlertController(title: nil, message: txt_alert, preferredStyle: .alert);
        let btn_alert = UIAlertAction(title: "Cerrar", style: .cancel)
        alert.addAction(btn_alert);
        self.present(alert, animated: true, completion: nil);
    }
    
    @IBAction func Send(_ sender: UIButton) {
        print("Envia")
        
        let service = self.id_account_selected
        let telephone = self.telephone.text?.trimmingCharacters(in: .whitespaces)
        let obs = self.textView.text
        let tipo = self.select2.text
        let img = picture.image
        
        if service == ""{
            showAlert(txt_alert: "Por favor, Seleccione el contrato")
            return
        }
        if telephone == "" {
            showAlert(txt_alert: "El campo Teléfono no puede quedar vacío")
            return
        }
        if (telephone?.count)! < 7 {
            showAlert(txt_alert: "Por favor, Ingrese  un telefono válido")
            return
        }
        if obs?.trimmingCharacters(in: .whitespaces) == ""{
            showAlert(txt_alert: "El campo Observación no puede quedar vacío")
            return
        }
        if tipo == ""{
            showAlert(txt_alert: "Por favor, Seleccione el Tipo de Reclamo")
            return
        }
        
        if img == nil {
            showAlert(txt_alert: "Por favor, cargar una imagen del motivo del reporte")
            return
        }
        
        print("ok")
        
        //dismiss(animated: true)
    }
    
    //HABILITA LA OPCION DE OCULTAR EL TECLADO CUANDO SE LE DA EN CUALQUIER PARTE DE LA PANTALLA Y PARA MOVER LA VIEW SI EL TECLADO OCULTA EL TEXTFIELD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("start")
        view.frame = CGRect(x:0.0,y:0.0, width: view.frame.width, height: view.frame.height)
        var viewFrameActual = view.frame
        print("viewframeactua: ",viewFrameActual.size.height)
        viewFrameActual.size.height -= keyboardHeight
        print("viewframeactua_heigth: ",viewFrameActual.size.height)
        
        let puntoEsquinaIzquierdaInferiorActiveField = CGPoint(x: textView.frame.origin.x, y: textView.frame.origin.y + textView.frame.height)
        print("puntoEsquinaIzquierdaInferiorActiveField: ",puntoEsquinaIzquierdaInferiorActiveField)
        
        if !viewFrameActual.contains(puntoEsquinaIzquierdaInferiorActiveField) {
            
            let newViewY = viewFrameActual.height - puntoEsquinaIzquierdaInferiorActiveField.y - 30.0
            print("newViewY: ",newViewY)
            
            let newViewFrame = CGRect(x: view.frame.origin.x, y: newViewY, width: view.frame.width,height: view.frame.height)
            print("newViewFrame: ",newViewFrame)
            
            UIView.animate(withDuration: 0.3) {
                self.view.frame = newViewFrame
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("end")
        
        self.view.frame = CGRect(x: 0.0,y: 0.0,width: self.view.frame.width, height: self.view.frame.height)
        
        
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        
        do {
            try data.write(to: directory.appendingPathComponent("sol_tecnicas.png")!)
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
        
        let n_directory = directory.appendingPathComponent("sol_tecnicas.png")
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
