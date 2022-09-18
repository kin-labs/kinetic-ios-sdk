//
//  KineticBuilder.swift
//  
//
//  Created by Samuel Dowd on 7/20/22.
//

import UIKit

public class KineticBuilder {
    private var index: Int = 0
    private var environment: String = "devnet"
    private var endpoint: String = "https://devnet.kinetic.org"

    public init() {}

    public func setEnvironment(_ env: String) -> KineticBuilder {
        self.environment = env
        return self
    }

    public func setIndex(_ i: Int) -> KineticBuilder {
        self.index = i
        return self
    }

    public func setEndpoint(_ endpoint: String) -> KineticBuilder {
        self.endpoint = endpoint
        return self
    }

    public func build() async throws -> Kinetic {
        var kineticInstance = Kinetic(environment: self.environment, index: self.index, endpoint: self.endpoint)
        let appConfig = try await kineticInstance.getAppConfig()
        kineticInstance.appConfig = appConfig
        return kineticInstance
    }
}
