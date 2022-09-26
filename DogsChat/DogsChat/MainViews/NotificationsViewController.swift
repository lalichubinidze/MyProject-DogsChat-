

import UIKit
import ProgressHUD

final class NotificationsViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!

    //MARK: -  Vars
    let allLikes:[LikeObject] = []
    var allUsers: [FUser] = []


    //MARK: - viewLifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        donwloadLikes()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    //MARK: - DonwloadLikes
    private func donwloadLikes() {
        ProgressHUD.show()

        FirebaseListener.shared.donwloadUserLikes { (allUserIds) in
            if allUserIds.count > 0 {
                FirebaseListener.shared.donwloadUsersFromFirebase(withIds: allUserIds) { (allUsers) in
                    ProgressHUD.dismiss()

                    self.allUsers = allUsers
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }

            } else {
                ProgressHUD.dismiss()
            }
        }
    }
    private func showUserProfileFor(user: FUser) {

        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileTableView") as! UserProfileTableViewController
        profileView.userObject = user
        self.navigationController?.pushViewController(profileView, animated: true)
    }
}
extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LikeTableViewCell
        cell.setupCell(user: allUsers[indexPath.row])
       return cell
    }
}

extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showUserProfileFor(user: allUsers[indexPath.row])
    }

}
