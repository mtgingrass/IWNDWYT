//
//  DataExportManager.swift
//  IWNDWYT
//
//  Created by Claude Code on 1/9/25.
//

import Foundation
import UIKit

struct ExportableData: Codable {
    let version: String
    let exportDate: Date
    let deviceInfo: String
    let appVersion: String
    let streakData: StreakData
    
    init(streakData: StreakData) {
        self.version = "1.0"
        self.exportDate = Date()
        self.deviceInfo = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        self.streakData = streakData
    }
}

enum DataExportError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case fileCreationFailed
    case fileNotFound
    case invalidFormat
    case unsupportedVersion
    case corruptedData
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode data for export"
        case .decodingFailed:
            return "Failed to decode imported data"
        case .fileCreationFailed:
            return "Failed to create export file"
        case .fileNotFound:
            return "Import file not found"
        case .invalidFormat:
            return "Invalid file format"
        case .unsupportedVersion:
            return "Unsupported export version"
        case .corruptedData:
            return "Data appears to be corrupted"
        }
    }
}

class DataExportManager {
    static let shared = DataExportManager()
    
    private init() {}
    
    // MARK: - Export
    
    func exportData(_ streakData: StreakData) -> Result<URL, DataExportError> {
        let exportableData = ExportableData(streakData: streakData)
        
        // Create JSON data
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        guard let jsonData = try? encoder.encode(exportableData) else {
            return .failure(.encodingFailed)
        }
        
        // Create file in Documents directory for better sharing access
        let fileName = "IWNDWYT_Export_\(formatDateForFilename(Date())).json"
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .failure(.fileCreationFailed)
        }
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            try jsonData.write(to: fileURL)
            return .success(fileURL)
        } catch {
            return .failure(.fileCreationFailed)
        }
    }
    
    // MARK: - Import
    
    func importData(from url: URL) -> Result<StreakData, DataExportError> {
        // Read file data
        guard let jsonData = try? Data(contentsOf: url) else {
            return .failure(.fileNotFound)
        }
        
        // Decode JSON
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let exportableData = try? decoder.decode(ExportableData.self, from: jsonData) else {
            return .failure(.decodingFailed)
        }
        
        // Validate version compatibility
        guard isVersionSupported(exportableData.version) else {
            return .failure(.unsupportedVersion)
        }
        
        // Validate data integrity
        guard isDataValid(exportableData.streakData) else {
            return .failure(.corruptedData)
        }
        
        return .success(exportableData.streakData)
    }
    
    // MARK: - Validation
    
    private func isVersionSupported(_ version: String) -> Bool {
        // Currently only supporting version 1.0
        return version == "1.0"
    }
    
    private func isDataValid(_ streakData: StreakData) -> Bool {
        // Basic validation checks
        
        // Check if dates are reasonable (not in far future)
        let maxDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        
        if streakData.currentStartDate > maxDate {
            return false
        }
        
        // Validate past streaks
        for streak in streakData.pastStreaks {
            if streak.startDate > streak.endDate {
                return false
            }
            if streak.startDate > maxDate || streak.endDate > maxDate {
                return false
            }
            if streak.length < 0 {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Helper Methods
    
    private func formatDateForFilename(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: date)
    }
    
    func getExportPreview(_ streakData: StreakData) -> String {
        let currentStreak = streakData.isActiveStreak ? 
            Calendar.current.dateComponents([.day], from: streakData.currentStartDate, to: Date()).day ?? 0 : 0
        
        let pastStreaksCount = streakData.pastStreaks.count
        let longestStreak = streakData.pastStreaks.map { $0.length }.max() ?? currentStreak
        let totalDays = streakData.pastStreaks.reduce(0) { $0 + $1.length } + currentStreak
        
        return """
        Export Preview:
        • Current Streak: \(currentStreak) days
        • Past Streaks: \(pastStreaksCount) 
        • Longest Streak: \(longestStreak) days
        • Total Days: \(totalDays) days
        • Export Date: \(Date().formatted(date: .abbreviated, time: .shortened))
        """
    }
    
    func getImportPreview(_ url: URL) -> Result<String, DataExportError> {
        guard let jsonData = try? Data(contentsOf: url) else {
            return .failure(.fileNotFound)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let exportableData = try? decoder.decode(ExportableData.self, from: jsonData) else {
            return .failure(.decodingFailed)
        }
        
        let streakData = exportableData.streakData
        let currentStreak = streakData.isActiveStreak ? 
            Calendar.current.dateComponents([.day], from: streakData.currentStartDate, to: Date()).day ?? 0 : 0
        
        let pastStreaksCount = streakData.pastStreaks.count
        let longestStreak = streakData.pastStreaks.map { $0.length }.max() ?? currentStreak
        let totalDays = streakData.pastStreaks.reduce(0) { $0 + $1.length } + currentStreak
        
        let preview = """
        Import Preview:
        • Current Streak: \(currentStreak) days
        • Past Streaks: \(pastStreaksCount)
        • Longest Streak: \(longestStreak) days
        • Total Days: \(totalDays) days
        • Export Date: \(exportableData.exportDate.formatted(date: .abbreviated, time: .shortened))
        • Device: \(exportableData.deviceInfo)
        • Version: \(exportableData.version)
        """
        
        return .success(preview)
    }
}