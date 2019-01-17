import UIKit
import UserNotifications

enum StartStopState {
    case stopped
    case running
    case paused
}

class ViewController: UIViewController {
    
    struct Constants {
        static let pomodorro: Double = 25.0 * 60.0
    }
    
    @IBOutlet var countdownView: CountdownView!
    
    ///User selected time interval
    var timeTotal = 10.0
    var timer: Timer? = nil
    var notificationManager: NotificationManager?
    var startDate: Date? = nil
    ///Expired time interval (used for pause)
    var remainingTime: TimeInterval? = nil
    
    private var state: StartStopState = .stopped
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup countdown view
        countdownView.timeTotal = timeTotal
        countdownView.timeRemaining = timeTotal
        countdownView.delegate = self
    }
    
    ///Calculate remaining time
    ///from current date to finish date calculated via startDate and interval
    func calculateRemaining(startDate: Date, interval: TimeInterval) -> TimeInterval {
        let currentDate = Date()
        let finishDate = startDate.addingTimeInterval(interval)
        return finishDate.timeIntervalSince1970 - currentDate.timeIntervalSince1970
    }
    
    ///MARK: - Timer handlers
    
    //start timer and create reminder with interval from current date
    func startCountdown(withTimeInterval interval: TimeInterval) {
        startDate = Date()
        let destinationDate = startDate!.addingTimeInterval(interval)
        notificationManager?.removeAllReminders()
        notificationManager?.createReminder(date: destinationDate, title: "Pomodorro", body: "It's time to take a ☕️")
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        timer?.fire()
        state = .running
    }
    
    func pauseCountdown() {
        notificationManager?.removeAllReminders()
        timer?.invalidate()
        timer = nil
        remainingTime = calculateRemaining(startDate: startDate!, interval: timeTotal)
        state = .paused
    }
    
    func resumeCountdown() {
        startCountdown(withTimeInterval: remainingTime ?? timeTotal)
    }
    
    //stop timer
    func resetCountdown() {
        notificationManager?.removeAllReminders()
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        state = .stopped
        remainingTime = nil
        
        //update countdown view
        countdownView.timeRemaining = countdownView.timeTotal
    }
    
    ///Timer fire function
    @objc func updateTimer() {
        switch state {
        case .running:
            let timeRemaining = calculateRemaining(startDate: startDate!, interval: remainingTime ?? timeTotal)
            
            if timeRemaining < 0 {
                resetCountdown()
                return
            }
            
            countdownView.timeRemaining = timeRemaining
            countdownView.timeTotal = timeTotal
        default:
            return
        }
    }
    
    ///Update timeTotal from date picker
    @IBAction func unwindToThisView(sender: UIStoryboardSegue) {
        guard let sourceViewController = sender.source as? DurationViewController else {
            return
        }
        
        resetCountdown()
        timeTotal = sourceViewController.datePicker.countDownDuration
        countdownView.timeRemaining = timeTotal
        countdownView.timeTotal = timeTotal
    }

}

extension ViewController: CountdownViewDelegate {
    func countdownViewTapped() {
        switch state {
        case .stopped:
            startCountdown(withTimeInterval: timeTotal)
        case .paused:
            resumeCountdown()
        case .running:
            pauseCountdown()
        }
    }
    
    func countdownViewCancelled(_: CountdownView) {
        resetCountdown()
    }
}

