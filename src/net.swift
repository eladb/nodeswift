//
//  tcp.swift
//  nodeswift-sample
//
//  Created by Elad Ben-Israel on 7/26/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

class Server {
    
    var server: Handle<uv_tcp_t>
    
    var clients = Set<Socket>()
    
    // Events
    
    var connect   = EventEmitter1<Socket>()
    var error     = ErrorEventEmitter()
    var listening = EventEmitter0()
    var closed    = EventEmitter0()
    
    init() {
        self.server = Handle(closable: true)
        self.server.callback = self.onconnect
        uv_tcp_init(uv_default_loop(), self.server.handle)
    }
    
    deinit {
        print("Server deinit")
    }
    
    func listen(port: Int, host: String = "0.0.0.0", backlog: Int32 = 511, callback: (() -> ())? = nil) {

        // if callback is provided, add it as a handler to the 'listening' event
        if let callback = callback {
            self.listening.once(callback)
        }
        
        // bind to address
        let addr = UnsafeMutablePointer<sockaddr_in>.alloc(1);
        uv_ip4_addr(host.cStringUsingEncoding(0)!, Int32(port), addr)
        let result = uv_tcp_bind(server.handle, UnsafeMutablePointer<sockaddr>(addr), 0)
        addr.dealloc(1)

        if let err = Error(result: result) {
            self.error.emit(err)
            return
        }
        
        let listen_result = uv_listen(UnsafeMutablePointer<uv_stream_t>(server.handle), backlog, connection_cb)
        if let err = Error(result: listen_result) {
            self.error.emit(err)
            return
        }
        
        // ok. we are ready. emit the listening event on next tick
        nextTick {
            self.listening.emit()
        }
    }
    
    func close(callback: (() -> ())? = nil) {
        if let callback = callback {
            self.closed.once(callback)
        }
        self.server.close()
    }
    
    func onconnect(args: [AnyObject?]) {
        
        // initialize client stream
        let client = Socket()

        // manage clients set (notice the weak reference!)
        self.clients.insert(client)
        client.closed.once { [weak client] in
            if let client = client {
                self.clients.remove(client)
            }
            
            self.emitClosed()
        }
        
        let result = uv_accept(UnsafeMutablePointer<uv_stream_t>(self.server.handle), client.handle)
        
        if let error = Error(result: result) {
            client.close()
            self.error.emit(error)
        }
        else {
            self.connect.emit(client)
            client.resume()
        }
    }
    
    private func emitClosed() {
        if self.server.closed && self.clients.count == 0 {
            self.closed.emit()
        }
    }
}

private func connection_cb(handle: UnsafeMutablePointer<uv_stream_t>, status: Int32) {
    RawHandle.callback(handle, args: [], autoclose: false)
}