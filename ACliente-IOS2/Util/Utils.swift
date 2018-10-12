//
//  Utils.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 12/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import Foundation
import UserNotifications

func notificationPop(title: String, subtitle: String, body: String){
    //se accede a la central de notificaciones
    let notificationCenter = UNUserNotificationCenter.current()
    //se crea el contenido de la notificacion
    let content = UNMutableNotificationContent()
    content.title = title
    content.subtitle = subtitle
    content.body = body
    
    /*Ahora debemos crear un Schedule de disparo de nuestra notificación. Para
     ello, usaremos UNTimeIntervalNotificationTrigger, el cual recibe un
     "timeInterval". Este parámetro indica cuantos segundos a partir de ser
     agregada nuestra notificación ésta será disparada. El siguiente parámetro
     "repeats" sirve para indicar si la notificación se repetirá después de
     su primer disparo.*/
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    
    /*Ahora crearemos una petición, la cual debe tener un "identifier" que
     puede ser el de nuestra preferencia, un "content" y un "trigger" que
     hemos generado lineas arriba.*/
    let request = UNNotificationRequest(identifier: "initNotification", content: content, trigger: trigger)
    
    /*El siguiente paso será agregar nuestra petición a la central
     de notificaciones de nuestra aplicación.*/
    notificationCenter.add(request) { (error) in
        
        if error == nil {
            print("Se agrego correctamente la notificacion")
        }else{
            print("Se presento un problema con la notificacion")
        }
    }
}

func verificarCedula(cedula: String) -> Bool {
    var cedulaCorrecta = false
    var cedula = cedula
    if (cedula.count == 13){
        cedula = cedula.substring(with: 0..<10)
        print("cedula \(cedula.substring(with: 0..<10))" )
    }
    
    if (cedula.count == 10){
        
        let tercerDigito = Int(cedula.substring(with: 2..<3))!
        if (tercerDigito < 6) {
            // Coeficientes de validación cédula
            // El decimo digito se lo considera dígito verificador
            let coefValCedula = [2,1,2,1,2,1,2,1,2]
            let verificador = Int(cedula.substring(with: 9..<10))
            var suma = 0
            var digito = 0
            var i = 0
            while i <= (cedula.count - 2) {
                digito = Int(cedula.substring(with: i..<(i+1)))! * coefValCedula[i]
                suma += ((digito % 10) + (digito / 10))
                i = i + 1
            }
            
            
            if ((suma % 10 == 0) && (suma % 10 == verificador)) {
                cedulaCorrecta = true
            }else if ((10 - (suma % 10)) == verificador) {
                cedulaCorrecta = true
            } else {
                cedulaCorrecta = false
            }
        } else {
            cedulaCorrecta = false
        }
    } else {
        cedulaCorrecta = false
    }
    
    
    if (!cedulaCorrecta) {
        print("La Cédula ingresada es Incorrecta")
    }
    return cedulaCorrecta
}

func codeUtf8(data: String) -> String{
    let customAllowedSet = CharacterSet(charactersIn:" &+=\"#%/<>?@\\^`{|}:[],").inverted
    return data.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
}



extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

func isValidEmail(string: String) -> Bool {
    let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailReg)
    return emailTest.evaluate(with: string)
}

func subStringProcess(text: String, char: Character) -> String{
    var status = ""
    if let index = text.index(of: char) {
        var distance = text.distance(from: text.startIndex, to: index)
        distance += 2
        status = text.substring(from: distance)
    }
    return status
}

extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}

func getMonthString(date: String, _ type: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "es_EC")
    dateFormatter.dateFormat = "LLLL yyyy"
    return dateFormatter.string(from: getFormatedDate(date: date, type)).uppercased()
}

func getOnlyMonthString(date: String, _ type: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "es_EC")
    dateFormatter.dateFormat = "LLLL"
    return dateFormatter.string(from: getFormatedDate(date: date, type)).uppercased()
}

func getLabelDate(date: String, _ type: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "es_EC")
    dateFormatter.dateFormat = "dd/MM/yyyy"
    return dateFormatter.string(from: getFormatedDate(date: date, type)).uppercased()
}

func getFormatedDate(date: String, _ type: Int) -> Date {
    let dateFormatter = DateFormatter()
    var date = date
    if(type == 1){
        dateFormatter.dateFormat = "ddMMyyyy-HH:mm:ss"
    }
    if(type == 2){
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
    }
    if(type == 3){
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        date = date.substring(with: 0..<18)
    }
    if(type == 4){
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    
    dateFormatter.locale = Locale(identifier: "es_EC")
    return dateFormatter.date(from: date)!
}

func getDate() -> String{
    
    let date = Date()
    
    let dateFormatter = DateFormatter()
    
    dateFormatter.locale = Locale(identifier: "es_EC")
    dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy")
    return dateFormatter.string(from: date)
}

extension NSMutableArray {
    func reverse() {
        if count <= 1 {
            return
        }
        var i: Int = 0
        var j: Int = count - 1
        while i < j {
            exchangeObject(at: i, withObjectAt: j)
            i += 1
            j -= 1
        }
    }
}
