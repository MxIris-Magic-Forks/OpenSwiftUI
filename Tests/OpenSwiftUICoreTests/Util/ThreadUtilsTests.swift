//
//  ThreadUtilsTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct ThreadUtilsTests {
    static let defaultValue: Int = 1
    static let box = ThreadSpecific(defaultValue)
    
    @Test
    func value() async throws {
        let box = ThreadUtilsTests.box
        #expect(box.value == ThreadUtilsTests.defaultValue)
        try await withThrowingTaskGroup(of: Int.self) { group in
            group.addTask {
                await Task.detached {
                    box.value = 3
                    #expect(box.value == 3)
                    return box.value
                }.value
            }
            group.addTask {
                await Task.detached {
                    box.value = 4
                    #expect(box.value == 4)
                    return box.value
                }.value
            }
            let result = try await group.reduce(0, +)
            #expect(result == 7)
            await MainActor.run {
                #expect(box.value == ThreadUtilsTests.defaultValue)
            }
        }
    }
}
