//
//  Authentication.swift
//  SwiftDog
//
//  Created by jacob.aronoff on 5/18/18.
//

import Foundation
import KeychainAccess

internal struct DatadogAuthentication {
    private let keychain = Keychain(service: "api.datadoghq.com")
    internal var authenticated = false
    internal var app_key: String? {
        return self.keychain[string: "app_key"]
    }
    internal var api_key: String? {
        return self.keychain[string: "api_key"]
    }
    
    private mutating func get_credentials_from_plist() throws {
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
                    self.authenticated = true
                    print("finished setting credentials")
                } catch {
                    throw DatadogAPIError.keyNotSet("Failed to set app or api key")
                }
                
            }
        }
    }
    
    internal init() {
        do {
            try self.get_credentials_from_plist()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    internal mutating func resetCredentials() {
        keychain["api_key"] = nil
        keychain["app_key"] = nil
        do {
            try self.get_credentials_from_plist()
        } catch {
            print(error)
        }
        
    }
}
