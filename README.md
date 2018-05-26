# SwiftDog

<img src="https://github.com/jaronoff97/SwiftDog/blob/master/bits-swift-lightbg.svg" width="250">

[![CI Status](https://travis-ci.org/jaronoff97/SwiftDog.svg?branch=master)](https://travis-ci.org/jaronoff97/SwiftDog)
[![Version](https://img.shields.io/cocoapods/v/SwiftDog.svg?style=flat)](https://cocoapods.org/pods/SwiftDog)
[![License](https://img.shields.io/cocoapods/l/SwiftDog.svg?style=flat)](https://cocoapods.org/pods/SwiftDog)
[![Platform](https://img.shields.io/cocoapods/p/SwiftDog.svg?style=flat)](https://cocoapods.org/pods/SwiftDog)

This is an (un)official swift library of the datadog API! Many more features to come, but right now it supports sending metrics and events!

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

In order to run this library you need to create a file called `datadog_config.plist` with two keys: `api_key` and `app_key`

## Installation

SwiftDog is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
target 'MyApp' do
  pod 'SwiftDog', '~> 0.0.2'
end
```

## Usage

The API currently supports sending metrics and events, with more features coming soon. 

*Currently, retrieving data is not implemented, nor is it in the plan for the future.* 

### Initialization

There are a few ways to initialize the api.

*BE SURE YOU HAVE ADDED `datadog_config.plist`, SEE REQUIREMENTS*
```swift
Datadog.initialize_api()
Datadog.initialize_api(default_tags: true)
Datadog.initialize_api(agent: true)
Datadog.initialize_api(agent: true, default_tags: true)
```

### Sending Metrics
```swift
Datadog.metric.send(metric: "ios.device.gauge", points: 1)
Datadog.metric.send(metric: "ios.test.event.sent", points: 1, type: .count(1))
Datadog.metric.send(metric: "ios.device.count", points: 1, host: nil, tags: ["device:test_device"], type: .count(1))
```

You can also create objects to send directly!
```swift
let gauge_metric = MetricData(host: nil, tags: ["test:1"], metric_name:"test.metric1", type: MetricData.MetricType.gauge, points: [DataPoint(timestamp: TimeInterval(1525377826.2537289), value: 1)])
let rate_metric = MetricData(host: "device:fun_ios", tags: ["test:2"], metric_name:"test.metric2", type: MetricData.MetricType.rate(10), points: [DataPoint(timestamp: TimeInterval(1525377828.2537289), value: 2)])
let count_metric = MetricData(host: "device:another_device", tags: ["test:3"], metric_name:"test.metric3", type: MetricData.MetricType.count(100), points: [DataPoint(timestamp: TimeInterval(1525377820.2537289), value: 3)])
Datadog.metric.send(series: [gauge_metric, rate_metric, count_metric])
```

### Sending Events
```swift
Datadog.event.send(title: "This is a test event", text: "We can now send events from an iOS device!")
Datadog.event.send(title: "This is a test event", text: "We can now send events from an iOS device!", tags: ["method:hello"])
Datadog.event.send(title: "This is a test event", text: "We can now send events from an iOS device!", tags: ["method:hello"], date_happened: Data.currentDate())
Datadog.event.send(title: "This is a test event", text: "We can now send events from an iOS device!", tags: ["method:hello"], date_happened: Data.currentDate(), priority: .low)
Datadog.event.send(title: "This is a test event", text: "We can now send events from an iOS device!", tags: ["method:hello"], date_happened: Data.currentDate(), priority: .normal, alert_type: .error)
Datadog.event.send(title: "This is a test event", text: "We can now send events from an iOS device!", tags: ["method:hello"], date_happened: Data.currentDate(), priority: .normal, alert_type: .error, aggregation_key: "host")
Datadog.event.send(title: "This is a test event", text: "We can now send events from an iOS device!", tags: ["method:hello"], date_happened: Data.currentDate(), priority: .normal, alert_type: .error, aggregation_key: "host", source_type_name: "mobile")
```

Like metrics, you can create an event and send it too.
```swift
let e: EventData = EventData(host: "ios", tags:[], title: "test title", text: "test text", date_happened: 1525412871, priority: .normal, alert_type: .info, aggregation_key: nil, source_type_name: nil)
Datadog.event.send(series: [e])
```

## Author

Jacob Aronoff, jacobaronoff45@gmail.com

## License

SwiftDog is available under the APACHE license. See the LICENSE file for more info.



