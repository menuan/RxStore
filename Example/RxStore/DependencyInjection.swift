import Foundation
import Dip
import RxStore

extension DependencyContainer {
    static var container: DependencyContainer?

    static func remove() {
        container?.reset()
        container = nil
    }

    static func configure() {
        DependencyContainer.container = DependencyContainer { container in
            container.register(.eagerSingleton) { getStore() }
        }
    }
}

final class Resolver {
    static func resolve<T>() -> T {
        guard let container = DependencyContainer.container else {
            fatalError("Container has not been initialised")
        }
        return try! container.resolve()
    }

    static func configure() {
        DependencyContainer.configure()
    }

    @discardableResult
    static func bootstrap() -> Bool {
        do {
            try DependencyContainer.container?.bootstrap()
            return true
        } catch {
            return false
        }
    }
}
