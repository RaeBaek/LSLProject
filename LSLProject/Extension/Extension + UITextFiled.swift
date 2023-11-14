//
//  Extension + TextFiled.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit

extension UITextField {
    static func customTextField(placeholder: String) -> UITextField {
        let view = UITextField()
        view.placeholder = placeholder
        view.textColor = .black
        view.font = .systemFont(ofSize: 15, weight: .regular)
        view.backgroundColor = .white
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        view.leftViewMode = .always
        view.layer.cornerRadius = 16.5
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.borderWidth = 1
        view.keyboardType = .emailAddress
        return view
    }
}
