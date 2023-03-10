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
        let teamNames: [String]
        let startDate: Date
        let endDate: Date
        let daysOfWeek: [Locale.Weekday]
        let canUsePeeWees: Bool
        let teamSnapName: String
        
        var teamCount: Int { teamNames.count }
        
        init(name: String, teamNames: [String], startDate: String, endDate: String, daysOfWeek: [Locale.Weekday], canUsePeeWees: Bool, teamSnapName: String) {
            self.name = name
            self.teamNames = teamNames
            self.startDate = divisionsDateFormatter.date(from: startDate + "/\(year)")!
            self.endDate = divisionsDateFormatter.date(from: endDate + "/\(year)")!
            self.daysOfWeek = daysOfWeek
            self.canUsePeeWees = canUsePeeWees
            self.teamSnapName = teamSnapName
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
    
    static let pintoTeamNames: [String] = [
        "Wildwood Market",
        "Tom's Auto",
        "Raynor Construction",
        "Pivar",
        "O'Neill Plumbing",
        "Northwest Art & Frame",
        "Menashe Jewelers",
        "Charter Construction",
        "Camp Crockett",
        "Boss Drive-In",
        "Alki Lumber",
    ]
    
    static let mustangTeamNames: [String] = [
        "Wildwood Market",
        "Salon",
        "O'Neill Plumbing",
        "Northwest Art & Frame",
        "Menashe Jewelers",
        "HIIT Lab",
        "ES&N",
        "Alki Lumber",
    ]
    
    static let broncoTeamNames: [String] = [
        "The Salon",
        "TBD1",
        "TBD2",
        "SGB Warriors",
        "O'Neill Red Sox",
        "Crockett Chihuahuas",
        "Boss Pirates",
    ]
    
    static let ponyTeamNames: [String] = [
        "West Seattle Pony"
    ]
    
    static let divisions = [
        Division(name: "Pinto", teamNames: pintoTeamNames, startDate: "3/11", endDate: "3/31", daysOfWeek: [.monday, .wednesday, .saturday], canUsePeeWees: true, teamSnapName: "Pinto 8U"),
        Division(name: "Mustang", teamNames: mustangTeamNames, startDate: "3/11", endDate: "3/31", daysOfWeek: [.tuesday, .thursday, .saturday], canUsePeeWees: true, teamSnapName: "Mustang 10U"),
        Division(name: "Bronco", teamNames: broncoTeamNames, startDate: "3/10", endDate: "3/31", daysOfWeek: [.monday, .wednesday, .friday], canUsePeeWees: false, teamSnapName: "Bronco 12U"),
        Division(name: "Pony", teamNames: ponyTeamNames, startDate: "3/11", endDate: "3/31", daysOfWeek: [.tuesday, .thursday], canUsePeeWees: true, teamSnapName: "Pony 14U")
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
        
        var splitSortPriority: Int {
            switch self {
            case .delridgeNE, .delridgeSW:
                return 4
            case .sealthLowerUtility, .sealthLowerSoftball, .sealthUpperSoftball:
                return 3
            case .riverview1, .riverview2, .riverview3, .riverview4:
                return 2
            case .peeWeeANorth, .peeWeeBNorth, .peeWeeASouth, .peeWeeBSouth:
                return 1
            
            default:
                return 0
            }
        }
        
        var isSplittable: Bool { splitSortPriority != 0 }
        
        var teamSnapName: String {
            switch self {
                
            case .peeWeeANorth:
                return "Pee Wee Field - A North"
            case .peeWeeBNorth:
                return "Pee Wee Field - B North"
            case .peeWeeASouth:
                return "Pee Wee Field - A South"
            case .peeWeeBSouth:
                return "Pee Wee Field - B South"
            case .delridgeSW:
                return "Delridge SW Corner"
            case .delridgeNE:
                return "Delridge NE Corner"
            case .sealthLowerUtility:
                return "Sealth Utility"
            case .sealthLowerSoftball:
                return "Sealth Softball Lower"
            case .sealthUpperSoftball:
                return "Sealth Softball Upper"
            case .lincolnPark1:
                return "Lincoln Park Field #1"
            case .lincolnPark2:
                return "Lincoln Park Field #2"
            case .lincolnPark3:
                return "Lincoln Park Field #3"
            case .riverview1:
                return "Riverview Playfield # 1"
            case .riverview2:
                return "Riverview Playfield # 2"
            case .riverview3:
                return "Riverview Playfield #3"
            case .riverview4:
                return "Riverview Playfield #4"
            case .waltHundley1:
                return "Walt Hundley Playfield - #1 (Upper Field)"
            case .waltHundley2:
                return "Walt Hundley Playfield - #2 (Upper Field)"
            }
        }
    }
    
    struct Subfield: CustomStringConvertible {
        enum Subportion: String {
            case infield
            case outfield
        }
        
        let field: Field
        let subportion: Subportion
        
        var teamSnapName: String {
            switch (field, subportion) {
            case (.delridgeNE, .infield):
                return "Delridge NE Corner"
            case (.delridgeNE, .outfield):
                return "Delridge NW Corner"
            case (.delridgeSW, .infield):
                return "Delridge SW Corner"
            case (.delridgeSW, .outfield):
                return "Delridge SE Corner"
            default:
                return field.teamSnapName + " " + subportion.rawValue.uppercased()
            }
        }
        
        var description: String { teamSnapName }
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
                case let .subfield(subfield, _):
                    return subfield.description
                }
            }
            
            var teamSnapName: String {
                switch self {
                case let .fullField(field):
                    return field.teamSnapName
                case let .subfield(subfield, _):
                    return subfield.teamSnapName
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
        
        let schedule = Self.divisions.flatMap { division in
            return self.schedule(division: division, with: fieldAvailability)
        }
        
        let writeURL = URL(filePath: outputFolder).appending(path: "schedule_full.csv")
        write(practices: schedule, to: writeURL)
    }
    
    func schedule(division: Division, with availability: [FieldAvailability]) -> [Practice] {
        let calendar: Calendar = .current
        let zeroSplitCounts = (0..<division.teamCount).map { ($0, 0) }
        var splitCounts: [Int: Int] = .init(uniqueKeysWithValues: zeroSplitCounts)
        
        return division.practiceDates.flatMap { (practiceDate: Date) -> [Practice] in
            let fieldsThatDay = availability.filter { field in
                calendar.isDate(practiceDate, inSameDayAs: field.startTime) &&
                field.division == division
            }
            
            let (fullLengthSuccess, fullLengthSplitPractices) = schedulePractices(
                for: division,
                on: practiceDate,
                with: fieldsThatDay, splitCounts: &splitCounts,
                compressedSplits: false
            )
            
            if fullLengthSuccess {
                return fullLengthSplitPractices
            } else {
                let (shortSplitSuccess, practices) = schedulePractices(
                    for: division,
                    on: practiceDate,
                    with: fieldsThatDay,
                    splitCounts: &splitCounts,
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
        splitCounts: inout [Int: Int],
        compressedSplits: Bool
    ) -> (success: Bool, practices: [Practice]) {
        var remainingTeams = Array(0..<division.teamCount).shuffled()
        var remainingFields = fieldAvailability
        
        let splitDuration: TimeInterval = compressedSplits ?
        division.minimumSplitPracticeTimeInterval : division.targetSplitPracticeTimeInterval
        
        var practices = scheduleSplitsUntilEnoughForFullPractices(
            for: &remainingTeams,
            division: division,
            splitCounts: &splitCounts,
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
        var practices = [Practice]()
        while !remainingFields.isEmpty &&
                !remainingTeams.isEmpty &&
                remainingFields.practiceCount(of: duration) != 0 {
            let field = remainingFields.removeFirst()
            if field.duration >= duration {
                let teamIndex = remainingTeams.removeFirst()
                let remainderDuration = field.duration - duration
                
                // if we can give them a longer practice, do it.
                let extendPractice = remainderDuration < division.minimumPracticeTimeInterval
                
                let practice = Practice(
                    startTime: field.startTime,
                    duration: duration,
                    division: division,
                    teamIndex: teamIndex,
                    venue: .fullField(field: field.field)
                )
                practices.append(practice)
                
                if !extendPractice {
                    let remainder = FieldAvailability(
                        field: field.field,
                        startTime: field.startTime + duration,
                        duration: remainderDuration,
                        division: division
                    )
                    remainingFields.append(remainder)
                }
            } else {
                remainingFields.append(field)
            }
        }
        
        return practices
    }
    
    func scheduleSplitsUntilEnoughForFullPractices(
        for remainingTeamIndices: inout [Int],
        division: Division,
        splitCounts: inout [Int: Int],
        on practiceDate: Date,
        splitDuration: TimeInterval,
        unsplitDuration: TimeInterval,
        with fieldAvailability: inout [FieldAvailability]
    ) -> [Practice] {
        var practices = [Practice]()
        while !fieldAvailability.isEmpty
                && !remainingTeamIndices.isEmpty
                && fieldAvailability.practiceCount(of: unsplitDuration) < remainingTeamIndices.count {
            
            if let (startTime, subfield1, subfield2) = fieldAvailability.splitPractice(with: splitDuration) {
                let teamIndex1 = remainingTeamIndices.removeTeamWithLowestSplitCount(splitCounts: &splitCounts)
                let teamIndex2 = remainingTeamIndices.removeTeamWithLowestSplitCount(splitCounts: &splitCounts)
                
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
    
    func write(practices: [Practice], to url: URL) {
        var rows: [String] = practices.map { practice in
            let dateCol = practice.startTime.formatted(date: .numeric, time: .omitted)
            let startCol = practice.startTime.formatted(date: .omitted, time: .shortened)
            let endCol = (practice.startTime + practice.duration).formatted(date: .omitted, time: .shortened)
            let arriveEarly = "15"
            let name = "Practice"
            let eventType = "Practice"
            let division = practice.division.teamSnapName
            let homeTeam = practice.division.teamNames[practice.teamIndex]
            let awayTeam = ""
            let location = practice.venue.teamSnapName
            let locationDetails = ""
            
            let notes: String
            if case let .subfield(_, sharingTeamIndex) = practice.venue {
                let splitTeam = practice.division.teamNames[sharingTeamIndex]
                notes = "Your team will be splitting the field with \(splitTeam). Consider trading use of the infield at the halfway point."
            } else {
                notes = ""
            }
            
            return [dateCol, startCol, endCol, arriveEarly, name, eventType, division, homeTeam, awayTeam, location, locationDetails, notes].joined(separator: ",")
        }
        
        let header = "Date,Start Time,End Time,Arrival Time,Short Label,Event Type,Division,Home Team,Away Team,Location,Location Details, Notes"
        rows.insert(header, at: 0)
        
//        for row in rows {
//            print(row)
//        }
        
        let fileString = rows.joined(separator: "\n")
        try? FileManager.default.removeItem(at: url)
        try! fileString.write(to: url, atomically: true, encoding: .utf8)
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

extension Array where Element == Int {
    mutating func removeTeamWithLowestSplitCount(splitCounts: inout [Int : Int]) -> Int {
        let teamIndex = self.enumerated().min { teamIndex1, teamIndex2 in
            splitCounts[teamIndex1.element]! < splitCounts[teamIndex2.element]!
        }!
        
        
        splitCounts[teamIndex.element, default: 0] += 1
        return self.remove(at: teamIndex.offset)
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
        let highestPriSlot = self.enumerated()
            .filter { $0.element.field.isSplittable && $0.element.duration >= practiceDuration }
            .max { field1, field2 in
                // sort first by split priority, then by duration
                if field1.element.field.splitSortPriority == field2.element.field.splitSortPriority {
                    return field1.element.duration < field2.element.duration
                } else {
                    return field1.element.field.splitSortPriority < field2.element.field.splitSortPriority
                }
            }
        
        if let (index, field) = highestPriSlot {
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
