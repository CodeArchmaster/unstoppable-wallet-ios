import UIKit
import SnapKit

class BalanceEditCell: UITableViewCell {
    static let height: CGFloat = 80

    private let button = UIButton()

    var onTap: (() -> ())?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        button.setTitle("balance.add_coin".localized, for: .normal)
        button.setTitleColor(.appGray, for: .normal)
        button.setTitleColor(.appGray50, for: .highlighted)
        button.titleLabel?.font = .appSubhead1
        button.contentEdgeInsets = UIEdgeInsets(top: .margin4x, left: .margin8x, bottom: .margin4x, right: .margin8x)

        let image = UIImage(named: "Plus Icon")
        button.setImage(image?.tinted(with: .appGray), for: .normal)
        button.setImage(image?.tinted(with: .appGray50), for: .highlighted)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -.margin4x, bottom: 0, right: 0)

        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)

        contentView.addSubview(button)
        button.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc func didTap() {
        onTap?()
    }

}
