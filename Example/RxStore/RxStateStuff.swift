import Foundation
import RxStore
import RxSwift
import RxCocoa

enum ExampleState: Int {
    case one, two, three
}

struct ExampleStateStruct: Equatable {
    let id: UUID
    let count: Int
}

extension ExampleStateStruct: SubstateType {
    init() {
        id = UUID()
        count = 0
    }
}

let reducer: Store.Reducer = { (state, action) -> Store.StoreState in
    var state = state
    switch action {
    case let exampleAction as ExampleAction:
        if let substate = state[ExampleState.one.rawValue] as? ExampleStateStruct {
            switch exampleAction {
            case .increment:
                state[ExampleState.one.rawValue] = ExampleStateStruct(id: substate.id, count: substate.count + 1)
                break
            case .decrement:
                state[ExampleState.one.rawValue] = ExampleStateStruct(id: substate.id, count: substate.count - 1)
                break
            }
        }
    default: break
    }
    return state
}

class Logger: MiddlewareType {
    var disposeBag: DisposeBag = DisposeBag()

    func observe(store: StoreType) {
        store.lastStateAndAction
            .drive(onNext: { state, action in
                print("new action \(String(describing: action)) and state \(state)")
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}

func getStore() -> Store {
    let store = Store(reducer: reducer)
    store.register(middleware: Logger())
    store.dispatch(action: Store.Action.add(substate: ExampleStateStruct(id: UUID(), count: 0), forKey: ExampleState.one.rawValue))
    return store
}


enum ExampleAction: ActionType {
    case increment, decrement
}
