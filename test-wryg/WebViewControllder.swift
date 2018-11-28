//
//  ViewController.swift
//  test-wryg
//
//  Created by Jeff Liu on 11/9/18.
//  Copyright © 2018 Jeff Liu. All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController,WKUIDelegate,WKNavigationDelegate {
    
    var webView: WKWebView!
    var passedURL = "http://whereyogi.com"
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        reloadWebview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("View appered")
    }
    
    func reloadWebview(){
        let url = URL(string:passedURL)!
        if(webView != nil){
            print("webview loading");
            webView.load(URLRequest(url: url));
        }else{
            print("webview is nil");
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
}

