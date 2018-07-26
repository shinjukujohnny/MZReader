//
//  ViewController.swift
//  MZReader
//
//  Created by Hisafumi Kikkawa on 2016/04/30.
//  Copyright © 2016年 shinjukujohnny. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAnalytics
import GoogleMobileAds
import Adjust

class ViewController: UIViewController, XMLParserDelegate, UITableViewDataSource, UITableViewDelegate, GADInterstitialDelegate {
    
    // ニュース記事のURLを格納する変数
    var newsUrl = ""
    // ニュース記事のタイトルを格納する変数
    var newsTitle = ""
    var _elementName: String = ""
    var _items: [Item]! = []
    var _item: Item? = nil
    @IBOutlet var table :UITableView!
    
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ヘッダ部分にタイトルを記載
        self.title = "MZReader"
        
        // firebaseイベント計測
        FIRAnalytics.setUserPropertyString("test", forName: "favorite_food")
        FIRAnalytics.logEvent(withName: "johnny_test", parameters: nil)
        // 新しいイベントが自動収集されるテスト
        FIRAnalytics.logEvent(withName: "event_auto_add_test", parameters: nil)

        FIRAnalytics.logEvent(withName: "event_test", parameters: ["key": "キー" as NSObject])
        
        //Table ViewのDataSource参照先指定
        table.dataSource = self
        // Table Viewのタップ時のdelegate先を指定
        table.delegate = self
        
        let url = URL(string: "https://markezine.jp/rss/new/20/index.xml")
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            if data == nil {
                print("dataTaskWithRequest error")
                return
            }
            
            let parser = XMLParser(data: data!)
            parser.delegate = self
            parser.parse()
        }) 
        
        task.resume()
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3553872227246761/3228241644")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        
        // level up event
        var event:ADJEvent = ADJEvent.init(eventToken: "pqb3cq")!
        Adjust.trackEvent(event)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // テーブルビューのセルの数をnewsDataArrayに格納しているデータの数で設定
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return _items.count
    }
    
    // セルに表示する内容を設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // story boardで設定したCellを取得
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        
        // ニュース記事データを取得（配列の"indexPath.row"番目の要素を取得）
        let item = _items[indexPath.row]
        // タイトル、説明をCellにセット
        cell.textLabel!.text = item.title
        cell.textLabel!.numberOfLines = 3
        //cell.detailTextLabel!.text = item.description
        cell.detailTextLabel!.text = item.pubDate
        return cell
    }
    
    // テーブルビューのセルがタップされた時の処理を追加
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = _items[indexPath.row]
        // StringをNSURLに変換
        //let url = NSURL(string:item.guid)
        //UIApplication.sharedApplication().openURL(url!)
        
        newsUrl = item.guid
        newsTitle = (item.title as NSString).substring(to: 15) + "..."
        // WebViewController画面へ遷移
        performSegue(withIdentifier: "toWebView", sender: self)
    }
    
    // WebViewControllerへURLデータを渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if interstitial.isReady {
            //interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }

        // セグエ用にダウンキャストしたWebViewControllerのインスタンス
        let wvc = segue.destination as! WebViewController
        // 変数newsUrlの値をWebViewControllerの変数newsUrlに代入
        wvc.newsUrl = newsUrl
        wvc.title = newsTitle
    }
    
    // XML解析開始時に実行されるメソッド
    func parserDidStartDocument(_ parser: XMLParser) {
        // print("XML解析開始しました")
    }
    
    // 解析中に要素の開始タグがあったときに実行されるメソッド
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        // print("開始タグ:" + elementName)
        _elementName = elementName
        if elementName == "item" {
            // Itemオブジェクトの初期化
            _item = Item()
        }
    }
    
    // 開始タグと終了タグでくくられたデータがあったときに実行されるメソッド
    func parser(_ parser: XMLParser, foundCharacters chars: String) {
        if _item == nil { return }
        //print(chars)
        //print(_elementName)
        if _elementName == "title" {
            _item!.title = chars
        } else if _elementName == "description" {
            _item!.description = chars
        } else if _elementName == "guid" {
            _item!.guid = chars
        } else if _elementName == "pubDate" {
            _item!.pubDate = chars
        }
    }
    
    // 解析中に要素の終了タグがあったときに実行されるメソッド
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // print("終了タグ:" + elementName)
        if (elementName == "item" && _item != nil && _item!.title != "" && _item?.description != "") {
            _items!.append(_item!)
        }
        _elementName = ""
    }
    
    // XML解析終了時に実行されるメソッド
    func parserDidEndDocument(_ parser: XMLParser) {
        // print("XML解析終了しました")
        // for Debug
        /*
        for i in _items {
            print("#####################")
            print(i.title)
            print(i.description)
            print("#####################")
        }
        */
        
        // UIの変更はmain thread で行う
        DispatchQueue.main.async(execute: {
            self.table.reloadData()
            // print("reload OK")
        })
    }
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}

