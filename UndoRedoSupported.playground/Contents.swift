import Foundation

@propertyDelegate
struct UndoRedoSupported<Value> {
    private let initialValue: Value
    private var stateBuffer: [Value]
    private var redoBuffer: [Value] = []

    var value: Value {
        get { self.stateBuffer.last ?? self.initialValue}
        set {
            self.redoBuffer = []
            self.stateBuffer.append(newValue)
        }
    }

    init(initialValue: Value) {
        self.initialValue = initialValue
        self.stateBuffer = [initialValue]
    }

    mutating func undo() {
        if let value = self.stateBuffer.popLast() {
            self.redoBuffer.append(value)
        }
    }

    mutating func redo() {
        if let value = self.redoBuffer.popLast() {
            self.stateBuffer.append(value)
        }
    }
}

struct Bar<T> {
    @UndoRedoSupported var foo: T
}

var bar = Bar(foo: 1)
bar.foo = 2
bar.foo = 3

bar.$foo.undo() // 2
bar.$foo.undo() // 1
bar.$foo.redo() // 2
bar.$foo.redo() // 3

bar.$foo.undo() // 2
bar.$foo

bar.foo = 100
bar.$foo.redo() // noop
bar.$foo
