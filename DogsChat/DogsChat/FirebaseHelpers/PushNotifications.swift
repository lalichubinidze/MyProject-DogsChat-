
import Foundation

class PushNotificationService {

    static let shared = PushNotificationService()

    private init() { }


    func sendPushNotificationTo(userIds: [String], body: String) {

        FirebaseListener.shared.donwloadUsersFromFirebase(withIds: userIds) { (users) in

            for user in users {
                if let pushId = user.pushId {
                    self.sendMessageToUser(to: pushId, title: FUser.currentUser()!.username, body: body)
                }
            }
        }
    }


    private func sendMessageToUser(to token: String, title: String, body: String) {

        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!

        let paramString : [String : Any] = ["to" : token,
                                            "notification" : [
                                                "title" : title,
                                                "body" : body,
                                                "budge" : "1",
                                                "sound" : "default"
                                            ]
        ]



        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=/", forHTTPHeaderField: "Authorization")


        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in


        }

        task.resume()
    }

}
