//
//  Scheduler.swift
//  wsbb_scheduler
//
//  Created by Jeff Holliday on 2/25/23.
//

import ArgumentParser
import Foundation
import SwiftCSV

@main
struct Scheduler: ParsableCommand {
    static let year = "2023"
//    @Flag(help: "Include a counter with each repetition.")
//    var includeCounter = false

//    @Option(name: .shortAndLong, help: "The number of times to repeat 'phrase'.")
//    var count: Int? = nil
//
//    @Argument(help: "The filepath to the CSV file.")
//    var csvFilepath: String
    
    
    struct Division: Hashable, Decodable {
        let name: String
        let teamCount: Int
        let startDate: Date
        let endDate: Date
        let daysOfWeek: [Locale.Weekday]
        let canUsePeeWees: Bool
        
        init(name: String, teamCount: Int, startDate: String, endDate: String, daysOfWeek: [Locale.Weekday], canUsePeeWees: Bool) {
            self.name = name
            self.teamCount = teamCount
            self.startDate = divisionsDateFormatter.date(from: startDate + "/\(year)")!
            self.endDate = divisionsDateFormatter.date(from: endDate + "/\(year)")!
            self.daysOfWeek = daysOfWeek
            self.canUsePeeWees = canUsePeeWees
        }
        
        func shouldPractice(on date: Date) -> Bool {
            let calendar = Calendar.current
            let dayStart = calendar.startOfDay(for: date)
            let weekday = Locale.Weekday(weekdayOrdinal: calendar.component(.weekday, from: date))!
            return daysOfWeek.contains(weekday)
        }
        
        var practiceDates: [Date] {
            var practiceDates = [Date]()
            
            let calendar: Calendar = .current
            let oneDay = TimeInterval(24 * 60 * 60)
            
            var date = calendar.startOfDay(for: self.startDate)
            while (date < self.endDate.addingTimeInterval(oneDay)) {
                let weekdayOrdinal = calendar.component(.weekday, from: date)
                let weekday = Locale.Weekday(weekdayOrdinal: weekdayOrdinal)!
                if daysOfWeek.contains(weekday) {
                    practiceDates.append(date)
                }
                
                date.addTimeInterval(oneDay)
            }
            
            return practiceDates
        }
        
        var targetPracticeLengthMinutes: Int { 90 }
        var targetPracticeTimeInterval: TimeInterval { TimeInterval(targetPracticeLengthMinutes * 60) }
        
        var minimumPracticeLengthMinutes: Int { 60 }
        var minimumPracticeTimeInterval: TimeInterval { TimeInterval(minimumPracticeLengthMinutes * 60) }
        
        var targetSplitPracticeLengthMinutes: Int { 120 }
        var targetSplitPracticeTimeInterval: TimeInterval { TimeInterval(targetSplitPracticeLengthMinutes * 60) }
        
        var minimumSplitPracticeLengthMinutes: Int { 75 }
        var minimumSplitPracticeTimeInterval: TimeInterval { TimeInterval(minimumSplitPracticeLengthMinutes * 60) }
    }
    
    static let divisionsDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = .short
        dateFormatter.timeZone = .current
        return dateFormatter
    }()
    
    static let divisions = [
        Division(name: "Pinto", teamCount: 11, startDate: "3/11", endDate: "3/31", daysOfWeek: [.monday, .wednesday, .saturday], canUsePeeWees: true),
        Division(name: "Mustang", teamCount: 10, startDate: "3/11", endDate: "3/31", daysOfWeek: [.tuesday, .thursday, .saturday], canUsePeeWees: true),
        Division(name: "Bronco", teamCount: 8, startDate: "3/10", endDate: "3/31", daysOfWeek: [.monday, .wednesday, .friday], canUsePeeWees: false),
        Division(name: "Pony", teamCount: 2, startDate: "3/11", endDate: "3/31", daysOfWeek: [.tuesday, .thursday], canUsePeeWees: true)
    ]
    
    enum Field: String, CaseIterable {
        case peeWeeANorth = "Pee Wee Fields A North"
        case peeWeeBNorth = "Pee Wee Fields B North"
        case peeWeeASouth = "Pee Wee Fields A South"
        case peeWeeBSouth = "Pee Wee Fields B South"
        
        case delridgeSW = "Delridge Playfield Ballfield 01 (SW)"
        case delridgeNE = "Delridge Playfield Ballfield 02 (NE)"
        
        case sealthLowerUtility = "Sealth HS Complex Utility Field Lower"
        case sealthLowerSoftball = "Sealth HS Complex Softball Lower"
        case sealthUpperSoftball = "Sealth Upper Softball"
        
        case lincolnPark1 = "Lincoln Park Ballfield 01"
        case lincolnPark2 = "Lincoln Park Ballfield 02"
        case lincolnPark3 = "Lincoln Park Ballfield 03"
        
        case riverview1 = "Riverview Playfield Ballfield 01"
        case riverview2 = "Riverview Playfield Ballfield 02"
        case riverview3 = "Riverview Playfield Ballfield 03"
        case riverview4 = "Riverview Playfield Ballfield 04"
        
        case waltHundley1 = "Walt Hundley Playfield Ballfield 01"
        case waltHundley2 = "Walt Hundley Playfield Ballfield 02"
        
        static func fields(from rawValueOrPeeWees: String) -> [Field] {
            if rawValueOrPeeWees == "Pee Wees" {
                return [.peeWeeANorth, .peeWeeASouth, .peeWeeBNorth, .peeWeeBSouth]
            } else {
                return [.init(rawValue: rawValueOrPeeWees)!]
            }
        }
        
        var isPeeWeeSizedField: Bool {
            switch self {
            case .peeWeeANorth, .peeWeeBNorth, .peeWeeASouth, .peeWeeBSouth:
                return true
            default:
                return false
            }
        }
        
        var splitSortPriority: Int? {
            switch self {
            case .delridgeNE, .delridgeSW:
                return 0
            case .riverview1, .riverview2, .riverview3, .riverview4:
                return 1
            case .peeWeeANorth, .peeWeeBNorth, .peeWeeASouth, .peeWeeBSouth:
                return 2
            case .sealthLowerUtility:
                return 3
                
            default:
                return nil
            }
        }
        
        var isSplittable: Bool { splitSortPriority != nil }
    }
    
    struct Subfield: CustomStringConvertible {
        enum Subportion: String {
            case infield
            case outfield
        }
        
        let field: Field
        let subportion: Subportion
        
        var name: String {
            field.rawValue + " (" + subportion.rawValue.uppercased() + ")"
        }
        
        var description: String { name }
    }
    
    struct FieldAvailability {
        let field: Field
        let startTime: Date
        let duration: TimeInterval
        let division: Division
        
        internal init(field: Scheduler.Field, startTime: Date, duration: TimeInterval, division: Scheduler.Division) {
            self.field = field
            self.startTime = startTime
            self.duration = duration
            self.division = division
        }
        
        static let startAndEndTimeFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.timeZone = .current
            return dateFormatter
        }()
        
        init(field: Field, day: String, timeRange: String, division: String) {
            self.field = field
            self.division = divisions.first { $0.name == division }!
            
            let components = timeRange.components(separatedBy: "-")
            let startTimeString = "\(day) at \(components[0])".trimmingCharacters(in: .whitespaces)
            let endTimeString = "\(day) at \(components[1])".trimmingCharacters(in: .whitespaces)
            
            self.startTime = Self.startAndEndTimeFormatter.date(from: startTimeString)!
            let endTime = Self.startAndEndTimeFormatter.date(from: endTimeString)!
            self.duration = endTime.timeIntervalSince(startTime)
        }
    }
    
    enum Column: String {
        case date = "Date"
        case startToEnd = "Start - End Time"
        case field = "Facility/Equipment/Instructor"
        case division = "Division"
        case release = "Release\r"
    }
    
    struct Practice: CustomStringConvertible {
        enum Venue: CustomStringConvertible {
            case fullField(field: Field)
            case subfield(subfield: Subfield, sharingTeamIndex: Int)
            
            var description: String {
                switch self {
                case let .fullField(field):
                    return field.rawValue
                case let .subfield(subfield, sharingTeamIndex):
                    return subfield.description
                }
            }
        }
        
        let startTime: Date
        let duration: TimeInterval
        let division: Division
        let teamIndex: Int
        let venue: Venue
        
        static let timeFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            dateFormatter.timeZone = .current
            return dateFormatter
        }()
        
        static let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            dateFormatter.timeZone = .current
            return dateFormatter
        }()
        
        var description: String {
            let dateString = Self.dateFormatter.string(from: self.startTime)
            let startTimeString = Self.timeFormatter.string(from: self.startTime)
            let endTimeString = Self.timeFormatter.string(from: self.startTime.addingTimeInterval(self.duration))
            var string = "Team \(teamIndex) practices on \(dateString) from \(startTimeString) - \(endTimeString) at \(self.venue)"
            
            if case let .subfield(_, sharingTeamIndex: shareIndex) = venue {
                string += " sharing with team \(shareIndex)"
            }
            
            return string
        }
    }
    
//    let expectedHeader = ["Date", "Day", "Setup - Ready Time", "Start - End Time", "Facility/Equipment/Instructor", "Permit#", "Division", "Count", "Slots", "Sum", "Needs", "", "Release"]

    mutating func run() throws {
        let filepath = "/Users/jhollida/Desktop/wsbb_scheduler/wsbb_scheduler/fields.csv"
        let outputFolder = "/Users/jhollida/Desktop/wsbb_scheduler/wsbb_scheduler/generated_schedules"
        
        let csvData: CSV = try CSV<Named>(url: URL(fileURLWithPath: filepath))
        
        let headerRow = csvData.header
        print("Header: \(headerRow)")
        
        let fieldAvailability: [FieldAvailability] = csvData.rows
            .flatMap { row -> [FieldAvailability] in
                guard let division = row[Column.division.rawValue], !division.isEmpty else {
                    return []
                }
                
                // Read in fields, and split the Pee Wees up into individual fields
                let fields = Field.fields(from: row[Column.field.rawValue]!)
                return fields.map {
                    FieldAvailability(
                        field: $0,
                        day: row[Column.date.rawValue]!,
                        timeRange: row[Column.startToEnd.rawValue]!,
                        division: division
                    )
                }
            }
        
        Self.divisions.forEach { division in
            let schedule = schedule(division: division, with: fieldAvailability)
            print("\(division.name) SCHEDULE")
            for practice in schedule {
                print(practice)
            }
            print("-----------\n\n")
        }
        
    }
    
    func schedule(division: Division, with availability: [FieldAvailability]) -> [Practice] {
        let calendar: Calendar = .current
        return division.practiceDates.flatMap { (practiceDate: Date) -> [Practice] in
            let fieldsThatDay = availability.filter { field in
                calendar.isDate(practiceDate, inSameDayAs: field.startTime) &&
                field.division == division
            }
            
            let (fullLengthSuccess, fullLengthSplitPractices) = schedulePractices(
                for: division,
                on: practiceDate,
                with: fieldsThatDay,
                compressedSplits: false
            )
            
            if fullLengthSuccess {
                return fullLengthSplitPractices
            } else {
                let (shortSplitSuccess, practices) = schedulePractices(
                    for: division,
                    on: practiceDate,
                    with: fieldsThatDay,
                    compressedSplits: true
                )
                
                if !shortSplitSuccess {
                    print("Unable to schedule \(division.name) on \(practiceDate) due to insufficient fields")
                }
                
                return practices
            }
        }
    }
    
    func schedulePractices(
        for division: Division,
        on practiceDate: Date,
        with fieldAvailability: [FieldAvailability],
        compressedSplits: Bool
    ) -> (success: Bool, practices: [Practice]) {
        var remainingTeams = Array(0..<division.teamCount).shuffled()
        var remainingFields = fieldAvailability
        
        let splitDuration: TimeInterval = compressedSplits ?
        division.minimumSplitPracticeTimeInterval : division.targetSplitPracticeTimeInterval
        
        var practices = scheduleSplitsUntilEnoughForFullPractices(
            for: &remainingTeams,
            division: division,
            on: practiceDate,
            splitDuration: splitDuration,
            unsplitDuration: division.targetPracticeTimeInterval,
            with: &remainingFields
        )
        
        practices.append(
            contentsOf: scheduleFullPractices(
                for: &remainingTeams,
                division: division,
                on: practiceDate,
                duration: division.targetPracticeTimeInterval,
                with: &remainingFields
            )
        )
        
        practices.append(
            contentsOf: scheduleFullPractices(
                for: &remainingTeams,
                division: division,
                on: practiceDate,
                duration: division.minimumPracticeTimeInterval,
                with: &remainingFields
            )
        )
        
        return (success: remainingTeams.isEmpty, practices: practices)
    }
    
    func scheduleFullPractices(
        for remainingTeams: inout [Int],
        division: Division,
        on practiceDate: Date,
        duration: TimeInterval,
        with remainingFields: inout [FieldAvailability]
    ) -> [Practice] {
        guard remainingTeams.count > 0 && remainingFields.count > 0 else {
            return []
        }
        
        var practices = [Practice]()
        while !remainingFields.isEmpty &&
                !remainingTeams.isEmpty &&
                remainingFields.practiceCount(of: duration) != 0 {
            let field = remainingFields.removeFirst()
            if field.duration >= duration {
                let teamIndex = remainingTeams.removeFirst()
                let practice = Practice(
                    startTime: field.startTime,
                    duration: duration,
                    division: division,
                    teamIndex: teamIndex,
                    venue: .fullField(field: field.field)
                )
                practices.append(practice)
                
                let remainder = FieldAvailability(
                    field: field.field,
                    startTime: field.startTime + duration,
                    duration: field.duration - duration,
                    division: division
                )
                remainingFields.append(remainder)
            } else {
                remainingFields.append(field)
            }
        }
        
        return practices
    }
    
    func scheduleSplitsUntilEnoughForFullPractices(
        for remainingTeamIndices: inout [Int],
        division: Division,
        on practiceDate: Date,
        splitDuration: TimeInterval,
        unsplitDuration: TimeInterval,
        with fieldAvailability: inout [FieldAvailability]
    ) -> [Practice] {
        guard fieldAvailability.count > 0, remainingTeamIndices.count > 0 else {
            return []
        }

        var practices = [Practice]()
        while !fieldAvailability.isEmpty
                && !remainingTeamIndices.isEmpty
                && fieldAvailability.practiceCount(of: unsplitDuration) < remainingTeamIndices.count {
            
            if let (startTime, subfield1, subfield2) = fieldAvailability.splitPractice(with: splitDuration) {
                let teamIndex1 = remainingTeamIndices.removeLast()
                let teamIndex2 = remainingTeamIndices.removeLast()
                
                let practice1 = Practice(
                    startTime: startTime,
                    duration: splitDuration,
                    division: division,
                    teamIndex: teamIndex1,
                    venue: .subfield(subfield: subfield1, sharingTeamIndex: teamIndex2)
                )
                
                let practice2 = Practice(
                    startTime: startTime,
                    duration: splitDuration,
                    division: division,
                    teamIndex: teamIndex2,
                    venue: .subfield(subfield: subfield2, sharingTeamIndex: teamIndex1)
                )
                
                practices.append(practice1)
                practices.append(practice2)
            } else {
                break
            }
        }
        
        return practices
    }
    
    
    func earliestTime(on date: Date) -> Date {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let weekdaySymbol = calendar.weekdaySymbols[calendar.component(.weekday, from: date)]
        let weekday = Locale.Weekday(rawValue: weekdaySymbol)!
        
        let hoursToAdd: Int
        switch weekday {
        case .saturday, .sunday:
            hoursToAdd = 9 // 9 AM
        case .monday, .tuesday, .wednesday, .thursday, .friday:
            hoursToAdd = 17 // 5 PM
        }
        
        let secondsInHour = 60 * 60
        return dayStart.addingTimeInterval(TimeInterval(hoursToAdd * secondsInHour))
    }
}

extension Locale.Weekday {
    var weekdayOrdinal: Int {
        switch self {
        case .sunday:
            return 1
        case .monday:
            return 2
        case .tuesday:
            return 3
        case .wednesday:
            return 4
        case .thursday:
            return 5
        case .friday:
            return 6
        case .saturday:
            return 7
        }
    }
    
    init?(weekdayOrdinal: Int) {
        let allCases: [Self] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        let weekday = allCases.first { $0.weekdayOrdinal == weekdayOrdinal }
        if let weekday {
            self = weekday
        } else {
            return nil
        }
    }
}

extension Array where Element == Scheduler.FieldAvailability {
    func practiceCount(of duration: TimeInterval) -> Int {
        self.reduce(0) { (sum, field) in
            let slots = Int(field.duration) / Int(duration)
            return sum + slots
        }
    }
    
    func splitPracticeCount(of duration: TimeInterval, normalDuration: TimeInterval) -> Int {
        self.reduce(0) { (sum, field) in
            if field.field.isSplittable  {
                let timeSlots = Int(field.duration) / Int(duration)
                if timeSlots > 0 {
                    return sum + timeSlots
                }
            }
            
            let timeSlots = Int(field.duration) / Int(normalDuration)
            return sum + timeSlots
        }
    }
    
    mutating func splitPractice(with practiceDuration: TimeInterval)
    -> (startTime: Date, firstSubfield: Scheduler.Subfield, secondField: Scheduler.Subfield)? {
        let longestSplittableTimeSlot = self.enumerated()
            .filter { $0.element.field.isSplittable }
            .max { field1, field2 in
                field1.element.duration < field2.element.duration
            }
        
        if let (index, field) = longestSplittableTimeSlot, field.duration >= practiceDuration {
            let split = (
                field.startTime,
                Scheduler.Subfield(field: field.field, subportion: .infield),
                Scheduler.Subfield(field: field.field, subportion: .outfield)
            )
            
            let remainingDuration = field.duration - practiceDuration
            if remainingDuration > 0 {
                self[index] = Scheduler.FieldAvailability(
                    field: field.field,
                    startTime: field.startTime + practiceDuration,
                    duration: remainingDuration,
                    division: field.division
                )
            } else {
                self.remove(at: index)
            }
            
            return split
        }
        return nil
    }
}
