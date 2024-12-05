//
//  AdventOfCodeCLI.swift
//  Advent of Code CLI 2024
//
//  Created by Stephen H. Gerstacker on 2023-12-01.
//  SPDX-License-Identifier: MIT
//

import AdventOfCode
import ArgumentParser
import Foundation

// Add each new day implementation to this array:
let allChallenges: [any AdventDay] = [
    Day0(), Day1(), Day2(), Day3(), Day4(),
    Day5()
]

@main
struct AdventOfCode: AsyncParsableCommand {
    @Argument(help: "The day of the challenge. For December 1st, use '1'.")
    var day: Int?

    @Flag(help: "Benchmark the time taken by the solution")
    var benchmark: Bool = false
    
    @Flag(inversion: .prefixedNo, help: "Use sample data instead of the given input data")
    var sampleData: Bool = false

    /// The selected day, or the latest day if no selection is provided.
    var selectedChallenge: any AdventDay {
        get throws {
            if let day {
                if let challenge = allChallenges.first(where: { $0.day == day }) {
                    return challenge
                } else {
                    throw ValidationError("No solution found for day \(day)")
                }
            } else {
                return latestChallenge
            }
        }
    }

    /// The latest challenge in `allChallenges`.
    var latestChallenge: any AdventDay {
        allChallenges.max(by: { $0.day < $1.day })!
    }

    func run(part: () async throws -> Any, named: String) async -> Duration {
        var result: Result<Any, Error> = .success("<unsolved>")
        let timing = await ContinuousClock().measure {
            do {
                result = .success(try await part())
            } catch {
                result = .failure(error)
            }
        }
        switch result {
        case .success(let success):
            print("\(named): \(success)")
        case .failure(let failure):
            print("\(named): Failed with error: \(failure)")
        }
        return timing
    }

    func run() async throws {
        var challenge = try selectedChallenge
        print("Executing Advent of Code challenge \(challenge.day)...")

        try challenge.prepare(useSample: sampleData)
        let timing1 = await run(part: challenge.part1, named: "Part 1")
        let timing2 = await run(part: challenge.part2, named: "Part 2")

        if benchmark {
            print("Part 1 took \(timing1), part 2 took \(timing2).")
            #if DEBUG
                print("Looks like you're benchmarking debug code. Try swift run -c release")
            #endif
        }
    }
}
