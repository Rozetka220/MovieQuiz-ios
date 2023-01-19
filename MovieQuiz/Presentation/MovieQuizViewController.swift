import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    var delegate: QuestionFactoryDelegate?
    
    // MARK: - Lifecycle
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak private var nButton: UIButton!
    
    @IBOutlet weak private var yButton: UIButton!
    
    private var presenter: MovieQuizPresenter!
    
    private var alertPresenter: AlertPresenterProtocol? = AlertPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertPresenter?.alertDelegate = self
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    @IBAction private func yesBtnPressed(_ sender: Any) {
        presenter.yesBtnPressed()
    }
    
    @IBAction private func noBtnPressed(_ sender: Any) {
        presenter.noBtnPressed()
    }
    
    func show(quiz step: QuizStepViewModel) {
        // здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    func show(quiz rezult: AlertModel) {
        alertPresenter?.presentGameOverAlert(model: rezult, identifier: "gameOverAlertId")
    }
    
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
            self.presenter.restartGame()
            self.presenter.didAnswer(isCorrectAnswer: true)
        }
        
        alertPresenter?.presentGameOverAlert(model: model, identifier: "netErrorAlertId")
    }
    
    func hideLoadingIndicator(){
        activityIndicator.isHidden = true
    }
    
    func setButtonDisable(isDisable: Bool){
        if (isDisable){
            nButton.isEnabled=true
            yButton.isEnabled=true
        } else {
            nButton.isEnabled=false
            yButton.isEnabled=false
        }
    }
}

