//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 16.01.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate{
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    
    private let statisticService: StatisticService!
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() ->Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
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
        
        
        //tututut
        currentQuestion.correctAnswer == givenAnswer ? showAnswerResult(isCorrect: true) : showAnswerResult(isCorrect: false)
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
    
    
    //Так выглядила моя функция до внедрения makeResultMessage и кажется она вполне себе работает, зачем мне внедрять makeResult?
    //    func showNextQuestionOrResults() {
    //        if self.isLastQuestion() {
    //            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
    //            let text = """
    //            Ваш результат: \(correctAnswers)/\(self.questionsAmount)
    //            Количество сыгранных квизов: \(statisticService.gamesCount)
    //            Рекорд: \(statisticService.bestGame.correct)/\(self.questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
    //            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
    //            """
    //            let viewModel = QuizResultsViewModel(
    //                title: "Этот раунд окончен!",
    //                text: text,
    //                buttonText: "Сыграть ещё раз")
    //            viewController?.show(quiz: viewModel)
    //
    //        } else {
    //            self.switchToNextQuestion()
    //            questionFactory?.requestNextQuestion()
    //        }
    //    }
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            //statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            let text = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)"
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
    
    func didAnswer(isCorrectAnswer: Bool) {
        if (isCorrectAnswer) { correctAnswers += 1 }
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    
    // Я вроде как вполне себе могй спокойно обойтись без этого метода, не совсем понимаю, зачем его использовать?
    func makeResultMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    func showAnswerResult(isCorrect: Bool) {
        viewController?.nButton.isEnabled=false
        viewController?.yButton.isEnabled=false
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // запускаем задачу через 1 секунду
            guard let self = self else {return}
            self.viewController?.highlightImageBorderClear()
            //self.presenter.correctAnswers = self.presenter.correctAnswers
            //self.presenter.questionFactory = self.questionFactory
            self.showNextQuestionOrResults()
            self.viewController?.yButton.isEnabled=true
            self.viewController?.nButton.isEnabled=true
        }
    }
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
}
