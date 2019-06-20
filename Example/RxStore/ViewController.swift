import UIKit
import RxSwift
import RxStore
import RxCocoa

class ViewController: UIViewController {
    weak var store: Store?

    var disposeBag: DisposeBag?

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        store = Resolver.resolve()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let newDisposeBag = DisposeBag()
        store?.state
            .flatMap { states -> Driver<ExampleStateStruct> in
                for state in states {
                    guard let value = state.1 as? ExampleStateStruct else { continue }
                    return Driver<ExampleStateStruct>.just(value)
                }
                fatalError("You need to add `ExampleStateStruct` first")
            }
            .distinctUntilChanged()
            .map { state -> String in
                return "\(state.count)"
            }
            .asObservable()
            .bind(to: countLabel.rx.text)
            .disposed(by: newDisposeBag)

        plusButton.rx
            .tap
            .subscribe(onNext: { [weak self] in
                self?.store?.dispatch(action: ExampleAction.increment)
            })
            .disposed(by: newDisposeBag)

        minusButton.rx
            .tap
            .subscribe(onNext: { [weak self] in
                self?.store?.dispatch(action: ExampleAction.decrement)
            })
            .disposed(by: newDisposeBag)
        disposeBag = newDisposeBag
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disposeBag = nil
    }
}

