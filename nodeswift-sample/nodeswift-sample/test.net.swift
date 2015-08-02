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
    
    server.listening.once {
        print("Listening on TCP port 5000")
    }
    
    server.connection.on { connection in
        print("new connection")
        
        connection.data.on { data in
            if let str = data.stringContents {
                for client in server.clients {
                    client.write(str)
                }
                print(str, appendNewline: false)
                let command = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                switch command {
                case "terminate":
                    print("No more connections")
                    server.close()
                    
                case "pause":
                    print("pausing this connection")
                    connection.pause()
                    
                default:
                    print("unknown command")
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

func testClient() {
    let server = Server()
    server.listen(5000)
    server.connection.on { socket in
        print("SERVER: client connected")
        socket.data.on { data in
            print("SERVER: received data from client: \(data.stringContents!)")
        }
        
        var i = 0
        let timer = Timer()
        timer.setInterval(1000) {
            socket.write("Hello, client: \(i++)")
            if i == 10 {
                socket.close()
                clearInterval(timer)
            }
        }
        socket.closed.once {
            print("SERVER: connection closed")
        }
    }
    
    let client = Socket()
    client.connect(5000)
    client.connected.once {
        print("CLIENT: connected to server")
        client.write("Hello, server")
    }
    client.data.on { data in
        print("CLIENT: received data from server: \(data.stringContents!)")
        client.write("ECHO \(data.stringContents!)")
    }
    client.closed.once {
        print("CLIENT: connection closed")
    }
}