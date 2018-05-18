//
//  Events.swift
//  SwiftDog
//
//  Created by jacob.aronoff on 5/4/18.
//


public struct Event: DataProducer {
    static let event = Event()
    public typealias EndpointDataType = EventData
    public var endpoint: String = "events"
    public var tags: [String] = []
    public var endpoint_data = [EventData]()
    
    internal mutating func _send_data(url: String, completion:((Error?) -> Void)?) throws {
        let url_to_post = try self.create_url(url: url)
        let encoder = JSONEncoder()
        do {
            for event in self.endpoint_data {
                let json_data = try encoder.encode(event)
                try self._send(url_to_post: url_to_post, json: json_data, completion: completion)
            }
            self.endpoint_data = []
        } catch {
            completion?(error)
        }
    }
    
    public mutating func send(host: String? = nil, tags:[String] = [], title: String, text: String, date_happened: Int = Date.currentDate(), priority: EventData.EventPriority = .normal, alert_type: EventData.AlertType = .info, aggregation_key: String? = nil, source_type_name: String? = nil) {
        self.send(series: [EventData(host: host, tags: tags, title: title, text: text, date_happened: date_happened, priority: priority, alert_type: alert_type, aggregation_key: aggregation_key, source_type_name: source_type_name)])
    }
    
}



