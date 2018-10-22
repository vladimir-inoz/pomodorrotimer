import UIKit
import Splitflap

class ViewController: UIViewController {
    
    var splitflapView: Splitflap!
    var time = 25.0 * 60.0
    var timer = Timer()
    
    fileprivate func stringFromTimeInterval(interval: TimeInterval) -> String {
        let intervalInt = Int(interval)
        let minutes = intervalInt / 60
        let seconds = intervalInt % 60
        return NSString(format: "%0.2d:%0.2d",minutes,seconds) as String
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitflapView = Splitflap(frame: CGRect(x: 0, y: 0, width: 370, height: 53))
        splitflapView.datasource = self
        
        self.view.addSubview(splitflapView)
        splitflapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            splitflapView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            //splitflapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splitflapView.heightAnchor.constraint(equalToConstant: 100.0),
            splitflapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            splitflapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        splitflapView.setText("12345", animated: false)
        
        runTimer()
        
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        self.time = self.time - 1.0
        let timeString = self.stringFromTimeInterval(interval: self.time)
        splitflapView.setText(timeString, animated: false)
    }

}


extension ViewController: SplitflapDataSource {
    // Defines the number of flaps that will be used to display the text
    func numberOfFlapsInSplitflap(_ splitflap: Splitflap) -> Int {
        return 5
    }
    
    func tokensInSplitflap(_ splitflap: Splitflap) -> [String] {
        return "0123456789:".map {String($0)}
    }
}

