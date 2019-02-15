import Foundation
import UserNotifications

class NotificationManager {
    
    init() {
        let center = UNUserNotificationCenter.current()
        // Request permission to display alerts and play sounds.
        center.requestAuthorization(options: [.alert, .sound])
        { (granted, error) in
            
        }
    }
    
    //create reminders
    public func createReminder(date: Date, title: String, body: String) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            // Do not schedule notifications if not authorized.
            guard settings.authorizationStatus == .authorized else {return}
            
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
            
            let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            content.categoryIdentifier = "TIMER_EXPIRED"
            content.sound = UNNotificationSound.default
            
            let newNotificationIdentifier = UUID().uuidString
            let request = UNNotificationRequest(identifier: newNotificationIdentifier, content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request) {(error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                    return
                }
            }
        }
    }
    
    //delete all current reminders
    public func removeAllReminders() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
}
