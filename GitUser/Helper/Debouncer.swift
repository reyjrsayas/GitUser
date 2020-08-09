//
//  Debouncer.swift
//  GitUser
//
//  Created by Ray Sayas on 8/9/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

class Debouncer {
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }

    typealias Handler = () -> Void
    var handler: Handler?

    private let timeInterval: TimeInterval

    private var timer: Timer?
    func renewInterval() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { [weak self] timer in
            self?.handleTimer(timer)
        })
    }

    private func handleTimer(_ timer: Timer) {
        guard timer.isValid else {
            return
        }
        handler?()
    }
}
