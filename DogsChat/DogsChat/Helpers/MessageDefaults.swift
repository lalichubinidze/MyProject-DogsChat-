
import Foundation
import MessageKit
import UIKit

struct MKSender: SenderType, Equatable {
    var senderId: String
    var displayName: String

}

enum MessageDefaults {
    //Bubble colors
    static let bubbleColorOutgoing = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    static let bubbleColorIncoming = UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)
}
