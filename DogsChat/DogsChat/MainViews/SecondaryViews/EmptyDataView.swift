

import UIKit

protocol EmptyDataViewDelegate {
    func didClickReloadButton()
}

class EmptyDataView: UIView {

    //MARK: -  IBOutlets

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var reloadBtn: UIButton!

    //MARK: - Vars
    var delegate: EmptyDataViewDelegate?


    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }


    private func commonInit() {

        Bundle.main.loadNibNamed("EmptyDataView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    //MARK: - IBActions
    @IBAction func reloadBtnPressed(_ sender: Any) {
        delegate?.didClickReloadButton()
    }
    
}
