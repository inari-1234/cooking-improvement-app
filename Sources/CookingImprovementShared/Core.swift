import Foundation

public enum CookingDomainError: Error, Equatable, Sendable {
    case emptyName
    case invalidScale
    case invalidRange
    case invalidTimerDuration
    case invalidStateTransition
}

public struct FixedPoint: Equatable, Hashable, Codable, Sendable, Comparable {
    public let mantissa: Int64
    public let scale: Int

    public init(mantissa: Int64, scale: Int) throws {
        guard scale >= 0 else { throw CookingDomainError.invalidScale }
        var m = mantissa
        var s = scale
        if m == 0 {
            self.mantissa = 0
            self.scale = 0
            return
        }
        while s > 0 && m % 10 == 0 {
            m /= 10
            s -= 1
        }
        self.mantissa = m
        self.scale = s
    }

    public static func < (lhs: FixedPoint, rhs: FixedPoint) -> Bool {
        if lhs == rhs { return false }
        let lNeg = lhs.mantissa < 0
        let rNeg = rhs.mantissa < 0
        if lNeg != rNeg { return lNeg }
        let lDigits = String(lhs.mantissa.magnitude)
        let rDigits = String(rhs.mantissa.magnitude)
        let lExp = lDigits.count - lhs.scale
        let rExp = rDigits.count - rhs.scale
        if lExp != rExp { return lNeg ? lExp > rExp : lExp < rExp }
        let fractionalDigits = max(lhs.scale, rhs.scale)
        let l = lDigits + String(repeating: "0", count: fractionalDigits - lhs.scale)
        let r = rDigits + String(repeating: "0", count: fractionalDigits - rhs.scale)
        if l.count != r.count { return lNeg ? l.count > r.count : l.count < r.count }
        return lNeg ? l > r : l < r
    }
}

public enum MeasurementValue: Equatable, Hashable, Codable, Sendable {
    case exact(FixedPoint, unit: String?)
    case approximate(FixedPoint, unit: String?)
    case range(FixedPoint, FixedPoint, unit: String?)
    case qualitative(String, unit: String?)
    case unknown(unit: String?)

    public func normalized() throws -> MeasurementValue {
        func unit(_ value: String?) -> String? {
            guard let v = value?.trimmingCharacters(in: .whitespacesAndNewlines), !v.isEmpty else { return nil }
            return v
        }
        switch self {
        case let .exact(v, u): return .exact(v, unit: unit(u))
        case let .approximate(v, u): return .approximate(v, unit: unit(u))
        case let .range(lower, upper, u):
            guard lower <= upper else { throw CookingDomainError.invalidRange }
            return .range(lower, upper, unit: unit(u))
        case let .qualitative(text, u):
            let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !t.isEmpty else { throw CookingDomainError.emptyName }
            return .qualitative(t, unit: unit(u))
        case let .unknown(u): return .unknown(unit: unit(u))
        }
    }
}

public struct IngredientDraft: Equatable, Codable, Sendable, Identifiable {
    public let id: UUID
    public var name: String
    public var amountText: String
    public init(id: UUID = UUID(), name: String, amountText: String = "") {
        self.id = id; self.name = name; self.amountText = amountText
    }
}

public struct StepDraft: Equatable, Codable, Sendable, Identifiable {
    public let id: UUID
    public var action: String
    public var note: String
    public var timerSeconds: Int?
    public init(id: UUID = UUID(), action: String, note: String = "", timerSeconds: Int? = nil) {
        self.id = id; self.action = action; self.note = note; self.timerSeconds = timerSeconds
    }
}

public enum CookingSessionStatus: String, Codable, Sendable, CaseIterable {
    case inProgress, completed, abandoned
}

public struct SessionStateMachine: Sendable {
    public init() {}
    public func finish(_ status: CookingSessionStatus) throws -> CookingSessionStatus {
        guard status == .inProgress else { throw CookingDomainError.invalidStateTransition }
        return .completed
    }
    public func abandon(_ status: CookingSessionStatus) throws -> CookingSessionStatus {
        guard status == .inProgress else { throw CookingDomainError.invalidStateTransition }
        return .abandoned
    }
}
