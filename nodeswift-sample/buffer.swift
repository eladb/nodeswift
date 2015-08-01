//
//  buffer.swift
//  nodeswift-sample
//
//  Created by Elad Ben-Israel on 8/1/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

class Buffer {
    private let buf: UnsafePointer<uv_buf_t>
    private let nlen: Int
    
    internal init(autoDealloc buf: UnsafePointer<uv_buf_t>, nlen: Int) {
        self.buf = buf
        self.nlen = nlen
    }
    deinit {
        print("buffer deallocated")
        self.buf.memory.base.dealloc(self.buf.memory.len)
    }
    var buffer: UnsafeMutableBufferPointer<Int8> {
        return UnsafeMutableBufferPointer(start: self.buf.memory.base, count: self.nlen)
    }
    var stringContents: String? {
        // put a \0 to terminate the string
        let buffer = UnsafeMutableBufferPointer(start: self.buf.memory.base, count: self.buf.memory.len)
        buffer[self.nlen] = 0x00
        return String.fromCString(buffer.baseAddress)
    }
}