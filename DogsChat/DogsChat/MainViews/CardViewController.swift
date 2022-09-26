
import UIKit
import Shuffle_iOS
import Firebase
import ProgressHUD

final class CardViewController: UIViewController {

    //MARK: -IBOutlets
    @IBOutlet weak var emptyDataView: EmptyDataView!
    
    //MARK: - Vars
    private let cardStack = SwipeCardStack()
    private var initialCardModels: [UserCardModel] = []
    private var secondCardModel: [UserCardModel] = []
    private var userObjects: [FUser] = []

    var lastDocumentSnapshot: DocumentSnapshot?
    var isInitialLoad = true
    var showReserve = false
    var numberOfCardaAdded = 0
    var initialLoadNumber = 30

    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        showEmptyDataView(loading: true)
        emptyDataView.delegate = self
        createUsers()

//        let user = FUser.currentUser()!
//        user.likedIdArray = []
//        user.saveUserLocally()
//        user.saveUserToFireStore()

        donwloadInitialUsers()


    }
    private func showEmptyDataView(loading: Bool) {

        emptyDataView.isHidden = false
        emptyDataView.reloadBtn.isEnabled = true

        let imageName = loading ? "searchingBackground" : "seenAllBackground"
        let title = loading ? "Searching for users..." : "You have swiped all users"
        let subTitle = loading ? "Please wait" : "Please check back later"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.view.bringSubviewToFront(self.emptyDataView)
        }

        emptyDataView.imageView.image = UIImage(named: imageName)
        emptyDataView.titleLbl.text = title
        emptyDataView.subtitleLbl.text = subTitle
        emptyDataView.reloadBtn.isHidden = loading
    }
    private func hideEmptyDataView() {
        emptyDataView.isHidden = true
    }

    private func resetLoadCount() {
        isInitialLoad = true
        showReserve = false
        lastDocumentSnapshot = nil
        numberOfCardaAdded = 0
    }

    //MARK: - Layout cards
    private func layoutCardStackView() {

        hideEmptyDataView()
        cardStack.delegate = self
        cardStack.dataSource = self

        view.addSubview(cardStack)
        cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.safeAreaLayoutGuide.leftAnchor,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         right: view.safeAreaLayoutGuide.rightAnchor)
    }

    //MARK: - DonwloadUsers

    private func donwloadInitialUsers() {
        ProgressHUD.show()

        FirebaseListener.shared.donwloadUsersFromFirebase(isInitialLoad: isInitialLoad, limit: initialLoadNumber, lastDoocumentSnapshot: lastDocumentSnapshot) { (allUsers, snapshot) in

            if allUsers.count == 0 {
                ProgressHUD.dismiss()
            }
            self.lastDocumentSnapshot = snapshot
            self.isInitialLoad = false
            self.initialCardModels = []

            self.userObjects = allUsers

            for user in allUsers {
                user.getUserAvatarFromFirestore { (didset) in
                    let cardModel = UserCardModel(id: user.objectId, name: user.username, age: user.dateOfBirth.interval(ofComponnent: .year, fromDate: Date()), breedOfDog: user.breed, image: user.avatar)

                    self.initialCardModels.append(cardModel)
                    self.numberOfCardaAdded += 1
                    if self.numberOfCardaAdded == allUsers.count {
                        print("reload")
                        DispatchQueue.main.async {
                            ProgressHUD.dismiss()
                            self.layoutCardStackView()
                        } 
                    }
                }
            }
            print("initial \(allUsers.count) received")
            self.donwloadMoreUsersInBackground()
        }
    }

    private func donwloadMoreUsersInBackground() {
        FirebaseListener.shared.donwloadUsersFromFirebase(isInitialLoad: isInitialLoad, limit: 1000, lastDoocumentSnapshot: lastDocumentSnapshot) { (allUsers, snapshot) in

            self.lastDocumentSnapshot = snapshot
            self.secondCardModel = []
            self.userObjects += allUsers

            for user in allUsers {
                user.getUserAvatarFromFirestore { (didset) in
                    let cardModel = UserCardModel(id: user.objectId,
                                                  name: user.username,
                                                  age: user.dateOfBirth.interval(ofComponnent: .year, fromDate: Date()),
                                                  breedOfDog: user.breed, image: user.avatar)
                    self.secondCardModel.append(cardModel)
                }
            }
        }
    }

    //MARK: - Navigation

    private func showUserProfileFor(userId: String) {

        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileTableView") as! UserProfileTableViewController
        profileView.userObject = getUserWithId(userId: userId)
        profileView.delegate = self
        self.present(profileView, animated: true, completion: nil)
    }

    private func showMatchView(userId: String) {
        let matchView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MatchViewController") as! MatchViewController

        matchView.user = getUserWithId(userId: userId)
        matchView.delegate = self
        self.present(matchView, animated: true, completion: nil)
    }

    //MARK: - Helpers
    private func getUserWithId(userId: String) -> FUser? {
        for user in userObjects {
            if user.objectId == userId {
                return user
            }
        }
        return nil
    }

    private func checkForLikesWith(userId: String) {

        if !didLikeUserWith(userId: userId) {
            saveLikeToUser(userId: userId)
        }

        FirebaseListener.shared.checkIfUserLikedUs(userId: userId) { (didLike) in

            if didLike {
                FirebaseListener.shared.saveMatch(userId: userId)
                self.showMatchView(userId: userId)
            }
        }
    }

    private func goToChat(user: FUser) {
        let chatRoomId = startChat(user1: FUser.currentUser()!, user2: user)
        let chatview = ChatViewController(chatId: chatRoomId, recipientId: user.objectId, recipientName: user.username)
        chatview.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatview, animated: true)
    }
}

extension CardViewController: SwipeCardStackDelegate, SwipeCardStackDataSource {

    //MARK: - DataSource
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = UserCard()
        card.footerHeight = 80
        card.swipeDirections = [.left, .right]

        for direction in card.swipeDirections {
            card.setOverlay(UserCardOverlay(direction: direction), forDirection: direction)
        }
        card.configure(withModel: showReserve ? secondCardModel[index] :  initialCardModels[index])
        return card
    }

    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return showReserve ? secondCardModel.count : initialCardModels.count
    }

    //MARK: - Delegates
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("finished with cards, show reserve is ", showReserve)
        initialCardModels = []
        if showReserve {
            secondCardModel = []
        }
        showReserve = true
        layoutCardStackView()
        if secondCardModel.isEmpty {
            showEmptyDataView(loading: false)
        }
    }

    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        if direction == .right {
            let user = getUserWithId(userId: showReserve ? secondCardModel[index].id : initialCardModels[index].id)
            checkForLikesWith(userId: user!.objectId)
        }
    }

    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        showUserProfileFor(userId: showReserve ? secondCardModel[index].id : initialCardModels[index].id)

    }
}


//MARK: - Extensions

extension CardViewController: UserProfileTableViewControllerDelegate {
    func didLikeUser() {
        cardStack.swipe(.right, animated: true)
    }

    func didDislikeUser() {
        cardStack.swipe(.left, animated: true)
    }
}

extension CardViewController : MatchViewControllerDelegate {
    func didClickSendMessage(to user: FUser) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.goToChat(user: user)
        }
    }

    func didClickKeepSwiping() {
    }
}

extension CardViewController: EmptyDataViewDelegate {

    func didClickReloadButton() {
        resetLoadCount()
        donwloadInitialUsers()
        emptyDataView.reloadBtn.isEnabled = false
    }
}

