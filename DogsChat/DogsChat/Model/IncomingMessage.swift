
import Foundation
import MessageKit
import Firebase

class IncomingMessage {

    var messageCollectionView: MessagesViewController

    init(collectionView_: MessagesViewController) {
        messageCollectionView = collectionView_
    }

    func createMessage(messageDictionary: [String: Any]) -> MKMessagge? {

        let message = Message(dictionary: messageDictionary)
        let mkMessage = MKMessagge(message: message)

        if message.type == kPICTURE {
            print("we have a picture message")

            let photoItem = PhotoMessage(path: message.mediaURL)
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)

            FileStorage.donwloadImage(imageUrl: messageDictionary[kMEDIAURL] as? String ?? "") { (image) in

                mkMessage.photoItem?.image = image
                DispatchQueue.main.async {
                    self.messageCollectionView.messagesCollectionView.reloadData()
                }
            }
        }

        return mkMessage
    }


}
