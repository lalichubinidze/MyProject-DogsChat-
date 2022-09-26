
import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Like
    case Match
    case Resent
    case Messages
    case Typing
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    
    return Firestore.firestore().collection(collectionReference.rawValue)

}
