//
//  timer.swift
//  swiftuv
//
//  Created by Elad Ben-Israel on 7/26/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

class Timer {
    let timer: Handle<uv_timer_t>
    
    init() {
        self.timer = Handle(closable: true)
        uv_timer_init(uv_default_loop(), self.timer.handle)
    }
    
    func setTimeout(timeout: UInt64, callback: (() -> ())? = nil) {
        self.timer.callback = { _ in
            callback?()
            self.timer.close()
        }
        uv_timer_start(self.timer.handle, timer_cb, timeout, 0)
    }
    
    func setInterval(interval: UInt64, callback: (() -> ())? = nil) {
        self.timer.callback = { _ in callback?() }
        uv_timer_start(self.timer.handle, timer_cb, 0, interval)
    }
    
    func clear() {
        uv_timer_stop(self.timer.handle)
        self.timer.close()
    }
}

func setTimeout(timeout: UInt64, callback: (() -> ())? = nil) -> Timer {
    let timer = Timer()
    timer.setTimeout(timeout, callback: callback)
    return timer
}

func clearTimeout(timer: Timer) {
    timer.clear()
}

func setInterval(interval: UInt64, callback: (() -> ())? = nil) -> Timer {
    let timer = Timer()
    timer.setInterval(interval)
    return timer
}

func clearInterval(timer: Timer) {
    timer.clear()
}

private func timer_cb(handle: UnsafeMutablePointer<uv_timer_t>) {
    RawHandle.callback(handle, args: [ ], autoclose: false)
}

