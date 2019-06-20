import Foundation

import RxCocoa
import RxSwift
import RxRelay

public protocol StoreType: class {
    /**
     Initialise the Store with a `StoreReducer`
     */
    init(reducer: @escaping (Dictionary<Int, SubstateType>, ActionType) -> Dictionary<Int, SubstateType>)

    var state: Driver<Dictionary<Int, SubstateType>> { get }

    var lastDispatchedAction: Driver<ActionType?> { get }

    var lastStateAndAction: Driver<(Dictionary<Int, SubstateType>, ActionType?)> { get }

    var middlewares: Array<MiddlewareType> { get }

    func dispatch(action: ActionType)

    func register(middleware: MiddlewareType)

    func register(middlewares: Array<MiddlewareType>)
}

public protocol SubstateType {
    init()
}

public protocol ActionType {}

public protocol MiddlewareType: class {
    func observe(store: StoreType)
}

public final class Store: StoreType {
    public typealias StoreState = Dictionary<Int, SubstateType>
    public typealias Reducer = (StoreState, ActionType) -> StoreState

    public enum Action: ActionType {
        case add(substate: SubstateType, forKey: Int)
        case remove(key: Int)
        case reset
    }

    let reducer: Reducer

    public var state: Driver<StoreState> { return _state.asDriver() }
    public var lastDispatchedAction: Driver<ActionType?> { return _lastDispatchedAction.asDriver() }

    public var middlewares: Array<MiddlewareType> { return _middlewares }

    public var lastStateAndAction: Driver<(StoreState, ActionType?)> {
        return Driver.zip(state, lastDispatchedAction) { state, lastAction -> (StoreState, ActionType?) in
            (state, lastAction)
        }
    }

    private var _state: BehaviorRelay<StoreState>
    private var _lastDispatchedAction: BehaviorRelay<ActionType?> = BehaviorRelay(value: nil)
    private var _middlewares: Array<MiddlewareType> = []

    public required init(reducer: @escaping Reducer) {
        self.reducer = reducer
        _state = BehaviorRelay(value: [:])
    }

    public func dispatch(action: ActionType) {
        switch action {
        case let storeAction as Store.Action:
            _state.accept(Store.reduce(state: _state.value, action: storeAction))
        default:
            _state.accept(reducer(_state.value, action))
        }
        _lastDispatchedAction.accept(action)
    }

    public func register(middleware: MiddlewareType) {
        middleware.observe(store: self)
        _middlewares.append(middleware)
    }

    public func register(middlewares: Array<MiddlewareType>) {
        middlewares.forEach { self.register(middleware: $0) }
    }

    public static func reduce(state: StoreState, action: Store.Action) -> StoreState {
        switch action {
        case .add(let substate, let key):
            var state = state
            state[key] = substate
            return state
        case .remove(let key):
            var state = state
            state.removeValue(forKey: key)
            return state
        case .reset:
            return [:]
        }
    }
}
