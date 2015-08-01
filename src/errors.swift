//
//  errors.swift
//  swiftuv
//
//  Created by Elad Ben-Israel on 7/26/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

class Error: CustomStringConvertible {
    
    let code: Int32
    let message: String
    
    var _code: Int { return Int(self.code) }
    var _domain: String { return "uv" }
    
    init?(result: Int32) {
        self.code = result
        self.message = String.fromCString(UnsafePointer<CChar>(uv_strerror(result))) ?? "Error \(result)"
        if (self.code >= 0) {
            return nil // this is not an error
        }
    }

    convenience init?(result: Int) {
        self.init(result: Int32(result))
    }
    
    var description: String {
        return message
    }
}
