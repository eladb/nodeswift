//
//  errors.swift
//  swiftuv
//
//  Created by Elad Ben-Israel on 7/26/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

struct Error: CustomStringConvertible {
    let code: Int
    let message: String
    
    init?(result: Int) {
        if (result >= 0) {
            return nil
        }
        self.code = result
        self.message = String.fromCString(UnsafePointer<CChar>(uv_strerror(Int32(result)))) ?? "Error \(result)"
    }
    
    var description: String {
        return message
    }
}
