import UIKit
import UserNotifications

enum StartStopState {
    case stopped
    case started
}

class ViewController: UIViewController {
    
    struct Constants {
        static let pomodorro: Double = 25.0 * 60.0
    }
    
    @IBOutlet var countdownView: CountdownView!
    
    var pomodorroInterval = Constants.pomodorro
    var timer: Timer! = nil
    var startDate: Date! = nil
    var notificationManager: NotificationManager?
    
    private var startStopState: StartStopState = .stopped
    
    //начать обратный отсчет таймера
    func startCountdown() {
        startDate = Date()
        let destinationDate = startDate.addingTimeInterval(pomodorroInterval)
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
        if timeRemaining < 0 {
            timer.invalidate()
            timer = nil
            return
        }
        
        countdownView.timeTotal = Constants.pomodorro
        countdownView.timeRemaining = timeRemaining
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

