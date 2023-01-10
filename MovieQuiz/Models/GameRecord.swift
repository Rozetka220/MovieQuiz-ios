//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 07.01.2023.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int //кол-во правильный ответов
    let total: Int //кол-во вопросов
    let date: Date //дата завершения раунда
}

extension GameRecord: Comparable {
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
    static func > (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct > rhs.correct
    }
    static func == (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct == rhs.correct
    }
}
