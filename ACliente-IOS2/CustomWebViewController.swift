//
//  CustomWebViewController.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 12/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit
import WebKit
import SystemConfiguration

class CustomWebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var url_string = "https://www.google.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        
        let url = URL(string: url_string)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        
        self.titleLabel.text = url_string
        
    }
    
    @IBAction func regresar(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func abrirNavegador(_ sender: Any) {
        if let url = URL(string: self.url_string) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func compartir(_ sender: Any) {
        
        let text = "Puntos de Recaudo - Interagua"
        let myWebsite = NSURL(string:self.url_string)
        let shareAll = [text , myWebsite] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    

}
