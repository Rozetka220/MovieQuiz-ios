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
    
    private var alertPresenter: AlertPresenterProtocol? = AlertPresenter()
    private var serviceStatictic: StatisticService = StatisticServiceImplementation()

    
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
    }

    @IBAction func yesBtnPressed(_ sender: Any) {
        presenter.yesBtnPressed()
    }
    
    @IBAction func noBtnPressed(_ sender: Any) {
        presenter.noBtnPressed()
    }
    
    func show(quiz step: QuizStepViewModel) {
        // здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText, //maybe empty, ="Сыграть еще!"
            completion: { [weak self] _ in
                guard let self = self else {return}
                self.presenter.restartGame()
                self.questionFactory?.requestNextQuestion()
            }
        )
        
        alertPresenter?.presentGameOverAlert(model: alertModel, identifier: "gameOverAlertId")
    }
    
    func showAnswerResult(isCorrect: Bool) {
        nButton.isEnabled=false
        yButton.isEnabled=false
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            presenter.didAnswer(isCorrectAnswer: isCorrect) //tut
            
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // запускаем задачу через 1 секунду
            guard let self = self else {return}
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.presenter.correctAnswers = self.presenter.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
            self.yButton.isEnabled=true
            self.nButton.isEnabled=true
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
            
            self.presenter.restartGame() //tut
            self.presenter.didAnswer(isCorrectAnswer: true)
            
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

