
import UIKit

protocol MatchViewControllerDelegate {
    func didClickSendMessage(to user: FUser)
    func didClickKeepSwiping()
}

class MatchViewController: UIViewController {

    //MARK: - IBOutlets

    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var heartView: UIImageView!
    @IBOutlet weak var nameAgeLbl: UILabel!
    @IBOutlet weak var breedLbl: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    //MARK: - Vars
    var user : FUser?
    var delegate : MatchViewControllerDelegate?

    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        if user != nil {
            presentUserData()
        }
    }
    //MARK: - IBActions
    @IBAction func sendMessageBtn(_ sender: Any) {
        delegate?.didClickSendMessage(to: user!)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func keepSwipingBtn(_ sender: Any) {
        delegate?.didClickKeepSwiping()
        self.dismiss(animated: true, completion: nil)
    }

    //MARK: -  Setup
    private func setupUI() {
        cardBackgroundView.layer.cornerRadius = 10
        heartView.layer.cornerRadius = 10
        heartView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardBackgroundView.applyShadow(radius: 8, opacity: 0.2, offset: CGSize(width: 0, height: 2))
    }

    private func presentUserData() {
        avatarImageView.image = user!.avatar?.circleMasked
        let nameAge = user!.username + ", \(user!.dateOfBirth.interval(ofComponnent: .year, fromDate: Date()))"
        let breed = user!.breed
        nameAgeLbl.text = nameAge
        breedLbl.text = breed
    }
}
