//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 21.12.2022.
//

import Foundation
import UIKit

protocol AlertPresenterProtocol {
    //func convertToAlertModel(model: QuizResultsViewModel) -> AlertModel
    var alertDelegate: UIViewController? {get set}
    func viewGameOverAlert(model: AlertModel)
}
