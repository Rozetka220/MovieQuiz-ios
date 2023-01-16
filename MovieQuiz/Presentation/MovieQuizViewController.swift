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
    
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    //private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenterProtocol? = AlertPresenter()
    private var serviceStatictic: StatisticService = StatisticServiceImplementation()

    private var correctAnswers: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter?.alertDelegate = self
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.requestNextQuestion()
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
        presenter.viewController = self
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func presentGameOverAlert(model: AlertModel, identifier: String){}
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        presenter.didRecieveNextQuestion(question: question)
//        guard let question = question else {
//            return
//        }
//        currentQuestion = question
//        let viewModel = presenter.convert(model: question)
//        DispatchQueue.main.async { [weak self] in
//            self?.show(quiz: viewModel)
//        }
    }

    @IBAction func yesBtnPressed(_ sender: Any) {
        //presenter.currentQuestion = currentQuestion
        presenter.yesBtnPressed()
    }
    
    @IBAction func noBtnPressed(_ sender: Any) {
        //presenter.currentQuestion = currentQuestion
        presenter.noBtnPressed()
    }
    
    func show(quiz step: QuizStepViewModel) {
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
                self.presenter.resetQuestuinIndex()
                self.questionFactory?.requestNextQuestion()
            }
        )
        
        alertPresenter?.presentGameOverAlert(model: alertModel, identifier: "gameOverAlertId")
        
        correctAnswers = 0
    }
    
    func showAnswerResult(isCorrect: Bool) {
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
        if presenter.isLastQuestion() {
            serviceStatictic.store(correct: correctAnswers, total: presenter.questionsAmount)
            let text = """
            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
            Количество сыгранных квизов: \(serviceStatictic.gamesCount)
            Рекорд: \(serviceStatictic.bestGame.correct)/\(presenter.questionsAmount) (\(serviceStatictic.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", serviceStatictic.totalAccuracy))%
            """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
            
        } else {
            presenter.switchToNextQuestion()
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
            
            self.presenter.resetQuestuinIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.presentGameOverAlert(model: model, identifier: "netErrorAlertId")
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

