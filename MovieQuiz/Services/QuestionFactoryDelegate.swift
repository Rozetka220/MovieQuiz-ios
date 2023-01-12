//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 11.12.2022.
//

import Foundation
///Ответственность протокола делегата - интерфейс передачи вопроса в MovieQuizViewController
protocol QuestionFactoryDelegate : AnyObject {
    func didRecieveNextQuestion(question: QuizQuestion?)
}
