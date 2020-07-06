//
//  ViewController.swift
//  MyFirstWatchApp
//
//  Created by Yeming Tang on 5/18/20.
//  Copyright © 2020 Yeming Tang. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    private let session: WCSession = WCSession.default
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        session.delegate = self
        session.activate()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("File received: ")
        print(file.fileURL)
        
        let folderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let filePath: String = folderPath + "/sleepacc.txt"
        let fileUrl = NSURL.fileURL(withPath: filePath)

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.moveItem(at: file.fileURL, to: fileUrl)
            } catch {
                print(error)
            }
        }
    }

}

