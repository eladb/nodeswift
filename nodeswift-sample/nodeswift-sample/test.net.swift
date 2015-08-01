//
//  test.net.swift
//  nodeswift-sample
//
//  Created by Elad Ben-Israel on 8/1/15.
//  Copyright © 2015 Citylifeapps Inc. All rights reserved.
//

import Foundation

func testNet() {
    let server = Server()
    server.listen(5000)
    print("Listening on TCP port 5000")
    
    server.connect.on { connection in
        print("connected: \(connection)")
        connection.data.on { data in
            if let str = data.stringContents {
                print(str, appendNewline: false)
                let command = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if command == "terminate" {
                    print("No more connections")
                    server.close()
                }
            }
        }
        connection.end.once {
            print("EOF")
        }
        
        connection.closed.once {
            print("closed")
        }
    }
    
    server.closed.once {
        print("server closed")
    }
}