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
    
    
    @IBOutlet weak var metricValue: UITextField!
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
    
    @IBAction func sendEvent(_ sender: Any) {
        Datadog.dd.event.send(title: "This is a test event", text: "We can now send events from an iOS device!")
        Datadog.dd.metric.send(metric: "ios.test.event.sent", points: 1)
    }
    
    @IBAction func sendMetric(_ sender: Any) {
    }
    @IBAction func sendTimedData(_ sender: Any) {
    }
    
}

