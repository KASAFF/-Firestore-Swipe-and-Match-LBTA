//
//  Firebase+Utils.swift
//  TinderApp
//
//  Created by Aleksey Kosov on 24.12.2022.
//

import Firebase

extension Firestore {
    func fetchCurrentUser(completion: @escaping (User?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                completion(nil, err)
                return
            }

            // fetched our user here
            guard let dictionary = snapshot?.data() else {
                let error = NSError(domain: "com.AK.SwipeApp", code: 500, userInfo: [NSLocalizedDescriptionKey: "No user found in Firestore"])
                completion(nil, error)
                return
            }
            let user = User(dictionary: dictionary)
            completion(user, nil)
        }
    }
}
