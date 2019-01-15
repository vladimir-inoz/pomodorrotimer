import UIKit
import UserNotifications

enum StartStopState {
    case stopped
    case running
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
    
    private var state: StartStopState = .stopped
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //adding gesture recognizer to countdown view
        //standard 0.5s is enough
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTapOnCountodwnView))
        countdownView.addGestureRecognizer(longTapGestureRecognizer)
        //tap recognizer to play/pause
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnCountdownView))
        countdownView.addGestureRecognizer(tapGestureRecognizer)
        
        //setup countdown view
        countdownView.timeTotal = timeTotal
        countdownView.timeRemaining = timeTotal
    }
    
    ///MARK: - Gesture recognizers handlers
    
    let rate: CGFloat = 0.00666
    var addRate: CGFloat = 0.00666
    
    @objc func longTapOnCountodwnView(_ gestureRecognizer: UIGestureRecognizer) {
        //long tap - cancel countdown
        if gestureRecognizer.state == .began {
            countdownView.fillRate = 0.0
            addRate = rate
            let _ = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) {
                timer in
                self.countdownView.fillRate = self.countdownView.fillRate + self.addRate
                
                //max fill, invalidating
                if self.countdownView.fillRate >= 1.0 {
                    timer.invalidate()
                    self.countdownView.fillRate = 0.0
                    self.resetCountdown()
                }
                
                //min fill, invalidating
                if self.countdownView.fillRate <= 0.0 {
                    timer.invalidate()
                }
            }
        }
        
        if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            addRate = -rate
        }
    }
    
    @objc func tapOnCountdownView(_ gestureRecognizer: UIGestureRecognizer) {
    }
    
    //start timer
    func startCountdown() {
        startDate = Date()
        let destinationDate = startDate!.addingTimeInterval(timeTotal)
        notificationManager?.removeAllReminders()
        notificationManager?.createReminder(date: destinationDate, title: "Pomodorro", body: "It's time to take a ☕️")
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        timer?.fire()
        state = .running
    }
    
    //stop timer
    func resetCountdown() {
        notificationManager?.removeAllReminders()
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        state = .stopped
        
        //update countdown view
        countdownView.timeRemaining = countdownView.timeTotal
    }
    
    @IBAction func startStopToggle() {
        switch state {
        case .stopped:
            startCountdown()
        case .running:
            resetCountdown()
        }
    }
    
    ///Calculate remaining time from starting date and total time
    func calculateRemaining(startDate: Date, interval: TimeInterval) -> TimeInterval {
        let currentDate = Date()
        let finishDate = startDate.addingTimeInterval(interval)
        return finishDate.timeIntervalSince1970 - currentDate.timeIntervalSince1970
    }
    
    ///Timer fire function
    @objc func updateTimer() {
        switch state {
        case .running:
            let timeRemaining = calculateRemaining(startDate: startDate!, interval: timeTotal)
            
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

