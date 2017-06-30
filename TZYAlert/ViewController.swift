//
//  ViewController.swift
//  TZYAlert
//
//  Created by 田子瑶 on 2017/4/10.
//  Copyright © 2017年 田子瑶. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let alert = TZYAlert.alert(withTitle: "提示", msg: "消息")
        alert.addCommonButton(withTitle: "1") { (item) in
            print(item.title)
        }
        alert.addCancelButton(withTitle: "3") { (item) in
            print(item.title)
        }
        alert.show()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

