//
//  InterfaceController.swift
//  MyFirstWatchApp WatchKit Extension
//
//  Created by Yeming Tang on 5/18/20.
//  Copyright © 2020 Yeming Tang. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreMotion


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var recordingButton: WKInterfaceButton!
    @IBOutlet var sendButton: WKInterfaceButton!
    private let motionManager = CMMotionManager()
    private var isRecording: Bool = false
    private let session: WCSession = WCSession.default
    private var dateFormat = "y-MM-dd H:m:ss.SSSS"
    private var filePath: String? = nil
    private var fileHandle: FileHandle? = nil

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        session.delegate = self
        session.activate()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    @IBAction func recordingButtonClicked() {
        print("isRecording: " + isRecording.description)
        if isRecording {
            isRecording = false
            stopRecording()
            recordingButton.setTitle("Start recording")
        } else {
            isRecording = true
            startRecording()
            recordingButton.setTitle("Stop recording")
        }
    }
    
    @IBAction func sendButtonClicked() {
        guard let filePath = filePath else {
            return
        }
        let fileUrl = NSURL.fileURL(withPath: filePath)
        self.session.transferFile(fileUrl, metadata: nil)
    }
    
    func startRecording() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer is not available")
            return
        }
        print("Recording started.")
        
        self.filePath = createFile()
        do {
            let fileUrl = NSURL.fileURL(withPath: self.filePath!)
            self.fileHandle = try FileHandle(forWritingTo: fileUrl)
        } catch {
            print(error)
        }
        
        motionManager.accelerometerUpdateInterval = 0.01
        motionManager.startAccelerometerUpdates(
            to: OperationQueue.current!,
            withHandler: {
                (data, error) -> Void in
                guard let data = data, error == nil else {
                    print(error)
                    return
                }
                let bootTime = NSDate(timeIntervalSinceNow: -ProcessInfo.processInfo.systemUptime)
                let eventDate = NSDate(timeInterval: data.timestamp, since: bootTime as Date)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = self.dateFormat
                var row = String(format: "%@, %f, %f, %f",
                                 dateFormatter.string(from: eventDate as Date),
                                 data.acceleration.x,
                                 data.acceleration.y,
                                 data.acceleration.z)
                print(row)
                self.appendRowToFile(row: row + "\n")
        })
    }
    
    func stopRecording() {
        guard motionManager.isAccelerometerAvailable else {
            return
        }
        motionManager.stopAccelerometerUpdates()
        
        guard let fileHandle = fileHandle else {
            return
        }
        fileHandle.synchronizeFile()
        fileHandle.closeFile()
        print("Recording stopped.")
    }
    
    func createFile() -> String {
        let folderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let filePath = folderPath + "/sleepacc.txt"  // TODO: add date-time to filename
        print(filePath)
        
        let data = "timestamp, x, y, z\n"
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            } catch {
                print(error)
            }
        }
        do {
            let file = try data.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print(error)
        }
        return filePath
    }

    func appendRowToFile(row: String) {
        guard let fileHandle = fileHandle else {
            return
        }
        do {
            fileHandle.seekToEndOfFile()
            let textData = Data(row.utf8)
            fileHandle.write(textData)
        } catch {
            print(error)
        }
    }
    
}
