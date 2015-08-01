//
//  fs.swift
//  swiftuv
//
//  Created by Elad Ben-Israel on 7/26/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

func mkdir(path: String, mode: Int32, callback: (Error?) -> ()) {
    let req = Handle<uv_fs_t>(closable: false)
    req.callback = { args in
        let result = req.handle.memory.result
        let err = Error(result: result)
        uv_fs_req_cleanup(req.handle)
        callback(err)
    }
    uv_fs_mkdir(uv_default_loop(), req.handle, (path as NSString).UTF8String, mode) { handle in
        RawHandle.callback(handle, args: [], autoclose: true)
    }
}