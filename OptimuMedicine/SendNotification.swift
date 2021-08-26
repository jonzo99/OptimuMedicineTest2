//
//  SendNotification.swift
//  OptimuMedicine
//
//  Created by Jonzo Jimenez on 8/19/21.
//
//
// test to see if you can pull code
//
import Foundation
import UserNotifications

struct SendNotification {
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    func sendLocalNotification(timeInterval: Double, title: String, body: String, sound: String) {
        
            
        // create new notifcation content instance
        let notificationContent = UNMutableNotificationContent()
            
        // Add the content to the notification content
        // this should alow me to create something like HamiltonIdentifier and another one for free flow
        // so Instead of deleting all the notifications from the app I just do it for the single calculations
        //notificationContent.threadIdentifier
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.sound = .criticalSoundNamed(UNNotificationSoundName.init(rawValue: sound), withAudioVolume: 1.0)
        // this is the little number on the app that shows you how many notifications you have left
        //notificationContent.badge = NSNumber(value: 1)
            
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        // create a unique indentifier to be able to get multiople notifications
        let identifier = UUID.init().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
        print(trigger.timeInterval, "jfkdsfjs")
        print(identifier)
            
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
}
/*
func sendNotification(timeInterval: Double, title: String, body: String, sound: String) {
    
    
    //let alert = UIAlertController(title: "hey", message: "that is hwy", preferredStyle: .alert)
    //alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
    //alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
    //self.present(alert, animated: true)
    
    // create new notifcation content instance
    let notificationContent = UNMutableNotificationContent()
    
    // Add the content to the notification content
    // this should alow me to create something like HamiltonIdentifier and another one for free flow
    // so Instead of deleting all the notifications from the app I just do it for the single calculations
    //notificationContent.threadIdentifier
    notificationContent.title = title
    notificationContent.body = body
    notificationContent.sound = .criticalSoundNamed(UNNotificationSoundName.init(rawValue: sound), withAudioVolume: 1.0)
    // this is the little number on the app that shows you how many notifications you have left
    //notificationContent.badge = NSNumber(value: 1)
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
    
    // create a unique indentifier to be able to get multiople notifications
    let identifier = UUID.init().uuidString
    let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
    print(trigger.timeInterval, "jfkdsfjs")
    print(identifier)
    
    userNotificationCenter.add(request) { (error) in
        if let error = error {
            print("Notification Error: ", error)
        }
    }
}
*/
