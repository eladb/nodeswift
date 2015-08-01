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
    
    private var rawhandle_: UnsafeMutablePointer<uv_handle_t>?
    private var dealloc: (UnsafeMutablePointer<Void>) -> ()
    var callback: ((args: [AnyObject]) -> ())?

    var rawhandle: UnsafeMutablePointer<uv_handle_t> {
        return self.rawhandle_!
    }
    
    init(alloc: () -> UnsafeMutablePointer<Void>, dealloc: (UnsafeMutablePointer<Void>) -> ()) {
        self.rawhandle_ = UnsafeMutablePointer<uv_handle_t>(alloc())
        self.dealloc = dealloc
        
        // this acts as a refcount++
        // we are using the handle itself as the key to the dictionary
        RawHandle.handles[self.rawhandle_!] = self
    }
    
    deinit {
        assert(self.rawhandle_ == nil, "Handles must be explicitly closed with close()")
    }
    
    // Returns true if the handle is closed
    var closed: Bool {
        return self.rawhandle_ == nil
    }
    
    var hashValue: Int {
        assert(self.rawhandle_ != nil, "Trying to access a released handle")
        return self.rawhandle_!.hashValue
    }
    
    func call(args: [AnyObject] = [], autoclose: Bool) {
        self.callback?(args: args)
        if autoclose {
            self.close()
        }
    }
    
    func close(callback: (() -> ())? = nil) {
        if self.closed { return }
        
        let handle = self.rawhandle
        
        // call close and dealloc the handle at the end
        self.callback = { _ in
            callback?()

            // remove handle from allocation map, which means it will deinit
            RawHandle.handles.removeValueForKey(handle)
            self.dealloc(UnsafeMutablePointer<Void>(self.rawhandle_!))
            self.rawhandle_ = nil
            self.callback = nil
        }
        
        uv_close(self.rawhandle, close_cb)
    }

    static func callback(handle: UnsafeMutablePointer<Void>, args: [AnyObject] = [], autoclose: Bool) {
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
    init() {
        super.init(
            alloc: { return UnsafeMutablePointer<Void>(UnsafeMutablePointer<T>.alloc(1)) },
            dealloc: { (h: UnsafeMutablePointer<Void>) in UnsafeMutablePointer<T>(h).dealloc(1) }
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
