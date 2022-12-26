//
//  ChatLogController.swift
//  TinderApp
//
//  Created by Aleksey Kosov on 27.12.2022.
//

import LBTATools

struct Message {
    let text: String
    let isFromCurrentLoggedUser: Bool
}

class MessageCell: LBTAListCell<Message> {

    let textView: UITextView = {
        let textview = UITextView()
        textview.backgroundColor = .clear
        textview.font = .systemFont(ofSize: 20)
        textview.isScrollEnabled = false
        textview.isEditable = false
        return textview
    }()

    let bubbleContrainer = UIView(backgroundColor: #colorLiteral(red: 0.9008976221, green: 0.9008976221, blue: 0.9008977413, alpha: 1))

    override var item: Message! {
        didSet {
            textView.text = item.text


            if item.isFromCurrentLoggedUser {
                // right edge
                anchoredConstraints.trailing?.isActive = true
                anchoredConstraints.leading?.isActive = false
                bubbleContrainer.backgroundColor = #colorLiteral(red: 0.08145835251, green: 0.7658771873, blue: 1, alpha: 1)
                textView.textColor = .white

            } else {
                // left edge
                anchoredConstraints.trailing?.isActive = false
                anchoredConstraints.leading?.isActive = true
                bubbleContrainer.backgroundColor = #colorLiteral(red: 0.9008976221, green: 0.9008976221, blue: 0.9008977413, alpha: 1)
                textView.textColor = .black
            }
        }
    }

    var anchoredConstraints: AnchoredConstraints!

    override func setupViews() {
        super.setupViews()
        addSubview(bubbleContrainer)
        bubbleContrainer.layer.cornerRadius = 12

        anchoredConstraints = bubbleContrainer.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        anchoredConstraints.leading?.constant = 20
        anchoredConstraints.trailing?.isActive = false
        anchoredConstraints.trailing?.constant = -20

        // example
//        anchoredConstraints.leading?.isActive = false
//        anchoredConstraints.trailing?.isActive = true

        bubbleContrainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        bubbleContrainer.addSubview(textView)
        textView.fillSuperview(padding: .init(top: 4, left: 12, bottom: 4, right: 12))

    }
}


class ChatLogController: LBTAListController<MessageCell, Message>, UICollectionViewDelegateFlowLayout {

    fileprivate lazy var customNavBar = MessagesNavBar(match: match)

    fileprivate let navBarHeight: CGFloat = 120

    fileprivate let match: Match

    init(match: Match) {
        self.match = match
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.alwaysBounceVertical = true

        items = [
            .init(text: "For this lesson, let's talk all about auto sizing message cells and how to shift alignment from left to right. Doing the alignment correctly within one cell makes it very easy to toggle things based on a chat message's properties later on. We'll also look at some bug fixes at the end.", isFromCurrentLoggedUser: true),
            .init(text: "Hello bud", isFromCurrentLoggedUser: false),
            .init(text: "Let's work on building out the chat log controller UI that shows the messages for each user. I'll go through this relatively quickly as I don't want to spend too much time on UI. Please let me know if you find the LBTATools methods convenient or hard to learn. Enjoy.", isFromCurrentLoggedUser: true)
        ]

        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: navBarHeight))
        collectionView.contentInset.top = navBarHeight
        collectionView.scrollIndicatorInsets.top = navBarHeight
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        let statusBarCover = UIView(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }

    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // estimated sizing
        let estimatedSizeCell = MessageCell(frame: .init(x: 0, y: 0, width: view.frame.width, height: 1000))

        estimatedSizeCell.item = self.items[indexPath.item]
        estimatedSizeCell.layoutIfNeeded()

        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(.init(width: view.frame.width, height: 1000))

        return .init(width: view.frame.width, height: estimatedSize.height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
