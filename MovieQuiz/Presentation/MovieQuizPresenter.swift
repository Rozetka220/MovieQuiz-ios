//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 16.01.2023.
//

import UIKit

final class MovieQuizPresenter{
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() ->Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestuinIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex+=1
    }
    
}
