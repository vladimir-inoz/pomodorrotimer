import UIKit

protocol DurationPickerViewDelegate {
    ///User selected duration with "Done" button
    func durationPickerView(_ : DurationPickerView, didSelectDuration: TimeInterval)
    ///User cancelled selection
    func durationPickerViewCancelled(_ : DurationPickerView)
}

class DurationPickerView: UIView {
    
    private lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .countDownTimer
        return picker
    }()

    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .blackTranslucent
        toolbar.barTintColor = UIColor.blue
        toolbar.tintColor = UIColor.white
        return toolbar
    }()
    
    public var delegate: DurationPickerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func embedButtons(_ toolbar: UIToolbar) {
        func setupLabelBarButtonItem() -> UIBarButtonItem {
            let label = UILabel()
            label.text = "Set Alarm Time"
            label.textColor = .white
            return UIBarButtonItem(customView: label)
        }
        
        let todayButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolbar.setItems([todayButton, flexButton, setupLabelBarButtonItem(), flexButton, doneButton], animated: true)
    }
    
    private func setup() {
        backgroundColor = UIColor.white
        
        addSubview(toolbar)
        embedButtons(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        toolbar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        toolbar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        
        addSubview(timePicker)
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        timePicker.topAnchor.constraint(equalTo: toolbar.bottomAnchor).isActive = true
        timePicker.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        timePicker.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    }
    
    @objc func donePressed() {
        delegate?.durationPickerView(self, didSelectDuration: timePicker.countDownDuration)
    }
    
    @objc func cancelPressed() {
        delegate?.durationPickerViewCancelled(self)
    }
}
