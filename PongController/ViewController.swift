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
    
    @IBOutlet var rollLabel: UILabel!
    
    @IBOutlet var pitchLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socketHandler = SocketHandler()
        
        var currentPosition = 0.0
        var destPosition = 0.0
        
//        if motionManager.accelerometerAvailable {
//            motionManager.accelerometerUpdateInterval = 0.1
//            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
//                [weak self] (data: CMAccelerometerData!, error: NSError!) in
//                
//                //self?.rollLabel.text = String(format:"%f", data.acceleration.x)
//                self?.yawLabel.text = String(format:"%f", data.acceleration.y)
//                if data.acceleration.y < -0.02 {
//                    currentPosition = currentPosition + data.acceleration.y * 100
//                }
//                    
//                else if data.acceleration.y > 0.02 {
//                    currentPosition = currentPosition + data.acceleration.y * 100
//                }
//                
//                self?.pitchLabel.text = String(format:"%f", currentPosition)
//            }
//        }
        
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMDeviceMotion!, error: NSError!) in
                
                self?.yawLabel.text = String(format:"%f", data.gravity.y)
                self?.rollLabel.text = String(format:"%f", data.gravity.x)
                
                var xValueAsString = String(format:"%f", data.gravity.x)
                
                self!.socketHandler.sendStringMessage(xValueAsString + "\n")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

