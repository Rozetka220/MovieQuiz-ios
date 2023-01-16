//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 21.12.2022.
//
import UIKit

protocol AlertPresenterProtocol {
    //func convertToAlertModel(model: QuizResultsViewModel) -> AlertModel
    var alertDelegate: UIViewController? {get set}
    func presentGameOverAlert(model: AlertModel, identifier: String)
}
