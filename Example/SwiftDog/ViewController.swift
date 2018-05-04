//
//  ViewController.swift
//  SwiftDog
//
//  Created by jacob.aronoff on 05/03/2018.
//  Copyright (c) 2018 jacob.aronoff. All rights reserved.
//

import UIKit
import SwiftDog

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var metricValue: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Datadog.dd.metric.send(metric: "ios.device.gauge", points: 1)
        Datadog.dd.metric.send(metric: "ios.device.count", points: 1, host: nil, tags: ["device:test_device"], type: .count(1))
        self.metricValue.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendEvent(_ sender: Any) {
        Datadog.dd.event.send(title: "This is a test event", text: "We can now send events from an iOS device!")
        Datadog.dd.metric.send(metric: "ios.test.event.sent", points: 1, type: .count(1))
    }
    
    @IBAction func sendMetric(_ sender: Any) {
        if let metric_value = Int(metricValue.text!) {
            Datadog.dd.metric.send(metric: "ios.test.value", points: Float(metric_value), type: .gauge)
        }
    }
    
    func fib(_ n: Int) -> Int {
        if n < 2 {
            return n
        } else {
            return (fib(n-1) + fib(n-2))
        }
    }
    @IBAction func resetCredentials(_ sender: Any) {
        Datadog.dd.resetCredentials()
    }
    
    @IBAction func sendTimedData(_ sender: Any) {
        let start = DispatchTime.now()
        _ = fib(40)
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        Datadog.dd.metric.send(metric: "ios.test.fib.timing", points: Float(timeInterval))

    }
    
}

