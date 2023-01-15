//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 10.12.2022.
//

import Foundation
///Ответсвенность протокола - получить  вопрос из хранилища вопросов
protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData()
}
