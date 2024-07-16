//
//  TaskFrequency.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 14/05/24.
//

import Foundation

/// Defines how often a task can be completed.
enum TaskFrequency: String, Codable {
    case daily
    case weekly
    case monthly
}
