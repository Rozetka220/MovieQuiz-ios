//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 16.01.2023.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: AlertModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func setButtonDisable(isDisable: Bool)
    
    func highlightImageBorderClear()
}

final class MovieQuizPresenter: QuestionFactoryDelegate{
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    
    private let statisticService: StatisticService
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() ->Bool {
        if(currentQuestionIndex == questionsAmount - 1){
            saveStatistic()
            return currentQuestionIndex == questionsAmount - 1
        }
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
    
    private func didAnswer(isYes givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {return}
        currentQuestion.correctAnswer == givenAnswer ? showAnswerResult(isCorrect: givenAnswer) : showAnswerResult(isCorrect: givenAnswer)
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
    
    private func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message:  makeResultMessage(), // result.text,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] _ in
                    guard let self = self else {return}
                    self.restartGame()
                })
            viewController?.show(quiz: alertModel)
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
    
    func saveStatistic(){
        statisticService.store(correct: correctAnswers, total: questionsAmount)
    }
    func makeResultMessage() -> String {
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
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.setButtonDisable(isDisable: false)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // запускаем задачу через 1 секунду
            guard let self = self else {return}
            self.viewController?.highlightImageBorderClear()
            self.showNextQuestionOrResults()
            self.viewController?.setButtonDisable(isDisable: true)
        }
    }
}
