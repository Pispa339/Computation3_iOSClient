//
//  ViewController.swift
//  PongController
//
//  Created by Juho Pispa on 8.10.2015.
//  Copyright (c) 2015 Juho Pispa. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    var socketHandler: SocketHandler!
    let motionManager = CMMotionManager()
    
    @IBOutlet var yawLabel: UILabel!
    
    @IBOutlet var connectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().idleTimerDisabled = true
        socketHandler = SocketHandler()
        
        var currentPosition = 0.0
        var destPosition = 0.0
    
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMDeviceMotion!, error: NSError!) in
                
                self?.yawLabel.text = String(format:"%f", data.gravity.y)
                self?.convertAngleToSpeedString(data.gravity.y)
                
                //self!.socketHandler.sendStringMessage(xValueAsString + "\n")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connectOrDisconnect(sender: AnyObject) {
        if(self.socketHandler.isConnected() == false){
            self.socketHandler.tryToEstablishConnectionWithTimer()
            self.connectButton.setTitle("Disconnect", forState: UIControlState.Normal)
        }
        else{
            self.socketHandler.disconnectConnection()
            self.connectButton.setTitle("Connect", forState: UIControlState.Normal)
        }
        
    }
    func convertAngleToSpeedString(angle: Double) {
        var speedString: String = "still"
//        if((angle < 0 && angle > -0.1) || (angle > 0 && angle < 0.1)){
//            
//        }
        if(angle < -0.1 && angle > -0.5){
            speedString = "slowLeft"
        }
        
        if(angle > 0.1 && angle < 0.5){
            speedString = "slowRight"
        }
        
        if(angle < -0.5){
            speedString = "fastLeft"
        }
        
        if(angle > 0.5){
            speedString = "fastRight"
        }
        
        self.socketHandler.sendStringMessage(speedString + "\n")
        
    }

}

