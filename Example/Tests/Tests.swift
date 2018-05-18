// https://github.com/Quick/Quick

import Quick
import Nimble
import SwiftDog

class MetricSpec: QuickSpec {
    override func spec() {
        describe("test metric creation") {
            context("can send different kinds of metrics") {
                let m: Metric.MetricData = Metric.MetricData(host: nil, tags: [], metric_name:"test.metric", type: Metric.MetricData.MetricType.gauge, points: [DataPoint(timestamp: TimeInterval(1525377826.2537289), value: 1001.1)])
                it("can create a basic metric") {
                    expect(m.metric_name).to(equal("test.metric"))
                }
                it("can serialize to json") {
                    let encoder = JSONEncoder()
                    do {
                        let jsonData = try encoder.encode(m)
                        let jsonString = String(data: jsonData, encoding: .utf8)
                        expect(jsonString!).to(equal("{\"type\":\"gauge\",\"metric\":\"test.metric\",\"points\":[[1525377826.2537289,1001.0999755859375]]}"))
                    } catch {
                        print("should never get here")
                    }
                }
            }
            context ("can send multiple metrics") {
                let gauge_metric: Metric.MetricData = Metric.MetricData(host: nil, tags: ["test:1"], metric_name:"test.metric1", type: Metric.MetricData.MetricType.gauge, points: [DataPoint(timestamp: TimeInterval(1525377826.2537289), value: 1)])
                let rate_metric: Metric.MetricData = Metric.MetricData(host: "device:fun_ios", tags: ["test:2"], metric_name:"test.metric2", type: Metric.MetricData.MetricType.rate(10), points: [DataPoint(timestamp: TimeInterval(1525377828.2537289), value: 2)])
                let count_metric: Metric.MetricData = Metric.MetricData(host: "device:another_device", tags: ["test:3"], metric_name:"test.metric3", type: Metric.MetricData.MetricType.count(100), points: [DataPoint(timestamp: TimeInterval(1525377820.2537289), value: 3)])
                Datadog.metric.send(series: [gauge_metric, rate_metric, count_metric])
                it("can serialize to json") {
                    let encoder = JSONEncoder()
                    do {
                        let jsonData = try encoder.encode(Datadog.metric)
                        let jsonString = String(data: jsonData, encoding: .utf8)
                        expect(jsonString!).to(equal("{\"series\":[{\"points\":[[1525377826.2537289,1]],\"tags\":[\"test:1\"],\"type\":\"gauge\",\"metric\":\"test.metric1\"},{\"points\":[[1525377828.2537289,2]],\"interval\":10,\"tags\":[\"test:2\"],\"host\":\"device:fun_ios\",\"type\":\"rate\",\"metric\":\"test.metric2\"},{\"points\":[[1525377820.2537289,3]],\"interval\":100,\"tags\":[\"test:3\"],\"host\":\"device:another_device\",\"type\":\"count\",\"metric\":\"test.metric3\"}]}"))
                    } catch {
                        print("should never get here")
                    }
                }
            }
        }
    }
}

class EventSpec: QuickSpec {
    override func spec() {
        describe("test event creation") {
            context("can send different kinds of metrics") {
                let e: Event.EventData = Event.EventData(host: "ios", tags:[], title: "test title", text: "test text", date_happened: 1525412871, priority: .normal, alert_type: .info, aggregation_key: nil, source_type_name: nil)
                it("can create a basic metric") {
                    expect(e.title).to(equal("test title"))
                }
                it("can serialize to json") {
                    let encoder = JSONEncoder()
                    do {
                        let jsonData = try encoder.encode(e)
                        let jsonString = String(data: jsonData, encoding: .utf8)
                        expect(jsonString!).to(equal("{\"alert_type\":\"info\",\"title\":\"test title\",\"host\":\"ios\",\"priority\":\"normal\",\"date_happened\":1525412871,\"text\":\"test text\"}"))
                    } catch {
                        print("should never get here")
                    }
                }
            }
        }
    }
}

