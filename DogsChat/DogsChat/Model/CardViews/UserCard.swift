
import Foundation
import Shuffle_iOS

class UserCard: SwipeCard {
    func configure(withModel model: UserCardModel) {
        content = UserCardContentView(withImage: model.image)
        footer = UserCardFooterView(withTitle: "\(model.name), \(model.age)", subTitle: model.breedOfDog)

    }
}
