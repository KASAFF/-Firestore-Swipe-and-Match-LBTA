//
//  SettingController.swift
//  TinderApp
//
//  Created by Aleksey Kosov on 24.12.2022.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage

protocol SettingsControllerDelegate: AnyObject {
    func didSaveSettings()
}

class CustomImagePickerController: UIImagePickerController {
    var imageButton: UIButton?
}

class SettingsController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var delegate: SettingsControllerDelegate?

    // instance properties
    lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))

    let imagePicker = CustomImagePickerController()

    @objc func handleSelectPhoto(button: UIButton) {
        print("Select photo with button:", button)
        imagePicker.delegate = self
        imagePicker.imageButton = button
        DispatchQueue.main.async {
            self.present(self.imagePicker, animated: true)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        // how do i set the image on my button when i select a photo?
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)

        let fileName = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(fileName)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else { return }

        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image..."
        hud.show(in: view)
        ref.putData(uploadData, metadata: nil) { _, err in
            if let err = err {
                hud.dismiss()
                print("Failed to upload image to storage", err)
                return
            }

            print("Finished uploading image")
            ref.downloadURL { url, err in
                hud.dismiss()
                if let err = err {
                    print("Failed to retrieve download URL:", err)
                    return
                }
                print("Finished getting download url:", url?.absoluteString ?? "")
                if imageButton == self.image1Button {
                    self.user?.imageUrl1 = url?.absoluteString
                } else if imageButton == self.image2Button {
                    self.user?.imageUrl2 = url?.absoluteString
                } else {
                    self.user?.imageUrl3 = url?.absoluteString
                }
            }

        }
    }

    func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItems()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive

        fetchCurrentUser()

    }

    var user: User?

    fileprivate func fetchCurrentUser() {
        Firestore.firestore().fetchCurrentUser { (user, err) in
            if let err = err {
                print("Failed to fetch user:", err)
                return
            }
            self.user = user
            self.loadUserPhotos()
            self.tableView.reloadData()
        }
    }

    func loadUserPhotos() {
        if let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { image, _, _, _, _, _ in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if let imageUrl = user?.imageUrl2, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { image, _, _, _, _, _ in
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if let imageUrl = user?.imageUrl3, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { image, _, _, _, _, _ in
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }

    lazy var header: UITableViewHeaderFooterView = {
        let header = UITableViewHeaderFooterView()
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true

        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding

        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()

    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            let yPos = (self.bounds.size.height - self.font.lineHeight) / 2 - 5
            let newRect = CGRect(x: rect.origin.x + 16, y: yPos, width: rect.size.width, height: rect.size.height)
            super.drawText(in: newRect)
        }
    }


    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        }
        let headerLabel = HeaderLabel()
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Profession"
        case 3:
            headerLabel.text = "Age"
        case 4:
            headerLabel.text = "Bio"
        default:
            headerLabel.text = "Seeking Age Range"
        }
        headerLabel.font = .boldSystemFont(ofSize: 16)
        return headerLabel
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        } else {
            return 40
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1 // if section 0 return 0
    }



    @objc fileprivate func handleMinAgeChange(slider: UISlider) {
        // i want to update the minLabel in my AgeRangeCell

        let indexPath = IndexPath(row: 0, section: 5)
       guard let ageRangeCell = tableView.cellForRow(at: indexPath) as? AgeRangeCell else { return }
        if slider.value >= ageRangeCell.maxSlider.value {
            ageRangeCell.maxSlider.value = slider.value
            ageRangeCell.maxLabel.text = "Max: \(Int((slider.value)))"
            self.user?.maxSeekingAge = Int(slider.value)
        }
        ageRangeCell.minLabel.text = "Min: \(Int((slider.value)))"
        self.user?.minSeekingAge = Int(slider.value)
    }
    @objc fileprivate func handleMaxAgeChange(slider: UISlider) {
        let indexPath = IndexPath(row: 0, section: 5)
        guard let ageRangeCell = tableView.cellForRow(at: indexPath) as? AgeRangeCell else { return }
        let minSliderValue = ageRangeCell.minSlider.value
        if slider.value <= minSliderValue {
            ageRangeCell.maxSlider.value = minSliderValue

        }
        ageRangeCell.maxLabel.text = "Max: \(Int((slider.value)))"
        self.user?.maxSeekingAge = Int(slider.value)
    }

    static let defaultMinSeekingAge = 18
    static let defaultMaxSeekingAge = 50
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // age range cell
        if indexPath.section == 5 {
            let ageRangeCell = AgeRangeCell(style: .default, reuseIdentifier: nil)
            ageRangeCell.minSlider.addTarget(self, action: #selector(handleMinAgeChange), for: .valueChanged)
            ageRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxAgeChange), for: .valueChanged)
            // we need to set up the labels on our cell here
            let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge
            let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge
            ageRangeCell.minLabel.text = "Min: \(minAge)"
            ageRangeCell.minSlider.value = Float(minAge)
            ageRangeCell.maxLabel.text = "Max: \(maxAge)"
            ageRangeCell.maxSlider.value = Float(maxAge)

            return ageRangeCell
        }

        let cell = SettingsCell(style: .default, reuseIdentifier: nil)

        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Enter Name"
            cell.textField.text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
        case 2:
            cell.textField.placeholder = "Enter Profession"
            cell.textField.text = user?.profession
            cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingChanged)
        case 3:
            cell.textField.placeholder = "Enter Age"
            cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)
            if let age = user?.age {
                cell.textField.text = String(age)
            }
        default:
            cell.textField.placeholder = "Enter Bio"
        }

        return cell
    }

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
//            cell.textView.becomeFirstResponder()
//    }

    @objc fileprivate func handleNameChange(textField: UITextField) {
        textField.becomeFirstResponder()
        self.user?.name = textField.text
    }
    @objc fileprivate func handleProfessionChange(textField: UITextField) {
        textField.becomeFirstResponder()
        self.user?.profession = textField.text
    }
    @objc fileprivate func handleAgeChange(textField: UITextField) {
        textField.becomeFirstResponder()
        self.user?.age = Int(textField.text ?? "")
    }

    fileprivate func setupNavigationItems() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.leftBarButtonItems = [UIBarButtonItem(
            title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))]
        navigationItem.rightBarButtonItems = [UIBarButtonItem(
            title: "Save", style: .plain, target: self, action: #selector(handleSave)),
        UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))]
    }

    @objc fileprivate func handleLogout() {
        try? Auth.auth().signOut()
        dismiss(animated: true) {

        }
    }

    @objc fileprivate func handleSave() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var docData: [String: Any] = [
            "uid": uid,
            "fullName": user?.name ?? "",
            "imageUrl1": user?.imageUrl1 ?? "",
            "age": user?.age ?? -1,
            "profession": user?.profession ?? "",
            "minSeekingAge": user?.minSeekingAge ?? -1,
            "maxSeekingAge": user?.maxSeekingAge ?? -1
        ]

        if user?.imageUrl2 != nil {
            docData["imageUrl2"] = user!.imageUrl2
        }
        if user?.imageUrl3 != nil {
            docData["imageUrl3"] = user!.imageUrl3
        }

        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving settings"
        hud.show(in: view)
        Firestore.firestore().collection("users").document(uid).setData(docData) { err in
            hud.dismiss()
            if let err = err {
                print("Failed to save user settings:", err)
                return
            }
            print("Finished saving user info")
            self.dismiss(animated: true) {
                self.delegate?.didSaveSettings()
                // i want to refetch my cards inside of homeController somehow
            }
        }
    }

    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }

}
