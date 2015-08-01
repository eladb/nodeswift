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
    
    var connect = EventEmitter1<Socket>()
    var error = ErrorEventEmitter()
    
    init() {
        self.server = Handle()
        self.server.callback = self.onconnect
        uv_tcp_init(uv_default_loop(), self.server.handle)
    }
    
    deinit {
        print("Server deinit")
    }
    
    func listen(port: Int, host: String = "0.0.0.0", backlog: Int32 = 511, callback: ((Error?) -> ())? = nil) {

        // bind to address
        let addr = UnsafeMutablePointer<sockaddr_in>.alloc(1);
        uv_ip4_addr(host.cStringUsingEncoding(0)!, Int32(port), addr)
        let result = uv_tcp_bind(server.handle, UnsafeMutablePointer<sockaddr>(addr), 0)
        addr.dealloc(1)

        if let err = Error(result: result) {
            if let callback = callback {
                callback(err)
            }
            else {
                self.error.emit(err)
            }
            return
        }
        
        let listen_result = uv_listen(UnsafeMutablePointer<uv_stream_t>(server.handle), backlog, connection_cb)
        if let err = Error(result: listen_result) {
            if let callback = callback {
                callback(err)
            }
            else {
                self.error.emit(err)
            }
            return
        }
    }
    
    func close() {
        // close all clients
        for client in self.clients {
            client.close()
        }

        self.server.close()
    }
    
    func onconnect(args: [AnyObject]) {
        // initialize client stream
        
        let client = Socket()

        // manage clients set
        self.clients.insert(client)
        
        print("registrying to receive end event")
        client.closed.once {
            print("removing client from clients list")
            self.clients.remove(client)
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
}

private func connection_cb(handle: UnsafeMutablePointer<uv_stream_t>, status: Int32) {
    RawHandle.callback(handle, args: [], autoclose: false)
}