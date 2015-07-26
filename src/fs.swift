//
//  fs.swift
//  swiftuv
//
//  Created by Elad Ben-Israel on 7/26/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

func mkdir(path: String, mode: Int32, callback: (Error?) -> ()) {
    let req = Handle<uv_fs_t> { handle in
        let result = handle.handle.memory.result
        let err = Error(result: result)
        callback(err)
    }
    uv_fs_mkdir(uv_default_loop(), req.handle, (path as NSString).UTF8String, mode) { handle in
        Handle.unwrap(handle).call().release()
        uv_fs_req_cleanup(handle)
    }
}