import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterProtocol {
    var delegateAlert: UIViewController?
    
    //var delegateAlert: AlertPresenterProtocol = AlertPresenter()
    
    func requestGameOverBtn(model: AlertModel){}
    
    var delegate: QuestionFactoryDelegate?
    
    // MARK: - Lifecycle
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    
    
    @IBOutlet weak var nButton: UIButton!
    
    @IBOutlet weak var yButton: UIButton!
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol? = QuestionFactory()
    private var currentQuestion: QuizQuestion?

    private var alertPresenter: AlertPresenterProtocol? = AlertPresenter()
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter?.delegateAlert = self
        questionFactory?.delegate = self
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
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
        
    @IBAction func yesButton(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        currentQuestion.correctAnswer ? showAnswerResult(isCorrect: true) : showAnswerResult(isCorrect: false)
    }
    
    @IBAction func noButton(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        currentQuestion.correctAnswer ? showAnswerResult(isCorrect: false) : showAnswerResult(isCorrect: true)
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
        
        alertPresenter?.requestGameOverBtn(model: alertModel)
        
        /*
        let alert = UIAlertController(title: result.title,
                                      message: result.text,
                                      preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet
        
        // создаём для него кнопки с действиями
        let action = UIAlertAction(title: "Сыграть еще раз!", style: .default, handler: ) { [weak self] _ in
            guard let self = self else {return}
            self.currentQuestionIndex = 0
            
            //заново показываем первый вопрос
            self.questionFactory?.requestNextQuestion()
        }
        correctAnswers = 0
        alert.addAction(action)
        // показываем всплывающее окно
        self.present(alert, animated: true, completion: nil)
         */
        correctAnswers = 0
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
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
            let text = correctAnswers == questionsAmount ? "Поздравляем, Вы ответили на 10 из 10!" : "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
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
}
