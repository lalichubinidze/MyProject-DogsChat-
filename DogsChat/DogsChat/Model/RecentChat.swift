

import Foundation
import UIKit
import Firebase

class RecentChat {
    var objectId = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var receiverId = ""
    var receiverName = ""
    var date = Date()
    var memberIds = [""]
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""

    var avatar:
    UIImage?

    var dictionary: NSDictionary {
        return NSDictionary(objects: [self.objectId,
                                      self.chatRoomId,
                                      self.senderId,
                                      self.senderName,
                                      self.receiverId,
                                      self.receiverName,
                                      self.date,
                                      self.memberIds,
                                      self.lastMessage,
                                      self.unreadCounter,
                                      self.avatarLink
        ],
                            forKeys: [ kOBJECTID as NSCopying,
                                       kCHATROOMID as NSCopying,
                                       kSENDERId as NSCopying,
                                       kSENDERNAME as NSCopying,
                                       kRECEIVERID as NSCopying,
                                       kRECEIVERNAME as NSCopying,
                                       kDATE as NSCopying,
                                       kMEMBERIDS as NSCopying,
                                       kLASTMESSAGE as NSCopying,
                                       kUNREADCOUNTER as NSCopying,
                                       kAVTAARLINK as NSCopying

                              ])
    }
    init() {}

    init(_ recentDocument: Dictionary<String, Any>) {
        objectId = recentDocument[kOBJECTID] as? String ?? ""
        chatRoomId = recentDocument[kCHATROOMID] as? String ?? ""
        senderId = recentDocument[kSENDERId] as? String ?? ""
        senderName = recentDocument[kSENDERNAME] as? String ?? ""
        receiverId = recentDocument[kRECEIVERID] as? String ?? ""
        receiverName = recentDocument[kRECEIVERNAME] as? String ?? ""
        date = (recentDocument[kDATE] as? Timestamp)?.dateValue() ?? Date()
        memberIds = recentDocument[kMEMBERIDS] as? [String] ?? [""]
        lastMessage = recentDocument[kLASTMESSAGE] as? String ?? ""
        unreadCounter = recentDocument[kUNREADCOUNTER] as? Int ?? 0
        avatarLink = recentDocument[kAVTAARLINK] as? String ?? ""

    }
    //MARK: - Saving
    func saveToFireStore() {
        FirebaseReference(.Resent).document(self.objectId).setData(self.dictionary as! [String: Any])

    }

    func deleteRecent() {
        FirebaseReference(.Resent).document(self.objectId).delete()
    }
}

