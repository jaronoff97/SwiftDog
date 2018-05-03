//
//  Types.swift
//  SwiftDog
//
//  Created by jacob.aronoff on 5/3/18.
//

public typealias DataPoint = (TimeInterval, Float)

public extension Date {
    public static func currentTimestamp() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
}

internal protocol API {
    var base_url: String { get }
    var interval_seconds: TimeInterval { get set }
}

public protocol DataType: Encodable {
    var host: String? { get set }
    var tags: [String] { get set }
}

public protocol Endpoint {
    associatedtype EndpointDataType: DataType
    var endpoint: String { get }
    mutating func send(series: [EndpointDataType])
}

extension Endpoint {
    func create_url(url: String) throws -> URL {
        let api_key = Datadog.dd.keychain[string: "api_key"]
        let app_key = Datadog.dd.keychain[string: "app_key"]
        return URL(string: "https://"+url+self.endpoint + "?api_key=\(api_key!)&application_key=\(app_key!)")!
    }
}

enum DatadogAPIError: Error {
    case keyNotSet(String)
    case URLNotCreated(String)
    case unknownError(String)
}
