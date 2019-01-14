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
    var timeTotal = 50.0
    var timer: Timer? = nil
    var notificationManager: NotificationManager?
    var startDate: Date? = nil
    
    private var state: StartStopState = .stopped
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup countdown view
        countdownView.timeTotal = timeTotal
        countdownView.timeRemaining = timeTotal
    }
    
    //start timer
    func startCountdown() {
        startDate = Date()
        let destinationDate = startDate!.addingTimeInterval(timeTotal)
        notificationManager?.removeAllReminders()
        notificationManager?.createReminder(date: destinationDate, title: "Pomodorro", body: "It's time to take a ☕️")
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
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
    
    ///Calculate remaining time
    func calculateRemaining(startDate: Date) -> TimeInterval {
        let currentDate = Date()
        let finishDate = startDate.addingTimeInterval(timeTotal)
        return finishDate.timeIntervalSince1970 - currentDate.timeIntervalSince1970
    }
    
    ///Timer fire function
    @objc func updateTimer() {
        switch state {
        case .running:
            let timeRemaining = calculateRemaining(startDate: startDate!)
            
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

