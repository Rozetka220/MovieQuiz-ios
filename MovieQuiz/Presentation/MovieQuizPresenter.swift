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
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    let serviceStatictic: StatisticService = StatisticServiceImplementation()
    
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
    
    
    func yesBtnPressed() {
        didAnswer(isYes: true)
    }
    
    func noBtnPressed() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {return}
        
        //на сколько необходимо создавать отельную переменную givenAnswer? Я как понимаю это просто для читаемости кода
        let givenAnswer = isYes
        
        currentQuestion.correctAnswer == givenAnswer ? viewController?.showAnswerResult(isCorrect: true) : viewController?.showAnswerResult(isCorrect: false)
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            serviceStatictic.store(correct: correctAnswers, total: self.questionsAmount)
            let text = """
            Ваш результат: \(correctAnswers)/\(self.questionsAmount)
            Количество сыгранных квизов: \(serviceStatictic.gamesCount)
            Рекорд: \(serviceStatictic.bestGame.correct)/\(self.questionsAmount) (\(serviceStatictic.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", serviceStatictic.totalAccuracy))%
            """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
            
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
