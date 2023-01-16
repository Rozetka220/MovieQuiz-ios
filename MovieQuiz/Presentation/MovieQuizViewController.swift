import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterProtocol {
    
    var alertDelegate: UIViewController?
    
    var delegate: QuestionFactoryDelegate?
    
    // MARK: - Lifecycle
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var nButton: UIButton!
    
    @IBOutlet weak var yButton: UIButton!
    
    private var presenter: MovieQuizPresenter!
    //private var questionFactory: QuestionFactoryProtocol?
    
    private var alertPresenter: AlertPresenterProtocol? = AlertPresenter()
    //private var serviceStatictic: StatisticService = StatisticServiceImplementation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter?.alertDelegate = self
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    func presentGameOverAlert(model: AlertModel, identifier: String){}
    
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
            message:  presenter.makeResultMessage(), // result.text,
            buttonText: result.buttonText, //maybe empty, ="Сыграть еще!"
            completion: { [weak self] _ in
                guard let self = self else {return}
                self.presenter.restartGame()
                //self.questionFactory?.requestNextQuestion()
            }
        )
        
        alertPresenter?.presentGameOverAlert(model: alertModel, identifier: "gameOverAlertId")
    }
    
    //    func showAnswerResult(isCorrect: Bool) {
    //        nButton.isEnabled=false
    //        yButton.isEnabled=false
    //        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
    //        imageView.layer.borderWidth = 8
    //
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // запускаем задачу через 1 секунду
    //            guard let self = self else {return}
    //            self.imageView.layer.borderColor = UIColor.clear.cgColor
    //            self.presenter.correctAnswers = self.presenter.correctAnswers
    //            //self.presenter.questionFactory = self.questionFactory
    //            self.presenter.showNextQuestionOrResults()
    //            self.yButton.isEnabled=true
    //            self.nButton.isEnabled=true
    //        }
    //    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrectAnswer == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            presenter.didAnswer(isCorrectAnswer: isCorrectAnswer) //tut
            
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
    }
    
    func highlightImageBorderClear(){
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    //Блок работы с сетью
    func showLoadingIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func showNetworkError(message: String){
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame() //tut
            self.presenter.didAnswer(isCorrectAnswer: true)
            
            //self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.presentGameOverAlert(model: model, identifier: "netErrorAlertId")
    }
    
    func hideLoadingIndicator(){
        activityIndicator.isHidden = true
    }
}

