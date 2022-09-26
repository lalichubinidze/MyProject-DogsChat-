
import Foundation
import Firebase

class TypingListener {

    static let shared = TypingListener()

    var typingListener: ListenerRegistration!

    private init() { }


    func createTypingObserver(chatRoomId: String, completion: @escaping (_ isTyping: Bool) -> Void) {

        typingListener = FirebaseReference(.Typing).document(chatRoomId).addSnapshotListener({ (snapshot, error) in

            guard let snapshot = snapshot else { return }

            if snapshot.exists {

                for data in snapshot.data()! {

                    if data.key != FUser.currentId() {
                        completion(data.value as! Bool)
                    }
                }
            } else {
                completion(false)
                FirebaseReference(.Typing).document(chatRoomId).setData([FUser.currentId() : false])
            }
        })

    }

    class func saveTypingCounter(typing: Bool, chatRoomId: String) {

        FirebaseReference(.Typing).document(chatRoomId).updateData([FUser.currentId() : typing])
    }

}
