//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 17.12.2022.
//
import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    weak var alertDelegate: UIViewController?
    
    func presentGameOverAlert(model: AlertModel, identifier: String) {
        guard let alertDelegate = alertDelegate else {return}
        
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet
        
        // создаём для него кнопки с действиями
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: model.completion)
        
        alert.addAction(action)
        alert.view.accessibilityIdentifier = identifier
        // показываем всплывающее окно
        alertDelegate.present(alert, animated: true, completion: nil)
    }
}
    

