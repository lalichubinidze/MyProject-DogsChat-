
import UIKit

class LikeTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!

    // MARK: - ViewLifeCycles
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(user: FUser) {
        nameLbl.text = user.username
        setAvatar(avatarLink: user.avatarLink)
    }

    private func setAvatar(avatarLink: String) {
        FileStorage.donwloadImage(imageUrl: avatarLink) { (avatarImage) in
            self.avatarImageView.image = avatarImage?.circleMasked
        }
    }
}
