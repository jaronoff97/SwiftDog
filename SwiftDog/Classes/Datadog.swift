

public class Datadog: API {
    
    internal var base_url: String = "api.datadoghq.com/api/v1/"
    internal var interval_seconds: TimeInterval = TimeInterval(10)
    public var metric: Metric = Metric.metric
    public var event: Event = Event.event
    private var timer: Timer = Timer()
    public static let dd = Datadog()
    internal let host = UIDevice.current.identifierForVendor!.uuidString
    internal let model = UIDevice.current.model
    internal var use_agent = false
    internal var auth:DatadogAuthentication? = nil
    
    @objc private func sendData() {
        print("Sending metrics to the Datadog API.")
        if use_agent {
            IOSAgent.send_agent_metrics()
        }
        do {
            for var endpoint in [self.metric, self.event] as [DataProducer] {
                try endpoint._send_data(url: base_url) { (error: Error?) in
                    print(error!)
                }
            }
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
    
    public func initialize_api(with agent:Bool=false, default_tags:Bool=false) {
        self.auth = DatadogAuthentication()
        self.use_agent = agent
        if default_tags {
            self.metric.addTags(tags: ["agent:ios", "model:\(IOSAgent.modelIdentifier())"])
            self.event.addTags(tags: ["agent:ios", "model:\(IOSAgent.modelIdentifier())"])
        }
        self.timer = Timer.scheduledTimer(timeInterval: self.interval_seconds, target: self, selector: #selector(Datadog.sendData), userInfo: nil, repeats: true)
    }
    
    public func resetCredentials() {
        if self.auth != nil {
            self.auth!.resetCredentials()
        }
    }
    
    private init() {
        
    }
    
    
}
