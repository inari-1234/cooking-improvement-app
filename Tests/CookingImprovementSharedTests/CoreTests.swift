import Testing
@testable import CookingImprovementShared

@Test func fixedPointNormalizesTrailingZeroes() throws {
    #expect(try FixedPoint(mantissa: 150, scale: 2) == FixedPoint(mantissa: 15, scale: 1))
    #expect(try FixedPoint(mantissa: 0, scale: 9) == FixedPoint(mantissa: 0, scale: 0))
}

@Test func fixedPointComparisonAvoidsScaleOverflow() throws {
    let a = try FixedPoint(mantissa: 9_000_000_000_000_001, scale: 2)
    let b = try FixedPoint(mantissa: 90_000_000_000_000, scale: 1)
    #expect(a > b)
}

@Test func measurementRangeRejectsReverse() throws {
    let low = try FixedPoint(mantissa: 20, scale: 0)
    let high = try FixedPoint(mantissa: 10, scale: 0)
    #expect(throws: CookingDomainError.invalidRange) {
        _ = try MeasurementValue.range(low, high, unit: "℃").normalized()
    }
}

@Test func measurementNormalizesWhitespace() throws {
    let x = try MeasurementValue.qualitative("  きつね色  ", unit: " ").normalized()
    #expect(x == .qualitative("きつね色", unit: nil))
}

@Test func sessionStateMachineOnlyMovesFromInProgress() throws {
    let sm = SessionStateMachine()
    #expect(try sm.finish(.inProgress) == .completed)
    #expect(try sm.abandon(.inProgress) == .abandoned)
    #expect(throws: CookingDomainError.invalidStateTransition) { _ = try sm.finish(.completed) }
}
