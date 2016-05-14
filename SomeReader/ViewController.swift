//
//  ViewController.swift
//  SomeReader
//
//  Created by Hisafumi Kikkawa on 2016/04/30.
//  Copyright © 2016年 shinjukujohnny. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var _elementName: String = ""
    var _items: [Item]! = []
    var _item: Item? = nil
    @IBOutlet var table :UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Table ViewのDataSource参照先指定
        table.dataSource = self
        // Table Viewのタップ時のdelegate先を指定
        table.delegate = self
        
        let url = NSURL(string: "http://rss.rssad.jp/rss/markezine/new/20/index.xml")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            if data == nil {
                print("dataTaskWithRequest error: \(error)")
                return
            }
            
            let parser = NSXMLParser(data: data!)
            parser.delegate = self
            parser.parse()
        }
        
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // テーブルビューのセルの数をnewsDataArrayに格納しているデータの数で設定
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return _items.count
    }
    
    // セルに表示する内容を設定
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // story boardで設定したCellを取得
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        // ニュース記事データを取得（配列の"indexPath.row"番目の要素を取得）
        let item = _items[indexPath.row]
        // タイトル、説明をCellにセット
        cell.textLabel!.text = item.title
        cell.textLabel!.numberOfLines = 3
        cell.detailTextLabel!.text = item.description
        cell.detailTextLabel!.text = item.pubDate
        return cell
    }
    
    // テーブルビューのセルがタップされた時の処理を追加
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = _items[indexPath.row]
        // StringをNSURLに変換
        let url = NSURL(string:item.guid)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    // XML解析開始時に実行されるメソッド
    func parserDidStartDocument(parser: NSXMLParser) {
        // print("XML解析開始しました")
    }
    
    // 解析中に要素の開始タグがあったときに実行されるメソッド
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        // print("開始タグ:" + elementName)
        _elementName = elementName
        if elementName == "item" {
            // Itemオブジェクトの初期化
            _item = Item()
        }
    }
    
    // 開始タグと終了タグでくくられたデータがあったときに実行されるメソッド
    func parser(parser: NSXMLParser, foundCharacters chars: String) {
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
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // print("終了タグ:" + elementName)
        if (elementName == "item" && _item != nil && _item!.title != "" && _item?.description != "") {
            _items!.append(_item!)
        }
        _elementName = ""
    }
    
    // XML解析終了時に実行されるメソッド
    func parserDidEndDocument(parser: NSXMLParser) {
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
        dispatch_async(dispatch_get_main_queue(), {
            self.table.reloadData()
            // print("reload OK")
        })
    }

}

