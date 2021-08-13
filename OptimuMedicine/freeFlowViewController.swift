//
//  freeFlowViewController.swift
//  OptimuMedicine
//
//  Created by Jonzo Jimenez on 8/12/21.
//


//
// 8/13/2021 4:27 Can you read this?
//
import UIKit
import UserNotifications
import AVFAudio

class freeFlowViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var tankSizePicker: UIPickerView!
    @IBOutlet weak var psiTextField: UITextField!
    @IBOutlet weak var flowRateTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var startStopBtn: UIButton!
    
    
    var tankSize = ["D", "E", "M", "Kevlar"]
    var tank = 0.16
    var psi = 0.0
    
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
        
        // Assing self delegate on userNotificationCenter
        self.userNotificationCenter.delegate = self
        self.requestNotificationAuthorization()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        // Do any additional setup after loading the view.
        tankSizePicker.dataSource = self
        tankSizePicker.delegate = self
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        startStopBtn.setTitleColor(UIColor.green, for: .normal)
        
        //PsiTextField.text = String(psi)
       // PsiTextField.text = String(2200)
        //flowRateTextField.text = String(100)

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
            
            //timePassedInBack = (totalTimeInSec2 - totalTimeInSec)
            first = false
        }
        // I am adding 2 because when the conversion happens between foreground and background i think i lose 2 seconds
        timePassedInBack = (totalTimeInSec2 - totalTimeInSec)
        print(totalTimeInSec2, "total time insec")
        print(timePassedInBack, "this is how much time has passed in the back")
        print(countDown, "is in foreground")
        if (timerCounting == true) {
            // I am subrtracting 1 because when the conversion happens between foreground and background i think i lose a second
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
        // create new notifcation content instance
        let notificationContent = UNMutableNotificationContent()
        
        // Add the content to the notification content
        notificationContent.title = title
        notificationContent.body = body
        //notificationContent.sound = .defaultCriticalSound(withAudioVolume: 100)
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
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        //self.countDown = getTotalSecondsLeft()
        
        countDown = 0
        self.timer.invalidate()
        self.timerLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
        self.startStopBtn.setTitle("START", for: .normal)
        self.startStopBtn.setTitleColor(UIColor.green, for: .normal)
        // this should cancel my notifications that I have created when I press the pause button
        userNotificationCenter.removeAllPendingNotificationRequests()
        psiTextField.text = ""
        flowRateTextField.text = ""
        timeLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
    }
    
    @IBAction func startStopButtonTapped(_ sender: UIButton) {
        // Im adding this because if the countdown is at zero it will grab the formula and countdown using whatever has been calculated
        if countDown == 0 {
            self.countDown = getTotalSecondsLeft()
            first = true
        }
        if (timerCounting) {
            timerCounting = false
            timer.invalidate()
            startStopBtn.setTitle("START", for: .normal)
            startStopBtn.setTitleColor(UIColor.green, for: .normal)
            // this should cancel my notifications that I have created when I press the pause button
            userNotificationCenter.removeAllPendingNotificationRequests()
        } else {
            if countDown >= 600 {
                let minuteLeft = countDown - 600
                print(countDown)
                sendNotification(timeInterval: Double(minuteLeft), title: "10 Minutes Left", body: "FREE FLOW: there is 10 minutes left", sound: "critalAlarm.wav")
            }
            if countDown >= 60 {
                let onesecond = countDown - 60
                print(countDown)
                sendNotification(timeInterval: Double(onesecond), title: "TIMER IS DONE", body: "FREE FLOW: there is 1 minute left", sound: "iphone_alarm.mp3")
            }
            timerCounting = true
            startStopBtn.setTitle("STOP", for: .normal)
            startStopBtn.setTitleColor(UIColor.red, for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
            timer.tolerance = 0.1
            RunLoop.current.add(timer,forMode: .common)
            
            // when the timer is counting down it does this part of the code
            print(countDown)
        }
    }
    @objc func timerCounter() -> Void {
        //countDown = countDown - 1
        //let t = getTotalSecondsLeft()
        countDown -= 1
        // if count is on 0 or less than zero my timer will stop
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
    
    // this function returns the total seconds left in free flow calculation
    func getTotalSecondsLeft() -> Int {
        guard let psiString = psiTextField.text else { return 0 }
        guard let psi = Double(psiString) else { return 0 }
        
        guard let flowRateString = flowRateTextField.text else {return 0}
        guard let flowRate = Double(flowRateString) else { return 0}
        
        // total time in minutes
        //timeLabel.text = String(format: "%.2f", total)
        let totalinSeconds = ((psi - 200) * tank / flowRate) * 60
        //let totalRounded = (format: "%.2f", total)
        //let secondsLeft = Int(totalRounded * 60)
        
        
        
        // need to make sure if the numbers are zero instead of trying to calucluate it we can just
        // make if statement saying if one of them is zero to not do the equation
        
        return Int(round(totalinSeconds))
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
        print(tank)
    }

}
