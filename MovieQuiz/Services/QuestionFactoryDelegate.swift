//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 11.12.2022.
//

import Foundation

protocol QuestionFactoryDelegate : AnyObject {
    var delegate: QuestionFactoryDelegate? { get set }
    func didRecieveNextQuestion(question: QuizQuestion?)
}
