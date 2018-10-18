//
//  CustomMapViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 12/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class CustomMapViewController: UIViewController,CLLocationManagerDelegate, GMSMapViewDelegate, UISearchBarDelegate,UITableViewDataSource, UITableViewDelegate  {

    let dbase = DBase()
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var navigateBtn: UIButton!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var blurViewTop: NSLayoutConstraint!
    @IBOutlet weak var mapViewBotton: NSLayoutConstraint!
    
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var addressView: UILabel!
    @IBOutlet weak var timeView: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var result: UITableView!
    var searchActive : Bool = false
    
    
    var userLatLong = CLLocationCoordinate2D(latitude: -2.162870, longitude: -79.898407)
    var placeLatLong = CLLocationCoordinate2D(latitude: -2.162870, longitude: -79.898407)
    
    var places = [
        place.init(name: "Agencia Centro", street: "Coronel y Maldonado", attention: "Lunes a viernes: 07:30 a 17:00 y Sábados: 09:00 a 13:00", coordinate: CLLocationCoordinate2D(latitude: -2.204457, longitude: -79.886952),selected: false, date_sync: ""),
        place.init(name: "Municipio de Guayaquil", street: "10 de Agosto y Pichincha, entrando por el callejon arosemena", attention: "Lunes a viernes: 08:30 a 16:30", coordinate: CLLocationCoordinate2D(latitude: -2.195159, longitude: -79.880961),selected: false, date_sync: "")
    ]
    
    var seleccionado = place.init(name: "", street: "", attention: "", coordinate: CLLocationCoordinate2D(latitude: -2.204457, longitude: -79.886952),selected: false, date_sync: "")
    
    
    var filteredPlaces = [place]()
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var  coordenadas : [CLLocationCoordinate2D] = []
    
    var mapMarkers : [GMSMarker] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let status = dbase.connect_db()
        
        mapView.delegate = self
        searchBar.delegate = self
        result.delegate = self
        result.dataSource = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
        
        mapView.settings.zoomGestures = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        
        blurViewTop.constant = 0.0
        mapViewBotton.constant = 0.0
        
        if status.value {
            let places_temp = dbase.getAgencies()
            if places_temp.count > 0{
                places = places_temp
            }
        }
        
        if seleccionado.selected {
            print(seleccionado)
        }
        
        self.showPins()
        
        if seleccionado.name != ""{
            
            for item in mapMarkers{
                if item.title == seleccionado.name{
                    
                    self.placeLatLong = seleccionado.coordinate
                    self.titleView.text = seleccionado.name
                    self.addressView.text = seleccionado.street
                    self.timeView.text = seleccionado.attention
                    self.blurViewTop.constant = -131
                    
                    self.navigateBtn.isEnabled = true
                    
                    let camera = GMSCameraPosition.camera(withLatitude: seleccionado.coordinate.latitude,
                                                          longitude: seleccionado.coordinate.longitude,
                                                          zoom: 18)
                    mapView.camera = camera
                    mapView.selectedMarker = item
                    
                }
                
            }
            
            
            /*var encontrado = false
            for item in places{
                if item.name == seleccionado.name{
                    encontrado = true
                    self.placeLatLong = seleccionado.coordinate
                    
                    self.titleView.text = seleccionado.name
                    self.addressView.text = seleccionado.street
                    self.timeView.text = seleccionado.attention
                    self.blurViewTop.constant = -131
                    mapViewBotton.constant = -131
                    
                    self.navigateBtn.isEnabled = true
                    
                    let camera = GMSCameraPosition.camera(withLatitude: seleccionado.coordinate.latitude,
                                                          longitude: seleccionado.coordinate.longitude,
                                                          zoom: 12)
                    mapView.camera = camera
                    
                }
            }
            
            if !encontrado{
                let camera = GMSCameraPosition.camera(withLatitude: userLatLong.latitude,
                                                      longitude: userLatLong.longitude,
                                                      zoom: 12)
                mapView.camera = camera
            }*/
            
            
        }else{
            let camera = GMSCameraPosition.camera(withLatitude: userLatLong.latitude,
                                                  longitude: userLatLong.longitude,
                                                  zoom: 12)
            mapView.camera = camera
        }
        
        
        filteredPlaces = places
        result.isHidden = true
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        result.isHidden = false
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        result.isHidden = false
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        result.isHidden = true
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        result.isHidden = false
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print("entra en busqueda")
        filteredPlaces = places.filter({ (place) -> Bool in
            let tmp: NSString = place.name as! NSString
            
            print(tmp)
            
            return tmp.localizedCaseInsensitiveContains(searchText)
            
            //return range.location != NSNotFound
        })
        if(filteredPlaces.count == 0){
            print("places cero")
            searchActive = false;
        } else {
            print("places \(filteredPlaces.count)")
            searchActive = true;
        }
        self.result.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredPlaces.count
        }
        return places.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        if(searchActive){
            cell.textLabel?.text = filteredPlaces[indexPath.row].name
        } else {
            cell.textLabel?.text = places[indexPath.row].name
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var temp_places = [place]()
        
        if(searchActive){
            temp_places = filteredPlaces
        } else {
            temp_places = places
        }
        
        print(temp_places[indexPath.row])
        self.view.endEditing(true)
        var index = 0
        for place in mapMarkers{
            if temp_places[indexPath.row].name ==  place.title {
                places[index].selected = true
                self.placeLatLong = temp_places[indexPath.row].coordinate
                
                self.titleView.text = temp_places[indexPath.row].name
                self.addressView.text = temp_places[indexPath.row].street
                self.timeView.text = temp_places[indexPath.row].attention
                self.blurViewTop.constant = -131
                
                
                let camera = GMSCameraPosition.camera(withLatitude: temp_places[indexPath.row].coordinate.latitude, longitude: temp_places[indexPath.row].coordinate.longitude, zoom: 16)
                self.mapView.camera = camera
                
                self.mapView.selectedMarker = place
                
                self.navigateBtn.isEnabled = true
                
                //mapViewBotton.constant = -131
                
                result.isHidden = true
                searchActive = false;
                
            }else{
                places[index].selected = false
            }
            index = index+1
        }
        
        
        
    }
    
    //HABILITA LA OPCION DE OCULTAR EL TECLADO CUANDO SE LE DA EN CUALQUIER PARTE DE LA PANTALLA
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // ####### MAPAS
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("tap item")
        var index = 0
        for place in places{
            if place.coordinate.latitude == marker.position.latitude && place.coordinate.longitude == marker.position.longitude{
                
                self.placeLatLong = marker.position
                
                self.titleView.text = place.name
                self.addressView.text = place.street
                self.timeView.text = place.attention
                self.blurViewTop.constant = -131
                mapViewBotton.constant = -131
                
                places[index].selected = true
                let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16)
                self.mapView.camera = camera
                
                self.navigateBtn.isEnabled = true
                
                
                
            }else{
                places[index].selected = false
            }
            index = index + 1;
        }
        
        //self.obtainCoordinate()
        return false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        userLatLong = locations[0].coordinate
        
        print(locations[0].coordinate.latitude)
        print(locations[0].coordinate.longitude)
        
    }
    
    @IBAction func regresar(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func navegar(_ sender: Any) {
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
            UIApplication.shared.open(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(placeLatLong.latitude),\(placeLatLong.longitude)&directionsmode=driving")! as URL, options: [:], completionHandler: nil) // openURL()
            
        } else {
            let alert = UIAlertController(title: nil, message: "No se encontró Google Maps", preferredStyle: .alert);
            let btn_alert = UIAlertAction(title: "Aceptar", style: .default) { (UIAlertAction) in
            }
            alert.addAction(btn_alert);
            self.present(alert, animated: true, completion: nil);
            print("Error al abrir google maps")
        }
    }
    
    
    @IBAction func closeView(_ sender: Any) {
        
        self.mapViewBotton.constant = 0.0
        self.blurViewTop.constant = 0.0
        
        let camera = GMSCameraPosition.camera(withLatitude: self.mapView.camera.target.latitude, longitude: self.mapView.camera.target.longitude, zoom: 12)
        self.mapView.camera = camera
        
        self.navigateBtn.isEnabled = false
    }
    
    func showPins(){
        
        for place in places{
            
            let marker = GMSMarker(position: place.coordinate)
            let imagePlace = UIImage(named: "place3")
            let markerView = UIImageView(image: imagePlace)
            //markerView.tintColor = .red
            marker.iconView = markerView
            marker.title = place.name
            marker.snippet = place.street
            mapMarkers.append(marker)
            marker.map = self.mapView
  
        }
        
        return
    }
    
    /*func obtainCoordinate(){
     self.coordenadas = []
     
     if let start_location = self.mapView.myLocation?.coordinate {
     
     let end_location = placeLatLong
     
     var url_request = baseURLDirections
     
     url_request += "origin=\(start_location.latitude),\(start_location.longitude)&destination=\(end_location.latitude),\(end_location.longitude)"
     
     print(url_request)
     
     DispatchQueue.main.async {
     
     let url = URL(string: url_request)
     
     URLSession.shared.dataTask(with: url!){ (data , response ,err ) in
     
     guard let data = data else {return}
     
     do{
     let dictionary: Dictionary<NSObject, AnyObject> = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<NSObject, AnyObject>
     
     var routes: NSArray = []
     
     var ok = false
     for (key,value) in dictionary {
     if key as! String == "status" && value as! String == "OK" {
     ok = true
     print("\(key) = \(value)")
     }
     if key as! String == "routes"{
     //print(value)
     routes = value as! NSArray
     }
     }
     
     if ok{
     for value in routes {
     
     print(value)
     print("###########")
     let route = value as! Dictionary<NSObject, AnyObject>
     for (key,value) in route {
     if key as! String == "legs"{
     //print(value)
     let list_rou = value as! Array<Dictionary<NSObject, AnyObject>>
     let startLocationDictionary = list_rou[0]
     for (key1,value1) in startLocationDictionary {
     //print(key1)
     if key1 as! String == "steps"{
     let list_steps = value1 as! Array<Dictionary<NSObject, AnyObject>>
     //let steps = list_steps[0]
     for steps in list_steps {
     var start = location.init(lat: 0, lng: 0)
     var end = location.init(lat: 0, lng: 0)
     for (key2,value2) in steps {
     //print(key2)
     //print(value2)
     if key2 as! String == "start_location"{
     
     let locat = value2 as! Dictionary<NSObject, AnyObject>
     for (key3,value3) in locat {
     if key3 as! String == "lat"{
     print("start_location lat: \(value3)")
     start.lat = value3 as! NSNumber
     //print(start.lat)
     }
     if key3 as! String == "lng"{
     print("start_location lng: \(value3)")
     start.lng = value3 as! NSNumber
     }
     }
     }
     print("------")
     if key2 as! String == "end_location"{
     //var loc = location.init(lat: "", lng: "")
     let locat = value2 as! Dictionary<NSObject, AnyObject>
     for (key3,value3) in locat {
     if key3 as! String == "lat"{
     print("end_location lat: \(value3)")
     end.lat = value3 as! NSNumber
     }
     if key3 as! String == "lng"{
     print("end_location lng: \(value3)")
     end.lng = value3 as! NSNumber
     }
     }
     //print("end_location lat: \(locat["lat"])")
     //print("end_location lng: \(locat["lng"])")
     }
     }
     //print(start)
     //print(end)
     let n_start = CLLocationCoordinate2D(latitude: start.lat as! CLLocationDegrees, longitude: start.lng as! CLLocationDegrees)
     let n_end = CLLocationCoordinate2D(latitude: end.lat as! CLLocationDegrees, longitude: end.lng as! CLLocationDegrees)
     self.coordenadas.append(n_start)
     self.coordenadas.append(n_end)
     }
     
     }
     }
     }
     }
     }
     
     //print(self.coordenadas)
     }
     
     print(self.coordenadas)
     
     
     }catch let errJson {
     print(errJson);
     
     //self.txt_alert = "El usuario no existe"
     }
     //sem.signal()
     
     }.resume()
     }
     
     
     }else{
     print("no se pudo obtener rutas")
     }
     }
     
     func drawRoute() {
     print("entra")
     let path = GMSMutablePath()
     self.mapView.clear()
     self.showPins()
     
     if let mylocation = self.mapView.myLocation {
     print("User's location: \(mylocation)")
     for coord in self.coordenadas{
     print(coord)
     path.add(coord)
     }
     //path.add(mylocation.coordinate)
     //path.add(placeLatLong)
     let polyline = GMSPolyline(path: path)
     polyline.map = self.mapView
     polyline.strokeColor = .blue
     polyline.strokeWidth = 2.0
     
     } else {
     print("User's location is unknown")
     }
     }*/

}
