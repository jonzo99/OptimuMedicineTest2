//
//  HamiltonViewController.swift
//  OptimuMedicine
//
//  Created by Jonzo Jimenez on 8/12/21.
//

import UIKit
import UserNotifications
import AVFAudio

class HamiltonViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var tankSizePicker: UIPickerView!
    
    @IBOutlet weak var psiTextField: UITextField!
    @IBOutlet weak var fi02TextField: UITextField!
    @IBOutlet weak var rateTextField: UITextField!
    @IBOutlet weak var vtTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var startStopBtn: UIButton!
    
    
    var tankSize = ["D", "E", "M", "Kevlar"]
    var tank = 0.16
    var psi = 0.0
    var patient = 3.0
    var timer = Timer()
    var countDown = 0
    var timerCounting = false
    
    var hrs = 0
    var min = 0
    var sec = 0
    var hrs2 = 0
    var min2 = 0
    var sec2 = 0
    var diffHrs = 0
    var diffMins = 0
    var diffSecs = 0
    var totalTimeInSec = 0
    var totalTimeInSec2 = 0
    var timePassedInBack = 0
    var first = false
    
    let userNotificationCenter = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        super.viewDidLoad()
        
            // go into sceneDelagate and scroll down into the background inforamtion
            
            // Assing self delegate on userNotificationCenter
            self.userNotificationCenter.delegate = self
            self.requestNotificationAuthorization()
            
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
            
            // Do any additional setup after loading the view.
            tankSizePicker.dataSource = self
            tankSizePicker.delegate = self
            
            // these two lines of code allows me to dismiss the keyboard whenn
            // I click outside of the keyboard
            let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
            view.addGestureRecognizer(tap)
            startStopBtn.setTitleColor(UIColor.green, for: .normal)
        
    }
    
    @objc func appMovedToBackground() {
        totalTimeInSec = 0
        let date = Date()
        let calendar = Calendar.current
        
        // if i set the calender to this timezone I dont have to worry about
        // the person going throught the time zones since i only care about how much seconds has passed
        //calendar.timeZone = TimeZone(identifier: "UTC")
        print("")
        print("app move to the background")
        print("")
        let components = calendar.dateComponents([.hour, .year, .minute, .second], from: date)
        print("all comp", components)
        hrs = calendar.component(.hour, from: date)
        min = calendar.component(.minute, from: date)
        sec = calendar.component(.second, from: date)
        
        totalTimeInSec = (min * 60) + (hrs * 3600) + sec
        
        print(totalTimeInSec)
        print(hrs, min, sec)
    }
    
    @objc func appMovedToForeground() {
        totalTimeInSec2 = 0
        let date = Date()
        let calendar = Calendar.current
        print("")
        print("App moved to foreGround")
        print("")
        let components = calendar.dateComponents([.hour, .year, .minute, .second], from: date)
        print("all comp", components)
        hrs2 = calendar.component(.hour, from: date)
        min2 = calendar.component(.minute, from: date)
        sec2 = calendar.component(.second, from: date)
        
        print(hrs2, min2, sec2)
        
        
        // i might need an if statement to check if c
        totalTimeInSec2 = (min2 * 60) + (hrs2 * 3600) + sec2
        print(totalTimeInSec2, "   ", totalTimeInSec)
        print(first, "    ", timerCounting)
        if (first == true && timerCounting == true) {
            first = false
        }
        timePassedInBack = (totalTimeInSec2 - totalTimeInSec)
        print(totalTimeInSec2, "total time insec")
        print(timePassedInBack, "this is how much time has passed in the back")
        print(countDown, "is in foreground")
        if (timerCounting == true) {
            // I am subrtracting 2 because when the conversion happens between foreground and background i think i lose a second
            countDown = countDown - (timePassedInBack - 2)
        }
        
        print(countDown, "app is in foreground2")
    }
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound, .criticalAlert)
        
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("ERror", error)
            }
        }
    }
    
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
    @IBAction func calcButtonTapped(_ sender: UIButton) {
        let total = getTotalSecondsLeft()
        let time = secondsToHoursMinutesSeconds(seconds: total)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        timeLabel.text = timeString
        //timeLabel.text = String(getTotalSecondsLeft())
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        self.countDown = getTotalSecondsLeft()
        self.timer.invalidate()
        self.timerLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
        self.startStopBtn.setTitle("START", for: .normal)
        self.startStopBtn.setTitleColor(UIColor.green, for: .normal)
        // this should cancel my notifications that I have created when I press the pause button
        // I just added this
        // if i press the reset button it should remove all the pending notifications request
        userNotificationCenter.removeAllPendingNotificationRequests()
        
        // instead of setting all the values to zero I could try to reset the values back to the placeholder text
        psiTextField.text = String(0)
        fi02TextField.text = String(0)
        rateTextField.text = String(0)
        vtTextField.text = String(0)
        timeLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
    }
    
    @IBAction func startStopButtonTapped(_ sender: UIButton) {
        // this might have to be put in the else if the user has to double tap the start button
        if countDown == 0 {
            self.countDown = getTotalSecondsLeft()
            first = true
        }
        if (timerCounting) {
            // this is when the the timer is paused and not counting down
            timerCounting = false
            timer.invalidate()
            startStopBtn.setTitle("START", for: .normal)
            startStopBtn.setTitleColor(UIColor.green, for: .normal)
            // this should cancel my notifications that I have created when I press the pause button
            userNotificationCenter.removeAllPendingNotificationRequests()
        } else {
            
            // this thing works to get the timer count since when i hit start again it
            // it gets whatever the countDown is
            // the if statement is here because if the timer is already less than 10 seconds that means
            // this timer doesnt need to go off and if it tries i get an error
            if countDown >= 600 {
                let minuteLeft = countDown - 600
                print(countDown)
                sendNotification(timeInterval: Double(minuteLeft), title: "10 Minutes Left", body: "HAMILTON: there is 10 minutes left", sound: "critalAlarm.wav")
            }
            if countDown >= 60 {
                print("I went throud the 60 sec loop")
                let tenseconds = countDown - 60
                print(countDown)
                sendNotification(timeInterval: Double(tenseconds), title: "60 Seconds Left", body: "HAMILTON: there is 60 seconds left", sound: "iphone_alarm.mp3")
                
                // I know when i hit this time mark I know that there is 10 seconds left
                // so what if I set the countDown = 10 that would mean that everthing would change into
                // 10 including the timer countdown
            }
                
            timerCounting = true
            startStopBtn.setTitle("STOP", for: .normal)
            startStopBtn.setTitleColor(UIColor.red, for: .normal)
            // every time the this code is run the code in timerCounter is run once
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
            timer.tolerance = 0.1
            RunLoop.current.add(timer,forMode: .common)
                
            // when the timer is counting down it does this part of the code
            print(countDown)
        }
    }
    
    @objc func timerCounter() -> Void {
        print(countDown, "this is in timerCounter()")
        countDown -= 1
        if countDown <= 0 {
            timer.invalidate()
        }
        // if i want to add a message when it hits a certain amount of seconds i should make phone vibrate show notification
        let time = secondsToHoursMinutesSeconds(seconds: countDown)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        timerLabel.text = timeString
    }
    
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
    func makeTimeString(hours: Int, minutes: Int, seconds : Int) ->  String {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += ":"
        timeString += String(format: "%02d", minutes)
        timeString += ":"
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    
    func getTotalSecondsLeft() -> Int {
        guard let psiStr = psiTextField.text else { return 0 }
        guard let psi = Double(psiStr) else { return 0 }
        
        guard let fi02Str = fi02TextField.text else { return 0 }
        guard let fi02 = Double(fi02Str) else { return 0 }
        
        // changes the input from the textfields into doubles
        guard let rateStr = rateTextField.text else { return 0 }
        guard let rate = Double(rateStr) else { return 0 }
        
        guard let vtStr = vtTextField.text else { return 0 }
        guard let vt = Double(vtStr) else { return 0 }
        
        let a = tank * psi
        let b = (rate * vt / 1000 * 1.1) + patient
        let c = (fi02 - 20.9) / 79.1
        
        // total time in seconds
        let totalTimeInSeconds = (1 / (b * c) * a) * 60
        return Int(round(totalTimeInSeconds))
        //timeLabel.text = String(format:"%.2f",totalTimeInHours)
    }
    
    
    @IBAction func patientDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            patient = 3
        case 1:
            patient = 4
        default:
            patient = 3
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tankSize.count
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = tankSize[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor:UIColor.black])
        return myTitle
    }
    
    // this checks if the user changes the scroller
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(tankSize[row])
        if (tankSize[row] == "D") {
            tank = 0.16
        } else if (tankSize[row] == "E") {
            tank = 0.28
        } else if (tankSize[row] == "M") {
            tank = 1.56
        } else if (tankSize[row] == "Kevlar") {
            tank = 3.14
        }
        // this did not work
        // I think i can add an else statement at the very end and make tank = .16
        // since the one it shows first is D when nothing is moved
        print(tank)
    }
}
