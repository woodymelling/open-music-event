import Validated

extension Validated {
    init(
        run: () throws -> Value,
        mappingError: (Swift.Error) -> Error
    ) {
        do {
            self = try .valid(run())
        } catch {
            self = .error(mappingError(error))
        }
    }
}

extension Validated where Error == Swift.Error {
    init(run: () throws -> Value) {
        do {
            self = try .valid(run())
        } catch {
            self = .error(error)
        }
    }
}


extension Validated {
    func mapErrors<NewError>(_ transform: (Error) -> NewError) -> Validated<Value, NewError> {
        switch self {
        case .valid(let value): .valid(value)
        case .invalid(let errors): .invalid(errors.map(transform))
        }
    }
}

typealias AnyValidated<T> = Validated<T, Swift.Error>

extension Array {
    /// Transforms an array of `Validated` elements into a single `Validated` containing an array of values.
    ///
    /// This function processes an array where each element is a `Validated` type. If all elements are `.valid`,
    /// it returns a `.valid` containing an array of the unwrapped values. If any elements are `.invalid`, it
    /// returns an `.invalid` containing a combined array of all the errors.
    ///
    /// - Returns: A `Validated` type containing an array of values if all elements are valid, or an array of errors if any elements are invalid.
    func sequence<Value, Error>() -> Validated<[Value], Error> where Element == Validated<Value, Error> {
        var values = [Value]()
        var errors = [Error]()

        for element in self {
            switch element {
            case .valid(let value):
                values.append(value)
            case .invalid(let errorArray):
                errors.append(contentsOf: errorArray)
            }
        }

        if errors.isEmpty {
            return .valid(values)
        } else {
            return .invalid(NonEmptyArray(errors)!)
        }
    }
}

extension Dictionary {
    /// Transforms a dictionary of `Validated` elements into a single `Validated` containing a dictionary of values.
    ///
    /// This function processes a dictionary where each value is a `Validated` type. If all values are `.valid`,
    /// it returns a `.valid` containing a dictionary of the unwrapped values. If any values are `.invalid`, it
    /// returns an `.invalid` containing a combined array of all the errors.
    ///
    /// - Returns: A `Validated` type containing a dictionary of values if all elements are valid, or an array of errors if any elements are invalid.
    func sequence<NewValue, Error>() -> Validated<[Key: NewValue], Error> where Value == Validated<NewValue, Error> {
        var values = [Key: NewValue]()
        var errors = [Error]()

        for (key, element) in self {
            switch element {
            case .valid(let value):
                values[key] = value
            case .invalid(let errorArray):
                errors.append(contentsOf: errorArray)
            }
        }

        if errors.isEmpty {
            return .valid(values)
        } else {
            return .invalid(NonEmptyArray(errors)!)
        }
    }
}
