//
//  RegistrationViewModel.swift
//  TinderApp
//
//  Created by Aleksey Kosov on 23.12.2022.
//

import UIKit
import Firebase

class RegistrationViewModel {
    
    var binadbleIsRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    
    var fullName: String? { didSet { checkFormValidity() } }
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    
    
    func performRegistration(completion: @escaping (Error?) -> ()) {
        
        // Auth part / Store Part
        
        register(email: email, password: password, completion: completion)
        
    }
    
    fileprivate func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false
        && email?.isEmpty == false
        && password?.isEmpty == false
        bindableIsFormValid.value = isFormValid
        
    }
    
    fileprivate func register(email : String?, password: String?, completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { res, err in
            if let err = err {
                completion(err)
                return
            }
            print("Succesfully registered user:", res?.user.uid ?? "")
            self.saveImageToFirebase(completion)
        }
        
    }
    
    fileprivate func saveImageToFirebase(_ completion: @escaping (Error?) -> ()) {
        //only upload images to firebase store once you are authorized
        
        if Auth.auth().currentUser != nil {
            
            let filename = UUID().uuidString
            let ref = Storage.storage().reference(withPath: "/images/\(filename)")
            let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
            ref.putData(imageData, metadata: nil) { (_, err) in
                
                if let err = err {
                    completion(err)
                    return // bail
                }
                print("Finished uploading image to storage")
                ref.downloadURL { url, err in
                    if let err = err {
                        print(err)
                        completion(err)
                        return
                    }
                    
                    self.binadbleIsRegistering.value = false
                    
                    let imageUrl = url?.absoluteString ?? ""
                    print("Download url of our image is: ", imageUrl)
                    //store the dowlonad url into firestore next lesson
                    
                    self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
                }
            }
        }
    }
    
    fileprivate func saveInfoToFirestore(imageUrl: String,completion: @escaping (Error?)->()) {
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData = ["fullName":fullName ?? "", "uid": uid, "imageUrl1": imageUrl]
        Firestore.firestore().collection("users").document(uid).setData(docData) { err in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }
    }
    
}
