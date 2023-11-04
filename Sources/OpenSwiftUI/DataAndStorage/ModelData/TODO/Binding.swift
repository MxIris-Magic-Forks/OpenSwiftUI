@frozen
@propertyWrapper
public struct Binding<Value> {
    public var transaction: Transaction
    var location: AnyLocation<Value>
    private var _value: Value

    init(value: Value, location: AnyLocation<Value>, transaction: Transaction = Transaction()) {
        self.transaction = transaction
        self.location = location
        self._value = value
    }

    public static func constant(_ value: Value) -> Binding<Value> {
        let location = ConstantLocation(value: value)
        let box = LocationBox(location: location)
        return Binding(value: value, location: box)
    }

    public var wrappedValue: Value {
        get {
            readValue()
        }
        nonmutating set {
            location.set(newValue, transaction: transaction)
        }
    }

    public var projectedValue: Binding<Value> { self }

    @_alwaysEmitIntoClient
    public init(projectedValue: Binding<Value>) {
        self = projectedValue
    }
}


extension Binding {
    private func readValue() -> Value {
        if GraphHost.isUpdating {
            location.wasRead = true
            return _value
        } else {
            return location.get()
        }
    }
}