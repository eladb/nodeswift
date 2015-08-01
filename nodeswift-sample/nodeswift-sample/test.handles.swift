//
//  test.handles.swift
//  nodeswift-sample
//
//  Created by Elad Ben-Israel on 8/1/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

/*
* This test exercises the memory management of handles.
* It allocates 100 handle objects. It then invokes all of their
* callbacks, some with autoclose: true and some with autoclose: false.
* It then verifies that indeed half were closed. Then, it closes all the rest
* and validates that no references are left to these handles
*/
func testHandleMemoryManagement() {
    class DummyHandle: Handle<uv_tcp_t> {
        static var objectCounter = 0;
        static var callbackCounter = 0;
        init() {
            super.init(closable: true)
            DummyHandle.objectCounter++
            uv_tcp_init(uv_default_loop(), self.handle)
            self.callback = { _ in DummyHandle.callbackCounter++ }
        }
        deinit {
            DummyHandle.objectCounter--
        }
    }
    
    // first create a bunch of objects
    var objects = [DummyHandle]()
    for _ in 0..<100 {
        objects.append(DummyHandle())
    }
    
    assert(DummyHandle.objectCounter == 100)
    
    // call half the callback with autoclose and half without
    for i in 0..<50 {
        RawHandle.callback(objects[i].handle, args: [ ], autoclose: false)
    }
    for i in 50..<100 {
        RawHandle.callback(objects[i].handle, args: [ ], autoclose: true)
    }
    
    // wait a little bit and verify that indeed half are closed
    setTimeout(1000) {
        assert(DummyHandle.callbackCounter == 100)
        assert(objects.filter({ $0.closed }).count == objects.count/2)
        
        // now close them all (the ones already closed should be fine)
        for obj in objects {
            obj.close()
        }
        
        setTimeout(1000) {
            assert(objects.filter({ $0.closed }).count == objects.count)
            
            // now delete the array so all ref counts to the handles are released
            objects.removeAll()
            
            // expect to see zero objects
            assert(DummyHandle.objectCounter == 0, "Found a leak. Some objects did not deinit")
            
            print("SUCCESS")
        }
    }
}