//
//  MetricData.swift
//  SwiftDog
//
//  Created by jacob.aronoff on 5/18/18.
//

import Foundation

public struct MetricData: DataType {
    private enum CodingKeys: String, CodingKey {
        case metric, type, interval, points, host, tags
    }
    public enum MetricType {
        case gauge, rate(Float), count(Float)
        
        var description: String {
            switch self {
            case .gauge:
                return "gauge"
            case .rate(_):
                return "rate"
            case .count(_):
                return "count"
            }
        }
    }
    public var host: String?
    public var tags: [String]
    public var metric_name: String
    public var type: MetricType
    public var points: [DataPoint]
    
    public init(host: String?, tags:[String], metric_name: String, type: MetricType, points: [DataPoint]) {
        self.host = host
        self.tags = tags
        self.metric_name = metric_name
        self.type = type
        self.points = points
    }
    
    public func encode(to encoder: Encoder) throws {
        var series_data = encoder.container(keyedBy: MetricData.CodingKeys.self)
        try series_data.encode(self.metric_name, forKey: .metric)
        try series_data.encode(self.type.description, forKey: .type)
        switch self.type {
        case .rate(let number), .count(let number):
            try series_data.encode(number, forKey: .interval)
        default:
            break
        }
        var fixed_points: [[Double]] = []
        for point in self.points {
            fixed_points.append([point.0, Double(point.1)])
        }
        try series_data.encode(fixed_points, forKey: CodingKeys.points)
        try series_data.encodeIfPresent(self.host, forKey: .host)
        try series_data.encodeIfPresent(self.tags.count == 0 ? nil : self.tags, forKey: .tags)
        
    }
}
