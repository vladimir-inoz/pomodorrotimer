import UIKit
import UserNotifications

enum StartStopState {
    case stopped
    case running
    case paused
}

class ViewController: UIViewController {
    
    @IBOutlet var countdownView: CountdownView!
    
    lazy var durationPickerView: DurationPickerView = {
        let picker = DurationPickerView(frame: CGRect(x: 0.0, y: view.bounds.height, width: view.bounds.width, height: 0.0))
        picker.delegate = self
        return picker
    }()
    
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
        
        //add duration picker as subview
        view.addSubview(durationPickerView)
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
    
    ///MARK: - manage picker view
    
    func showPickerView() {
        UIView.animate(withDuration: 0.4) {
            let height: CGFloat = 300.0
            self.durationPickerView.frame = CGRect(x: 0.0, y: self.view.bounds.height - height, width: self.view.bounds.width, height: height)
        }
    }
    
    func hidePickerView() {
        UIView.animate(withDuration: 0.4) {
            self.durationPickerView.frame = CGRect(x: 0.0, y: self.view.bounds.height, width: self.view.bounds.width, height: 0.0)
        }
    }
    
    @IBAction func openPicker() {
        showPickerView()
    }

}

extension ViewController: DurationPickerViewDelegate {
    ///When user selects duration with picker view we stop countdown and timeTotal
    func durationPickerView(_: DurationPickerView, didSelectDuration duration: TimeInterval) {
        resetCountdown()
        timeTotal = duration
        countdownView.timeTotal = timeTotal
        countdownView.timeRemaining = timeTotal
        
        hidePickerView()
    }
    
    func durationPickerViewCancelled(_: DurationPickerView) {
        hidePickerView()
    }
}

extension ViewController: CountdownViewDelegate {
    ///When user taps we start, pause and resume countdown
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
    
    ///User long tap resets countdown
    func countdownViewCancelled(_: CountdownView) {
        resetCountdown()
    }
}

