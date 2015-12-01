//
//  SocketHandler.swift
//  PongController
//
//  Created by Juho Pispa on 8.10.2015.
//  Copyright (c) 2015 Juho Pispa. All rights reserved.
//

import Foundation

class SocketHandler: NSObject, GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate{
    var tcpSocket: GCDAsyncSocket!
    var udpSocket: GCDAsyncUdpSocket!
    var myHost = ""
    var myPort: UInt16 = 0
    var timer: NSTimer!
    var connected = false
    
    
    convenience override init() {
        self.init(fromString: "")
        self.setupUDPSocket()
        self.setupTCPSocket()
    }
    
    init(fromString string: NSString) {
        myHost = ""
        super.init()
    }
    
    func isConnected() -> Bool {
        return self.connected
    }
    
    func setupUDPSocket() {
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        var error: NSError?
        udpSocket.enableBroadcast(true, error: &error)
    
        udpSocket.bindToPort(0, error: &error)
        if(error != nil) {
            print("Error binding \(error!.description)\n")
        }
            return
        
    }
    
    func setupTCPSocket() {
        tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
    }
    
    func tryToEstablishConnectionWithTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self,
                            selector: "broadCastAndListen", userInfo: nil, repeats: true)
    }
    
    func broadCastAndListen() {
        if((tcpSocket.isConnected) != false){
            timer.invalidate()
            return
        }
        self.listenToUDPResponse()
        self.UDPBroadcast()
    }
    
    func UDPBroadcast() {
        var dataToSend: NSData = "PONG_REQUEST".dataUsingEncoding(NSUTF8StringEncoding)!
        udpSocket.sendData(dataToSend, toHost: "255.255.255.255", port: 8888, withTimeout: -10, tag: 0)
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
        print("Sent data through UDP with tag: \(tag)\n")
    }
    
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        //print("Data send through TCP-socket \n")
    }
    
    func listenToUDPResponse() {
        var error: NSError?
        (udpSocket.beginReceiving(&error))
        if(error != nil){
            print("Error receiving \(error!.description)\n")
            return
        }
        
    }
    
    func reconnectAfterTimeout(timer: NSTimer) {
        self.tryToEstablishConnectionWithTimer()
        //timer.invalidate()
    }
    
    func socketDidDisconnect(socket: GCDAsyncSocket, err: NSError) {
        print("TCP Socket disconnected: \(err.description)\n")
        self.setupUDPSocket()
        self.tryToEstablishConnectionWithTimer()
        self.connected = false
    }
    
    func connectThroughTCP(ipAddress: String, port: UInt16) {
        var error: NSError?
        tcpSocket.connectToHost(ipAddress, onPort: port, error: &error)
        if(error != nil){
            print("Error connecting through TCP socket: \(error?.description)\n")
            self.setupUDPSocket()
            self.tryToEstablishConnectionWithTimer()
        }
        
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        var msg = NSString(data: data, encoding: NSASCIIStringEncoding)
        print("received UDP response: \(msg!)\n")
        if((msg) != nil && msg?.isEqualToString("PONG_CONNECTING_DATA") != false)
        {
            var host: NSString?
            var port: UInt16 = 0
            GCDAsyncUdpSocket.getHost(&host, port: &port, fromAddress:address)
            myHost = (host as? String)!
            myPort = port
            print("Host: \(host!) Port:\(port)\n")
            udpSocket.close()
            timer.invalidate()
            self.connectThroughTCP(myHost, port: myPort)
        }
        else
        {
            var host: NSString?
            var port: UInt16 = 0
            GCDAsyncUdpSocket.getHost(&host, port: &port, fromAddress:address)
            
            print("Unknown message: \(host) : \(port)\n")
        }
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        var msg = NSString(data: data, encoding: NSASCIIStringEncoding)
        print("Received msg from TCP-socket: \(msg)\n")
        
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        print("TCP-socket connection made with: \(host) : \(port)\n")
        self.connected = true
    }
    
    func sendStringMessage(stringToSend: String) {
        let data = stringToSend.dataUsingEncoding(NSUTF8StringEncoding)
        self.sendDataThroughTCP(data)
    }
    
    func sendDataThroughTCP(dataToSend: NSData!) {
        tcpSocket.writeData(dataToSend, withTimeout: -1, tag: 99)
    }
    
    func disconnectConnection() {
        self.tcpSocket.disconnect()
    }

}


