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
        case peeWees = "Pee Wees"
        
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
        
        var isPeeWeeSizedField: Bool {
            switch self {
            case .peeWees:
                return true
            default:
                return false
            }
        }
        
        var isSplittable: Bool {
            switch self {
            case .delridgeNE, .delridgeSW, .riverview1, .riverview2, .riverview3, .riverview4, .sealthLowerUtility:
                return true
            default:
                return false
            }
        }
        
        var split: (Subfield, Subfield)? {
            return (
                Subfield(field: self, subportion: .infield),
                Subfield(field: self, subportion: .outfield)
            )
        }
    }
    
    struct Subfield {
        enum Subportion: String {
            case infield
            case outfield
        }
        
        let field: Field
        let subportion: Subportion
        
        var name: String {
            field.rawValue + "_" + subportion.rawValue
        }
    }
    
    struct FieldAvailability {
        let field: Field
        let startTime: Date
        let endTime: Date
        let division: Division
        
        static let startAndEndTimeFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.timeZone = .current
            return dateFormatter
        }()
        
        init(field: String, day: String, timeRange: String, division: String) {
            self.field = Field(rawValue: field)!
            self.division = divisions.first { $0.name == division }!
            
            let components = timeRange.components(separatedBy: "-")
            let startTimeString = "\(day) at \(components[0])".trimmingCharacters(in: .whitespaces)
            let endTimeString = "\(day) at \(components[1])".trimmingCharacters(in: .whitespaces)
            
            self.startTime = Self.startAndEndTimeFormatter.date(from: startTimeString)!
            self.endTime = Self.startAndEndTimeFormatter.date(from: endTimeString)!
        }
    }
    
    enum Column: String {
        case date = "Date"
        case startToEnd = "Start - End Time"
        case field = "Facility/Equipment/Instructor"
        case division = "Division"
        case release = "Release\r"
    }
    
    struct Practice {
        enum Venue {
            case fullField(field: Field)
            case subfield(subfield: Subfield, sharingTeamIndex: Int)
        }
        
        let startTime: Date
        let duration: TimeInterval
        let division: Division
        let teamIndex: Int
        let venue: Venue
    }
    
//    let expectedHeader = ["Date", "Day", "Setup - Ready Time", "Start - End Time", "Facility/Equipment/Instructor", "Permit#", "Division", "Count", "Slots", "Sum", "Needs", "", "Release"]

    mutating func run() throws {
        let filepath = "/Users/jhollida/Desktop/wsbb_scheduler/wsbb_scheduler/fields.csv"
        let outputFolder = "/Users/jhollida/Desktop/wsbb_scheduler/wsbb_scheduler/generated_schedules"
        
        let csvData: CSV = try CSV<Named>(url: URL(fileURLWithPath: filepath))
        
        let headerRow = csvData.header
        print("Header: \(headerRow)")
        
        let fieldAvailability: [FieldAvailability] = csvData.rows
            .compactMap { row in
                guard let division = row[Column.division.rawValue], !division.isEmpty else {
                    return nil
                }
                
                return FieldAvailability(
                    field: row[Column.field.rawValue]!,
                    day: row[Column.date.rawValue]!,
                    timeRange: row[Column.startToEnd.rawValue]!,
                    division: division
                )
            }
        
        Self.divisions.forEach {
            let schedule = schedule(division: $0, with: fieldAvailability)
        }
        
    }
    
    func schedule(division: Division, with availability: [FieldAvailability]) -> [Practice] {
        print("\(division.name) division has practices on: \(division.practiceDates)")
        return []
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
            hoursToAdd = 17 //5 PM
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
