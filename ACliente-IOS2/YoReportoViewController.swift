//
//  YoReportoViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 15/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class YoReportoViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var map: GMSMapView!
    @IBOutlet weak var select: UITextField!
    @IBOutlet weak var picture: UIImageView!
    
    @IBOutlet weak var direccion: UITextField!
    @IBOutlet weak var telefono: UITextField!
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var obs: UITextField!
    
    
    @IBOutlet weak var footViewController: UIView!
    
    weak var activeField: UITextField?
    
    let options=["","Fugas de Agua Potable","Falta de Tapa de Alcantarillado","Desborde de Aguas Servidas","Denuncia Fraudes"]
    var pickerView = UIPickerView()
    
    let locationManager = CLLocationManager()
    var userLatLong = CLLocationCoordinate2D(latitude: -2, longitude: -79)
    
    let myBackgroundColor = UIColor(red: 235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = true
        //navigationController?.hidesBarsOnTap = true
        navigationController?.hidesBarsWhenKeyboardAppears = false
        
        locationManager.delegate = self
        self.map.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureReconizer:)))
        //gesture.minimumPressDuration = 0.3
        //gesture.delaysTouchesBegan = true
        //gesture.delegate = self
        //self.map.addGestureRecognizer(gesture)
        let camera = GMSCameraPosition.camera(withLatitude: userLatLong.latitude,
                                              longitude: userLatLong.longitude,
                                              zoom: 18)
        self.map.camera = camera
        map.settings.zoomGestures = true
        map.settings.myLocationButton = true
        map.isMyLocationEnabled = true
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = myBackgroundColor
        select.inputView = pickerView

    }
    
    @IBAction func Back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    /*@objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            let touchLocation = gestureReconizer.location(in: map)
            //let locationCoordinate = map.convert(touchLocation,toCoordinateFrom: map)
            //print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
            
            //let pin1 = PinMap(title: "Reporte", subtitle: "Ubicacion del problema", coordinate: locationCoordinate)
            
            //map.removeAnnotations(pins as [MKAnnotation])
            //pins = []
            //pins.append(pin1)
            //map.addAnnotation(pin1)
            
            
            return
        }
        
        if gestureReconizer.state != UIGestureRecognizer.State.began {
            return
        }
    }*/
    
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        userLatLong = locations[0].coordinate
        print(locations[0].coordinate.latitude)
        print(locations[0].coordinate.longitude)
        
        let camera = GMSCameraPosition.camera(withLatitude: userLatLong.latitude,
                                              longitude: userLatLong.longitude,
                                              zoom: 18)
        self.map.camera = camera
        
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return self.options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: 12)
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.textColor = UIColor.blue
        pickerLabel?.text = self.options[row]
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.select.text = self.options[row]
        self.select.resignFirstResponder()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        
        self.picture.image = image
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(txt_alert: String){
        print("entra a alerta")
        let alert = UIAlertController(title: nil, message: txt_alert, preferredStyle: .alert);
        let btn_alert = UIAlertAction(title: "Cerrar", style: .cancel)
        alert.addAction(btn_alert);
        self.present(alert, animated: true, completion: nil);
    }
    
    //HABILITA LA OPCION DE OCULTAR EL TECLADO CUANDO SE LE DA EN CUALQUIER PARTE DE LA PANTALLA Y PARA MOVER LA VIEW SI EL TECLADO OCULTA EL TEXTFIELD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1. Escuchar las notificaciones del teclado.
        registerForKeyboardNotifications()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Siempre hay que dejar de escuchar las notificaciones.
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func startTextFieldEditing(_ sender: UITextField) {
        activeField = sender
        print("entra")
        
    }
    
    @IBAction func endTextFieldEditing(_ sender: UITextField) {
        activeField = nil
    }
    
    @IBAction func send(_ sender: UIButton) {
        print("validando los campos")
        let tipo_txt = select.text
        let direccion_txt = direccion.text
        let telefono_txt = telefono.text?.trimmingCharacters(in: .whitespaces)
        let mail_txt = mail.text?.trimmingCharacters(in: .whitespaces)
        let obs_txt = obs.text
        let img = picture.image
        
        if tipo_txt == ""{
            showAlert(txt_alert: "Por favor, Seleccione un Tipo de daño")
            return
        }
        if direccion_txt?.trimmingCharacters(in: .whitespaces) == ""{
            showAlert(txt_alert: "El campo Dirección no puede quedar vacío")
            return
        }
        
        if telefono_txt! == "" {
            showAlert(txt_alert: "El campo Teléfono no puede quedar vacío")
            return
        }
        if (telefono_txt?.count)! < 7{
            showAlert(txt_alert: "Por favor, ingrese un teléfono/celular válido")
            return
        }
        if !isValidEmail(string: mail_txt!){
            showAlert(txt_alert: "Por favor, ingrese un correo válido")
            return
        }
        if obs_txt?.trimmingCharacters(in: .whitespaces) == ""{
            showAlert(txt_alert: "El campo Descripción no puede quedar vacío")
            return
        }
        
        if img == nil {
            showAlert(txt_alert: "Por favor, cargar una imagen del motivo del reporte")
            return
        }
        
        if userLatLong.latitude == -2 && userLatLong.longitude == -79{
            showAlert(txt_alert: "No se pud actualizar las coordenadas actuales, estas son necesarias para enviar el reporte")
            return
        }
        
        print("ok")
        
        //enviar por ws el formulario
        
    }


}

extension YoReportoViewController: UITextFieldDelegate {
    // FUNCIONES PARA ESCUCHAR NOTIFICACIONES O EN ESTE CASO EVENTOS DEL TECLADO
    
    // Registro notificaciones teclado.
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Cuando el teclado se va a mostrar.
    @objc func keyboardWillShow(notification: NSNotification) {
        print("entra2")
        guard let activeField = self.activeField else {
            // Si activeField es nil, no se hace nada.
            print("activeField es nil")
            return
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            // Resetear el frame por si acaso.
            view.frame = CGRect(x:0.0,y:0.0, width: view.frame.width, height: view.frame.height)
            
            // Recuperar el frame actual de la view principal.
            var footviewFrameActual = footViewController.frame
            
            // Calcular la altura de la view principal restante al restarle la altura del teclado.
            footviewFrameActual.size.height -= keyboardSize.height
            
            // Calcular el punto situado en la esquina izquierda inferior de activeField.
            // (x: x, y: origin.y + height)
            let puntoEsquinaIzquierdaInferiorActiveField = CGPoint(x: activeField.frame.origin.x, y: activeField.frame.origin.y + activeField.frame.height)
            
            // Comprobar si el punto de la esquina izquierda inferior de activeField está contenido
            // en la viewFrameActual visible (lo que se ve encima del teclado).
            if !footviewFrameActual.contains(puntoEsquinaIzquierdaInferiorActiveField) {
                print("esta en frame")
                
                // El campo está oculto por el teclado.
                
                // Hay que mover la view principal hacia arriba.
                // Calcular el nuevo Y restando el punto inferior del campo Y a la viewFrameActual.
                // Además resto 8 más para darle holgura y no dejarlo pegado al teclado.
                let newViewY = self.view.frame.origin.y - puntoEsquinaIzquierdaInferiorActiveField.y - 8.0
                
                
                // Crear nuevo frame con la nueva Y. El resto de datos seguirá sin cambiar.
                let newViewFrame = CGRect(x: view.frame.origin.x, y: newViewY, width: view.frame.width,height: view.frame.height)
                
                // En conjunción con la duración de la animación del teclado.
                if let seconds = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                    UIView.animate(withDuration: seconds) {
                        self.view.frame = newViewFrame
                    }
                }
            }
            
        }
        
    }
    
    // Cuando el teclado se va a ocultar.
    @objc func keyboardWillHide(notification: NSNotification) {
        if let seconds = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            UIView.animate(withDuration: seconds) {
                print("entra  a ocultar")
                //self.footViewController.frame = CGRect(x: 0.0,y: self.footViewController.frame.origin.y,width: self.footViewController.frame.width, height: self.footViewController.frame.height)
                self.view.frame = CGRect(x: 0.0,y: 0.0,width: self.view.frame.width, height: self.view.frame.height)
            }
        }
    }
    
    
    
}
