
import UIKit

class RecentTableViewCell: UITableViewCell {

    //MARK: - IBOutlets

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var lastMessageLbl: UILabel!
    @IBOutlet weak var unreadMessageBackgroundView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var unreadMessageCountLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        unreadMessageBackgroundView.layer.cornerRadius = unreadMessageBackgroundView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func generateCell(recentChat: RecentChat) {
        nameLbl.text = recentChat.receiverName
        lastMessageLbl.text = recentChat.lastMessage
        lastMessageLbl.adjustsFontSizeToFitWidth = true

        if recentChat.unreadCounter != 0 {
            self.unreadMessageCountLbl.text = "\(recentChat.unreadCounter)"
            self.unreadMessageCountLbl.isHidden = false
            self.unreadMessageBackgroundView.isHidden = false
        } else {
            self.unreadMessageCountLbl.isHidden = true
            self.unreadMessageBackgroundView.isHidden = true
        }

        setAvatar(avatarLink: recentChat.avatarLink)
        dateLbl.text = timeElapsed(recentChat.date)
        dateLbl.adjustsFontSizeToFitWidth = true

    }

    private func setAvatar(avatarLink : String) {
        FileStorage.donwloadImage(imageUrl: avatarLink) { (avatarImage) in
            if avatarImage != nil {
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        }
    }

    func timeElapsed(_ date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        print("seconds since last message", seconds)

        var dateText = ""

        if seconds < 60 {
            dateText = "just now"
        } else if seconds < 60 * 60 {
            let minutes = Int(seconds / 60)
            let minText = minutes > 1 ? "mins" : "min"
            dateText = "\(minutes) \(minText) "
        } else if seconds < 24 * 60 * 60 {
            let hours = Int(seconds / (60 * 60))
            let hourText = hours > 1 ? "hours" : "hour"
        } else {
            dateText = date.longDate()
        }
        return dateText

    }

  
}
