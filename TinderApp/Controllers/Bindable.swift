//
//  Bindable.swift
//  TinderApp
//
//  Created by Aleksey Kosov on 23.12.2022.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }

    var observer: ((T?) -> Void)?

    func bind(observer: @escaping (T?) -> Void) {
        self.observer = observer
    }
}
