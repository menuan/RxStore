import UIKit
import RxSwift
import RxStore
import RxCocoa

class ViewController: UIViewController {

    weak var store: Store?

    var disposable: Disposable?

    @IBOutlet weak var countLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        store = Resolver.resolve()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disposable = store?.state
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
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.countLabel.text = $0
            }, onCompleted: nil, onDisposed: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disposable?.dispose()
        disposable = nil
    }

    @IBAction func onPlusTouchUp(_ sender: Any) {
        store?.dispatch(action: ExampleAction.increment)
    }

    @IBAction func onMinusTouchUp(_ sender: Any) {
        store?.dispatch(action: ExampleAction.decrement)
    }
}

