import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterProtocol {
    
    var alertDelegate: UIViewController?
    
    var delegate: QuestionFactoryDelegate?
    
    // MARK: - Lifecycle
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var nButton: UIButton!
    
    @IBOutlet weak var yButton: UIButton!
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenterProtocol? = AlertPresenter()
    private var serviceStatictic: StatisticService = StatisticServiceImplementation()
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter?.alertDelegate = self
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.requestNextQuestion()
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func presentGameOverAlert(model: AlertModel){}
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    @IBAction private func yesBtnPressed(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        currentQuestion.correctAnswer ? showAnswerResult(isCorrect: false) : showAnswerResult(isCorrect: true)
    }
    @IBAction private func noBtnPressed(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        currentQuestion.correctAnswer ? showAnswerResult(isCorrect: true) : showAnswerResult(isCorrect: false)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        // здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText, //maybe empty, ="Сыграть еще!"
            completion: { [weak self] _ in
                guard let self = self else {return}
                self.currentQuestionIndex = 0
                self.questionFactory?.requestNextQuestion()
            }
        )
        
        alertPresenter?.presentGameOverAlert(model: alertModel)
        
        correctAnswers = 0
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),                //UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        nButton.isEnabled=false
        yButton.isEnabled=false
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers+=1
            
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // запускаем задачу через 1 секунду
            guard let self = self else {return}
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
            self.yButton.isEnabled=true
            self.nButton.isEnabled=true
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            serviceStatictic.store(correct: correctAnswers, total: questionsAmount)
            let text = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(serviceStatictic.gamesCount)
            Рекорд: \(serviceStatictic.bestGame.correct)/\(questionsAmount) (\(serviceStatictic.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", serviceStatictic.totalAccuracy))%
            """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
            
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    //Блок работы с сетью
    private func showLoadingIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String){
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] _ in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.presentGameOverAlert(model: model)
    }
    private func hideLoadingIndicator(){
        activityIndicator.isHidden = true
    }
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
}

