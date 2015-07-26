//
//  timer.swift
//  swiftuv
//
//  Created by Elad Ben-Israel on 7/26/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

func setTimeout(timeout: UInt64, callback: () -> ()) -> Handle<uv_timer_t> {
    let handle = Handle<uv_timer_t> { _ in callback() }
    uv_timer_init(uv_default_loop(), handle.handle)
    uv_timer_start(handle.handle, { handle in Handle.unwrap(handle).call().release() }, timeout, 0)
    return handle
}

func clearTimeout(handle: Handle<uv_timer_t>) {
    uv_timer_stop(handle.handle)
    handle.release()
}

func setInterval(interval: UInt64, callback: () -> ()) -> Handle<uv_timer_t> {
    let handle = Handle<uv_timer_t> { _ in callback() }
    uv_timer_init(uv_default_loop(), handle.handle)
    uv_timer_start(handle.handle, { handle in Handle.unwrap(handle).call() }, interval, interval)
    return handle
}

func clearInterval(handle: Handle<uv_timer_t>) {
    clearTimeout(handle)
}