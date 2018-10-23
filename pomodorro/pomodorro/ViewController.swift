import UIKit
import UserNotifications
import Splitflap

enum StartStopState {
    case stopped
    case started
}

class ViewController: UIViewController {
    
    @IBOutlet var timeLabel: UILabel!
    var pomodorroInterval = 25.0 * 60.0
    var timer: Timer! = nil
    var startDate: Date! = nil
    var notificationManager: NotificationManager?
    
    private var startStopState: StartStopState = .stopped
    
    fileprivate func stringFromTimeInterval(interval: TimeInterval) -> String {
        let intervalInt = Int(interval)
        let minutes = intervalInt / 60
        let seconds = intervalInt % 60
        return NSString(format: "%0.2d:%0.2d",minutes,seconds) as String
    }
    
    //начать обратный отсчет таймера
    func startCountdown() {
        startDate = Date()
        let destinationDate = startDate.addingTimeInterval(1.0)
        notificationManager?.removeAllReminders()
        notificationManager?.createReminder(date: destinationDate, title: "Pomodorro", body: "It's time to take a ☕️")
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    //остановить обратный отсчет таймера
    func resetCountdown() {
        notificationManager?.removeAllReminders()
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    @IBAction func startStopToggle() {
        switch startStopState {
        case .stopped:
            startCountdown()
        case .started:
            resetCountdown()
        }
    }
    
    @objc func updateTimer() {
        let currentDate = Date()
        let deltaT = currentDate.timeIntervalSince1970 - self.startDate.timeIntervalSince1970
        let timeRemaining = self.pomodorroInterval - deltaT
        let timeString = self.stringFromTimeInterval(interval: timeRemaining)
        timeLabel.text = timeString
    }
    
    @IBAction func unwindToThisView(sender: UIStoryboardSegue) {
        guard let sourceViewController = sender.source as? DurationViewController else {
            return
        }
        
        resetCountdown()
        let duration = sourceViewController.datePicker.countDownDuration
        pomodorroInterval = duration
    }

}

