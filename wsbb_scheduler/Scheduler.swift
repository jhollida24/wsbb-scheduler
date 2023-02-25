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
    
    
        
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()
    
    struct Division: Decodable {
        let name: String
        let teamCount: Int
        let startDate: Date
        let endDate: Date
        let daysOfWeek: [Locale.Weekday]
        let canUsePeeWees: Bool
        
        init(name: String, teamCount: Int, startDate: String, endDate: String, daysOfWeek: [Locale.Weekday], canUsePeeWees: Bool) {
            self.name = name
            self.teamCount = teamCount
            self.startDate = dateFormatter.date(from: startDate + "/\(year)")!
            self.endDate = dateFormatter.date(from: startDate + "/\(year)")!
            self.daysOfWeek = daysOfWeek
            self.canUsePeeWees = canUsePeeWees
        }
    }
    
    static let divisions = [
        Division(name: "Pinto", teamCount: 11, startDate: "3/11", endDate: "3/31", daysOfWeek: [.monday, .wednesday, .saturday], canUsePeeWees: true),
        Division(name: "Mustang", teamCount: 10, startDate: "3/11", endDate: "3/31", daysOfWeek: [.tuesday, .thursday, .saturday], canUsePeeWees: true),
        Division(name: "Bronco", teamCount: 8, startDate: "3/10", endDate: "3/31", daysOfWeek: [.monday, .wednesday, .friday], canUsePeeWees: false),
        Division(name: "Pony", teamCount: 2, startDate: "3/11", endDate: "3/31", daysOfWeek: [.tuesday, .thursday], canUsePeeWees: true)
    ]
    
    enum Field: String, CaseIterable {
        case peeWees = "Pee Wees"
        
        case delridgeSW = "Delridge Playfield Ballfield 01 (SW)"
        case delridgeSW_Infield = "Delridge SW (Infield)"
        case delridgeSW_Outfield = "Delridge SW (Outfield)"
        
        case delridgeNE = "Delridge Playfield Ballfield 02 (NE)"
        case delridgeNE_Infield = "Delridge NE (Infield)"
        case delridgeNE_Outfield = "Delridge NE (Outfield)"
        
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
        
        init(field: String, timeRange: String, division: String) {
            self.field = Field(rawValue: field)!
            self.division = divisions.first { $0.name == division }!
            self.startTime = Date()
            self.endTime = Date()
        }
    }
    
    enum Column: String {
        case date = "Date"
        case startToEnd = "Start - End Time"
        case field = "Facility/Equipment/Instructor"
        case division = "Division"
        case release = "Release\r"
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
                
                let timeRange = row[Column.date.rawValue]! + " " + row[Column.startToEnd.rawValue]!
                return FieldAvailability(
                    field: row[Column.field.rawValue]!,
                    timeRange: timeRange,
                    division: division
                )
            }
        
        print(fieldAvailability)
    }

}
