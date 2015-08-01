//
//  main.swift
//  swiftuv
//
//  Created by Elad Ben-Israel on 7/25/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

//testNet()

for i in 0..<100 {
    print(i)
    let h = Handle<uv_tcp_t>()
    uv_tcp_init(uv_default_loop(), h.handle)
    h.callback = { _ in print("callme") }
    setTimeout(500) {
        RawHandle.callback(h.handle, args: [], autoclose: true)
    }
}

print("here")
setInterval(1000)

uv_run(uv_default_loop(), UV_RUN_DEFAULT)
while true { }