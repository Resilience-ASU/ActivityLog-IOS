//
//  SurveyWebViewController.swift
//  ActivityLog
//
//  Created by Ziqi Li on 6/29/18.
//  Copyright © 2018 Ziqi Li. All rights reserved.
//

import UIKit
import WebKit

class SurveyWebViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string:"https://asu.co1.qualtrics.com/jfe/form/SV_9nylPQbOl5x9tfD")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

}
