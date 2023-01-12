//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 17.12.2022.
//

import Foundation
import UIKit

class AlertPresenter: AlertPresenterProtocol {
    internal weak var alertDelegate: UIViewController?
    
    func viewGameOverAlert(model: AlertModel) {
        guard let delegateAlert = alertDelegate else {return}
        
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet
        
        // создаём для него кнопки с действиями
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: model.completion)
        
        alert.addAction(action)
        // показываем всплывающее окно
        delegateAlert.present(alert, animated: true, completion: nil)
    }
}
    

