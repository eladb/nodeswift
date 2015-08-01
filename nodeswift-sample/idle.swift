//
//  idle.swift
//  nodeswift-sample
//
//  Created by Elad Ben-Israel on 8/1/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

func nextTick(callback: () -> ()) {
    let idle = Handle<uv_idle_t>(closable: true)
    idle.callback = { _ in callback() }
    uv_idle_init(uv_default_loop(), idle.handle)
    uv_idle_start(idle.handle, idle_cb)
}

private func idle_cb(handle: UnsafeMutablePointer<uv_idle_t>) {
    RawHandle.callback(handle, args: [], autoclose: true)
    uv_idle_stop(handle)
}