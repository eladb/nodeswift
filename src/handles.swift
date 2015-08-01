//
//  handles.swift
//  swiftuv
//
//  Created by Elad Ben-Israel on 7/26/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation


class RawHandle: Hashable, Equatable {
    private static var handles = Dictionary<UnsafeMutablePointer<Void>, RawHandle>()
    
    private var hash = UnsafeMutablePointer<Int8>.alloc(1)
    private var rawhandle_: UnsafeMutablePointer<uv_handle_t>?
    private var dealloc: (UnsafeMutablePointer<Void>) -> ()
    private let closable: Bool
    
    var callback: ((args: [AnyObject?]) -> ())?

    var rawhandle: UnsafeMutablePointer<uv_handle_t> {
        return self.rawhandle_!
    }
    
    init(alloc: () -> UnsafeMutablePointer<Void>, dealloc: (UnsafeMutablePointer<Void>) -> (), closable: Bool) {
        self.rawhandle_ = UnsafeMutablePointer<uv_handle_t>(alloc())
        self.dealloc = dealloc
        self.closable = closable
        
        // this acts as a refcount++
        // we are using the handle itself as the key to the dictionary
        RawHandle.handles[self.rawhandle_!] = self
    }
    
    deinit {
        assert(self.rawhandle_ == nil, "Handles must be explicitly closed with close()")
        self.hash.dealloc(1)
    }
    
    // Returns true if the handle is closed
    var closed: Bool {
        return self.rawhandle_ == nil
    }
    
    var hashValue: Int {
        return self.hash.hashValue
    }
    
    func release() {
        RawHandle.handles.removeValueForKey(self.rawhandle)
        self.dealloc(UnsafeMutablePointer<Void>(self.rawhandle))
        self.rawhandle_ = nil
        self.callback = nil
    }
    
    func close(callback: (() -> ())? = nil) {
        if self.closed { return }
        
        if self.closable {
            // call close and dealloc the handle at the end
            self.callback = { _ in
                self.release()
                callback?()
            }
            
            uv_close(self.rawhandle, close_cb)
        }
        else {
            self.release()
            callback?()
        }
    }

    static func callback(handle: UnsafeMutablePointer<Void>, args: [AnyObject?] = [], autoclose: Bool) {
        let rawhandle = UnsafeMutablePointer<uv_handle_t>(handle)
        if let handle = RawHandle.handles[rawhandle] {
            handle.callback?(args: args)
            if autoclose {
                handle.close()
            }
        }
    }
}

func ==(lhs: RawHandle, rhs: RawHandle) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class Handle<T>: RawHandle {
    init(closable: Bool) {
        super.init(
            alloc: { return UnsafeMutablePointer<Void>(UnsafeMutablePointer<T>.alloc(1)) },
            dealloc: { (h: UnsafeMutablePointer<Void>) in UnsafeMutablePointer<T>(h).dealloc(1) },
            closable: closable
        )
    }
    
    var handle: UnsafeMutablePointer<T> {
        return UnsafeMutablePointer<T>(self.rawhandle)
    }
}

func ==<T>(lhs: Handle<T>, rhs: Handle<T>) -> Bool {
    return lhs.handle == rhs.handle
}

func close_cb(handle: UnsafeMutablePointer<uv_handle_t>) {
    RawHandle.callback(handle, args: [], autoclose: false) // we are now closing haha
}
