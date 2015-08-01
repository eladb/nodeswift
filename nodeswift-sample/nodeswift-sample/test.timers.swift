//
//  test.timers.swift
//  nodeswift-sample
//
//  Created by Elad Ben-Israel on 8/1/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

func testTimers() {
    let t1 = setInterval(1000) { print("tick") }
    let t2 = setInterval(1000) { print("tock") }
    
    setTimeout(5000) {
        print("Stopping intervals")
        clearInterval(t1)
        clearInterval(t2)
    } 
}