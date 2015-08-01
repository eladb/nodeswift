//
//  stream.swift
//  nodeswift-sample
//
//  Created by Elad Ben-Israel on 7/31/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

class Socket: Hashable, Equatable {

    let tcp: Handle<uv_tcp_t>
    
    var handle: UnsafeMutablePointer<uv_stream_t> {
        return UnsafeMutablePointer<uv_stream_t>(self.tcp.handle)
    }
    
    var hashValue: Int {
        return self.tcp.hashValue
    }
    
    // Events
    
    var data = EventEmitter1<Buffer>()
    var end = EventEmitter0()
    var closed = EventEmitter0()
    
    init() {
        self.tcp = Handle(closable: true)
        self.tcp.callback = self.ondata
        uv_tcp_init(uv_default_loop(), self.tcp.handle)
    }
    
    deinit {
        print("Socket deinit")
    }
    
    func write(string: String, callback: ((Error?) -> ())? = nil) {
        let req = Handle<uv_write_t>(closable: false)
        req.callback = { args in callback?(args[0] as? Error) }
        if let cString = string.cStringUsingEncoding(NSUTF8StringEncoding) {
            let buf = UnsafeMutablePointer<uv_buf_t>.alloc(1)
            buf.memory = uv_buf_init(UnsafeMutablePointer<Int8>(cString), UInt32(cString.count))
            uv_write(req.handle, self.handle, UnsafePointer<uv_buf_t>(buf), 1, write_cb)
        }
    }
    
    func resume() {
        uv_read_start(self.handle, alloc_cb, read_cb)
    }
    
    func close() {
        self.tcp.close {
            self.closed.emit()
        }
    }
    
    private func ondata(args: [AnyObject?]) {
        let event = args[0] as! String
        if event == "data" {
            self.data.emit(args[1] as! Buffer)
        }
        else if event == "end" {
            self.end.emit()
            self.close()
        }
    }
}

private func alloc_cb(handle: UnsafeMutablePointer<uv_handle_t>, suggested_size: Int, buf: UnsafeMutablePointer<uv_buf_t>) {
    buf.memory = uv_buf_init(UnsafeMutablePointer<Int8>.alloc(suggested_size), UInt32(suggested_size))
}

private func read_cb(handle: UnsafeMutablePointer<uv_stream_t>, nread: Int, buf: UnsafePointer<uv_buf_t>) {
    if Int32(nread) == UV_EOF.rawValue {
        // release the buffer and emit "end"
        print("Deallocate buf")
        buf.memory.base.dealloc(buf.memory.len)
        RawHandle.callback(handle, args: [ "end" ], autoclose: false)
        return
    }
    
    // buf will be deallocated on Buffer deinit
    let buffer = Buffer(autoDealloc: buf, nlen: nread)
    RawHandle.callback(handle, args: [ "data", buffer ], autoclose: false)
}

private func write_cb(handle: UnsafeMutablePointer<uv_write_t>, status: Int32) {
    RawHandle.callback(handle, args: [ Error(result: status) ], autoclose: true)
}

func ==(lhs: Socket, rhs: Socket) -> Bool {
    return lhs.tcp == rhs.tcp
}
