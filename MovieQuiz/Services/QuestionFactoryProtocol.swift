//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 10.12.2022.
//

import Foundation

protocol QuestionFactoryProtocol : QuestionFactoryDelegate {
    func requestNextQuestion()
}
