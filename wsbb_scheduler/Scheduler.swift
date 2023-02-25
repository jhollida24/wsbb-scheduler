//
//  Scheduler.swift
//  wsbb_scheduler
//
//  Created by Jeff Holliday on 2/25/23.
//

import ArgumentParser
import Foundation

@main
struct Scheduler: ParsableCommand {
//    @Flag(help: "Include a counter with each repetition.")
//    var includeCounter = false

//    @Option(name: .shortAndLong, help: "The number of times to repeat 'phrase'.")
//    var count: Int? = nil

    @Argument(help: "The filepath to the CSV file.")
    var csvFilepath: String

    mutating func run() throws {
        print("hello world")
    }
}
