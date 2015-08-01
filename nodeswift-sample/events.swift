//
//  events.swift
//  nodeswift-sample
//
//  Created by Elad Ben-Israel on 7/28/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

class EventHandler: Hashable, Equatable {
    // allocate 1-byte and use it's hashValue (address) as the hashValue of the EventHandler
    let ptr = UnsafeMutablePointer<Int8>.alloc(1)
    var hashValue: Int { return ptr.hashValue }
    deinit { self.ptr.dealloc(1) }

    var callback: (([AnyObject]) -> ())?
    init(_ callback: (([AnyObject]) -> ())?) {
        self.callback = callback
    }
}

func ==(lhs: EventHandler, rhs: EventHandler) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class EventEmitter {
    private var handlers = Set<EventHandler>();
    func debug(s: AnyObject) {
        
    }
    func emit(args: [AnyObject]) -> Int {
        debug("emit (\(self.handlers.count) handlers)")
        var calls = 0
        for handler in self.handlers {
            if let callback = handler.callback {
                callback(args)
                calls++
            }
        }
        return calls
    }
    func addListener(listener: (([AnyObject]) -> ())?) -> EventHandler {
        debug("addListener (\(self.handlers.count) handlers)")
        let handler = EventHandler(listener)
        self.handlers.insert(handler)
        return handler
    }
    func removeListener(handler: EventHandler) {
        debug("removeListener (\(self.handlers.count) handlers)")
        self.handlers.remove(handler)
    }
    func once(listener: ([AnyObject]) -> ()) -> EventHandler {
        debug("once (\(self.handlers.count) handlers)")
        let handler = self.addListener(nil)
        handler.callback = { args in
            listener(args)
            self.removeListener(handler)
        }
        return handler
    }
    func on(listener: ([AnyObject]) -> ()) -> EventHandler {
        debug("on (\(self.handlers.count) handlers)")
        return self.addListener(listener)
    }
}

class EventEmitter2<A: AnyObject, B: AnyObject> {
    private let emitter = EventEmitter()
    func emit(a: A, b: B) -> Int { return self.emitter.emit([ a, b ]) }
    func on(callback: (A, B) -> ()) -> EventHandler { return self.emitter.on { args in callback(args[0] as! A, args[1] as! B) } }
    func once(callback: (A, B) -> ()) -> EventHandler { return self.emitter.once { args in callback(args[0] as! A, args[1] as! B) } }
    func removeListener(handler: EventHandler) { self.emitter.removeListener(handler) }
}

class EventEmitter1<A: AnyObject> {
    private let emitter = EventEmitter()
    func emit(a: A) -> Int { return self.emitter.emit([a]) }
    func on(callback: (A) -> ()) -> EventHandler { return self.emitter.on { args in callback(args[0] as! A) } }
    func once(callback: (A) -> ()) -> EventHandler { return self.emitter.once { args in callback(args[0] as! A) } }
    func removeListener(handler: EventHandler) { self.emitter.removeListener(handler) }
}

class EventEmitter0 {
    private let emitter = EventEmitter()
    func emit() -> Int { return self.emitter.emit([]) }
    func on(callback: () -> ()) -> EventHandler { return self.emitter.on { _ in callback() } }
    func once(callback: () -> ()) -> EventHandler { return self.emitter.once { _ in callback() } }
    func removeListener(handler: EventHandler) { self.emitter.removeListener(handler) }
}

class ErrorEventEmitter: EventEmitter1<Error> {
    override func emit(error: Error) -> Int {
        let calls = super.emit(error)
        assert(calls > 0, "Unhandled 'error' event: \(error)")
        return calls
    }
}