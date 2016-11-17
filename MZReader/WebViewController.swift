//
//  WebViewController.swift
//  MZReader
//
//  Created by Hisafumi Kikkawa on 2016/05/21.
//  Copyright © 2016年 shinjukujohnny. All rights reserved.
//  開発停止中

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    // インジケータを使うための変数
    var indicator = UIActivityIndicatorView()
    
    // UIWebViewを使うための変数を作成
    @IBOutlet var webview :UIWebView!
    // URLを格納するString変数を作成
    var newsUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UIWebViewDelegageの参照先を設定
        webview.delegate = self
        // インジケータを画面中央に設定
        indicator.center = self.view.center
        // インジケータのスタイルをグレーに設定
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        // インジケータをwebviewに設置
        webview.addSubview(indicator)
        
        let url = NSURL(string: newsUrl)
        let urlRequest = NSURLRequest(URL: url!)
        // WebViewで読み込み
        webview.loadRequest(urlRequest)
    }
    
    // Webページの読み込み開始を通知
    func webViewDidStartLoad(webView: UIWebView) {
        // インジケータの表示アニメを開始
        indicator.startAnimating()
    }
    
    // Webページの読み込み終了を通知
    func webViewDidFinishLoad(webView: UIWebView) {
        // インジケータを停止
        indicator.stopAnimating()
    }

}
