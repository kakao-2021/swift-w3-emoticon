//
//  MainViewController.swift
//  EmoticonApp
//
//  Created by bean Milky on 2021/01/18.
//

import UIKit

class MainViewController: UIViewController {

    private var mainImage: UIView!
    private var myTableView: UITableView!
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    private(set) var cart: CartType = Cart(cartKey: "EmoticonApp/Cart")
    private var emojiService: EmojiService = EmojiService()
    private var clickedItemId: UUID?
    private var cellHeight: CGFloat = CGFloat(100)
    private let numOfCell: CGFloat = 6.5
    private var cartObserver: Observable?

    init() {
        super.init(nibName: nil, bundle: nil)
        self.cartObserver = CartObserver(self)
        self.cartObserver?.addObserver(name: .pushToCart, selector: #selector(willPushToCart))
    }

    deinit {
        self.cartObserver?.removeObservers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.cartObserver = CartObserver(self)
        self.cartObserver?.addObserver(name: .pushToCart, selector: #selector(willPushToCart))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        setUI()
    }

    private func setUI() {
        setNavigationItem()
        setMainImage()
        setTableView()
    }
    private func setMainImage() {
        self.mainImage = Promotion(frame: CGRect(x: 0, y: self.topbarHeight, width: screenWidth-20, height: 230))
        self.view.addSubview(mainImage)
        self.mainImage.center.x = self.view.center.x
    }

    private func setTableView() {
        let positionY = self.topbarHeight+mainImage.frame.height+20
        self.myTableView = UITableView(frame: CGRect(x: 0, y: positionY, width: self.screenWidth, height: self.screenHeight-positionY))

        myTableView.alwaysBounceVertical = false
        myTableView.showsVerticalScrollIndicator = false
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.register(EmojiTableViewCell.self, forCellReuseIdentifier: EmojiTableViewCell.cellIdentifier)
        view.addSubview(self.myTableView)
        cellHeight = CGFloat((self.screenHeight-positionY)/numOfCell)
    }

    private func setNavigationItem() {
        let item = UIBarButtonItem(image: UIImage(systemName: "cart.fill"), style: .plain, target: self, action: #selector(goToHistory))
        self.navigationItem.setRightBarButton(item, animated: true)
    }

    private func clickAlertOK(id: UUID) {
        if let emoji = emojiService.findById(id: id) {
            cart.push(emoji: emoji)
        }
    }

    @objc private func goToHistory() {
        self.performSegue(withIdentifier: "goToHistory", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHistory" {
            if let destinationVC = segue.destination as? HistoryViewController {
                destinationVC.cart = cart
            }
        }
    }

}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

extension MainViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emojiService.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: EmojiTableViewCell = tableView.dequeueReusableCell(withIdentifier: EmojiTableViewCell.cellIdentifier, for: indexPath) as? EmojiTableViewCell {
            guard emojiService.data.count > indexPath.row else { return UITableViewCell() }
            let emoji: Emoji = emojiService.data[indexPath.row]
            cell.setProperty(emoji: emoji)
            cell.resize(width: screenWidth, height: cellHeight)
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
}

extension MainViewController {
    @objc func willPushToCart(_ notification: Notification) {
        
        let okHandler: (UIAlertAction) -> Void = { [weak self] _ in
            guard let strongSelf = self else { return }
            if let id = strongSelf.clickedItemId {
                strongSelf.clickAlertOK(id: id)
            }
        }
        
        let alert = UIAlertController(title: "알림", message: "구매하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: okHandler))
        alert.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        
        if let id = notification.object as? UUID {
            self.present(alert, animated: true, completion: nil)
            self.clickedItemId = id
        }

    }
}
