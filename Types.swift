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
    public static func currentDate() -> Int {
        return Int(Date.currentTimestamp())
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
    var tags: [String] { get set }
    var endpoint_data: [EndpointDataType] { get set }
}

extension Endpoint {
    internal func create_url(url: String) throws -> URL {
        let api_key = Datadog.dd.keychain[string: "api_key"]
        let app_key = Datadog.dd.keychain[string: "app_key"]
        return URL(string: "https://"+url+self.endpoint + "?api_key=\(api_key!)&application_key=\(app_key!)")!
    }
    internal mutating func _send(url_to_post: URL, json: Data, completion:((Error?) -> Void)?) throws {
        guard json.count > 0, self.endpoint_data.count > 0 else {
            print("no data to send")
            return
        }
        var request = URLRequest(url: url_to_post)
        request.httpMethod = "POST"
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        request.httpBody = json
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                completion?(responseError!)
                return
            }
            // APIs usually respond with the data you just sent in your POST request
            if let data = responseData, let _ = String(data: data, encoding: .utf8) {
                do {
                    let response_dict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                    print("response: \(String(describing: response_dict["status"]))")
                } catch {
                    completion?(error)
                }
            } else {
                print("no readable data received in response")
            }
        }
        task.resume()
        self.endpoint_data = []
    }
    internal mutating func addTags(tags: [String]) {
        self.tags.append(contentsOf: tags)
    }
    
    public mutating func send(series: [EndpointDataType]) {
        _ = series.map { (item: EndpointDataType) in
            var it = item
            it.tags.append(contentsOf: self.tags)
            endpoint_data.append(it)
        }
    }
}

enum DatadogAPIError: Error {
    case keyNotSet(String)
    case URLNotCreated(String)
    case unknownError(String)
}
