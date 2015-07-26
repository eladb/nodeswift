//
//  main.swift
//  swiftuv
//
//  Created by Elad Ben-Israel on 7/25/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

var t1 = setInterval(1000) { print("tick") }
var t2 = setInterval(1000) { print("tock") }

setTimeout(5000) {
    print("Stopping intervals")
    clearInterval(t1)
    clearInterval(t2)
}

mkdir("/tmp/foogoo", mode: 0777) { err in
    if let err = err {
        print("error: \(err)")
    }
}

mkdir("/tmp/succeed\(arc4random())", mode: 0777) { err in
    print(err)
}

uv_run(uv_default_loop(), UV_RUN_DEFAULT)

print("Done")
