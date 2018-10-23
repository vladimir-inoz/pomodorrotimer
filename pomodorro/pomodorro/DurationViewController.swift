import UIKit

class DurationViewController: UIViewController {
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBAction func close() {
        dismiss(animated: true)
    }
}
