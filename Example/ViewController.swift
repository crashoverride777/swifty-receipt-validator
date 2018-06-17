//
//  ViewController.swift
//  SwiftyReceiptValidatorExample
//
//  Created by Dominik on 17/06/2018.
//  Copyright © 2018 Dominik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var validateButton: UIButton!
    
    @IBOutlet private weak var textField: UITextField! {
        didSet {
            textField.text = productIdentifier
        }
    }
    
    // MARK: - Properties
    
    private let productIdentifier = "com.dominikringler.twinplanes.removeads"
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    }
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}

// MARK: - Callbacks

private extension ViewController {
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    @IBAction func validateButtonPressed(_ sender: UIButton) {
        guard let productId = textField.text else { return }
      
        let receiptValidator = SwiftyReceiptValidator()
        receiptValidator.start(withProductId: productId, sharedSecret: nil) { result in
            switch result {
            case .success(let data):
                print("Validation successfull with data \(data)")
            case .failure(let code, let error):
                print("Validation failed, code: \(code), error \(error)")
            }
        }
    }
}
