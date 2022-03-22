//
//  FetchRateLimiter.swift
//  SpaceTraderiOS-SwiftUI2
//
//  Created by David W. Brown on 1/17/22.
//

import Foundation

struct RateLimiter {
    private var lastRefresh = Date.distantPast
    private let refreshRateLimit: TimeInterval
    
    init(maxRefreshRate: TimeInterval) {
        self.refreshRateLimit = maxRefreshRate
    }
    
    mutating func execute(action: (() -> Void), force: Bool = false) {
        guard delayHasExpired || force else { return }
        action()
        resetDelay()
    }
    
    private var delayHasExpired: Bool {
        Date().timeIntervalSince(lastRefresh) > refreshRateLimit
    }
    
    mutating private func resetDelay() {
        lastRefresh = Date()
    }
}
