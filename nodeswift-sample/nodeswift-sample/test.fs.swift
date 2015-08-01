//
//  test.fs.swift
//  nodeswift-sample
//
//  Created by Elad Ben-Israel on 8/1/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

func testMkdir() {
    mkdir("/tmp/foogoo", mode: 0777) { err in
        if let err = err {
            print("error: \(err)")
        }
    }
    
    mkdir("/tmp/succeed\(arc4random())", mode: 0777) { err in
        print(err)
    }
}