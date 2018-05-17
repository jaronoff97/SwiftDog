import KeychainAccess

public class Datadog: API {
    internal var base_url: String = "api.datadoghq.com/api/v1/"
    internal var interval_seconds: TimeInterval = TimeInterval(10)
    public var metric: Metric = Metric.metric
    public var event: Event = Event.event
    private var timer: Timer = Timer()
    internal let keychain = Keychain(service: "api.datadoghq.com")
    public static let dd = Datadog()
    internal let host = UIDevice.current.identifierForVendor!.uuidString
    internal let model = UIDevice.current.model
    internal var use_agent = false
    
    @objc private func sendData() {
        print("Sending metrics to the Datadog API.")
        if use_agent {
            IOSAgent.send_agent_metrics()
        }
        do {
            try self.metric._send(url: base_url) { (error: Error?) in
                print(error!)
            }
            try self.event._send(url: base_url, completion: { (error: Error?) in
                print(error!)
            })
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
    
    private func get_credentials_from_plist() throws {
        var myDict: NSDictionary?
        if let path = Bundle.main.url(forResource: "datadog_config", withExtension: "plist") {
            myDict = NSDictionary(contentsOf: path)
        }
        if let dict = myDict {
            guard let api_key = dict["api_key"] as? String, let app_key = dict["app_key"] as? String else {
                throw DatadogAPIError.keyNotSet("API OR APP KEY NOT SET")
            }
            if keychain["api_key"] == nil || keychain["app_key"] == nil {
                do {
                    try keychain.set(api_key, key: "api_key")
                    try keychain.set(app_key, key: "app_key")
                    print("finished setting credentials")
                } catch {
                    throw DatadogAPIError.keyNotSet("Failed to set app or api key")
                }
                
            }
        }
    }
    
    public func resetCredentials() {
        keychain["api_key"] = nil
        keychain["app_key"] = nil
        do {
            try get_credentials_from_plist()
        } catch {
            print(error)
        }
        
    }
    
    public func initialize_api(with agent:Bool=false, default_tags:Bool=false) {
        do {
            try get_credentials_from_plist()
        } catch {
            fatalError(error.localizedDescription)
        }
        self.use_agent = agent
        if default_tags {
            self.metric.addTags(tags: ["agent:ios", "model:\(IOSAgent.modelIdentifier())"])
            self.event.addTags(tags: ["agent:ios", "model:\(IOSAgent.modelIdentifier())"])
        }
        self.timer = Timer.scheduledTimer(timeInterval: self.interval_seconds, target: self, selector: #selector(Datadog.sendData), userInfo: nil, repeats: true)
    }
    
    
    private init() {
        
    }
    
    
}
