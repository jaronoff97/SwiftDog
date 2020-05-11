//
//  Metric.swift
//  SwiftDog
//
//  Created by jacob.aronoff on 5/3/18.
//

import Foundation

public struct Metric: DataProducer, Encodable {
    
    static let metric = Metric()
    public typealias EndpointDataType = MetricData
    public var endpoint: String = "series"
    public var endpoint_data = [MetricData]()
    public var tags: [String] = []
    
    private enum SeriesCodingKeys: String, CodingKey {
        case series
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SeriesCodingKeys.self)
        try container.encode(endpoint_data, forKey: .series)
    }
    
    internal mutating func _send_data(url: String, completion:((Error?) -> Void)?) throws {
        let url_to_post = try self.create_url(url: url)
        let encoder = JSONEncoder()
        do {
            let json_data = try encoder.encode(self)
            try self._send(url_to_post: url_to_post, json: json_data, completion: completion)
            self.endpoint_data = []
        } catch {
            completion?(error)
        }
    }
    
    public mutating func send(metric: String, points: [DataPoint], host: String? = nil, tags: [String] = [], type: MetricData.MetricType = .gauge) {
        self.send(series: [MetricData(host: host, tags: tags, metric_name: metric, type: type, points: points)])
    }
    
    public mutating func send(metric: String, points: Float, host: String? = nil, tags: [String] = [], type: MetricData.MetricType = .gauge) {
        self.send(series: [MetricData(host: host, tags: tags, metric_name: metric, type: type, points: [DataPoint(timestamp: Date.currentTimestamp(), value: points)])])
    }
    
    public mutating func send(metric: String, points: DataPoint, host: String? = nil, tags: [String] = [], type: MetricData.MetricType = .gauge) {
        self.send(series: [MetricData(host: host, tags: tags, metric_name: metric, type: type, points: [points])])
    }
    
    
}


