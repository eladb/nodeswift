//
//  handles.swift
//  swiftuv
//
//  Created by Elad Ben-Israel on 7/26/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation


class HandleBase {
    private static var handles = Dictionary<UnsafeMutablePointer<Void>, HandleBase>()
}

class Handle<T>: HandleBase {
    private let callback: (Handle<T>) -> ()
    private var uvhandle: UnsafeMutablePointer<T>?
    
    init(_ callback: (Handle<T>) -> ()) {
        self.callback = callback
        self.uvhandle = UnsafeMutablePointer<T>.alloc(1)
        super.init()
        Handle.wrap(self.uvhandle!, obj: self)
    }
    
    deinit {
        assert(self.uvhandle == nil, "Handle was not released explicitly using release()")
    }
    
    var handle: UnsafeMutablePointer<T> {
        assert(self.uvhandle != nil, "Trying to access a released handle")
        return self.uvhandle!
    }
    
    func call() -> Handle<T> {
        self.callback(self)
        return self
    }
    
    func release() {
        assert(self.uvhandle != nil, "Handle already released")
        let handle = self.uvhandle!
        let key = UnsafeMutablePointer<uv_handle_t>(handle).memory.data
        HandleBase.handles.removeValueForKey(key)
        handle.dealloc(1)
        self.uvhandle = nil
    }
    
    static func wrap(handle: UnsafeMutablePointer<T>, obj: Handle<T>) {
        let key = UnsafeMutablePointer<Void>(handle)
        HandleBase.handles[key] = obj;
        UnsafeMutablePointer<uv_handle_t>(handle).memory.data = key
    }
    
    static func unwrap(handle: UnsafeMutablePointer<T>) -> Handle<T> {
        let key = UnsafeMutablePointer<uv_handle_t>(handle).memory.data
        let obj = HandleBase.handles[key]
        assert(obj != nil, "Cannot unwrap handle")
        return obj as! Handle<T>
    }
}
