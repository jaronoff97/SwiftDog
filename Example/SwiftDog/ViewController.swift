//
//  ViewController.swift
//  SwiftDog
//
//  Created by jacob.aronoff on 05/03/2018.
//  Copyright (c) 2018 jacob.aronoff. All rights reserved.
//

import UIKit
import SwiftDog

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Datadog.dd.metric.send(metric: "ios.device.gauge", points: 1)
        Datadog.dd.metric.send(metric: "ios.device.count", points: 1, host: nil, tags: ["device:test_device"], type: .count(1))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

