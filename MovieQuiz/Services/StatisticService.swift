//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 07.01.2023.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get } //точность
    var gamesCount: Int { get } //кол-во игр
    var bestGame: GameRecord { get } //лучшая игра
    
    func store(correct count: Int, total amount: Int)
}


final class StatisticServiceImplementation: StatisticService {    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    var totalAccuracy: Double {
        get{
            return userDefaults.double(forKey: Keys.total.rawValue)
        }set{
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }set{
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                    return .init(correct: 0, total: 0, date: Date())
                }
            return record
        } set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        refresh()
        var newBestGame = GameRecord(correct: count, total: amount, date: Date())
        gamesCount += 1
        if newBestGame > bestGame {
            bestGame = newBestGame
        }
        averageAccuracy(correct: count, total: amount)
    }
    func averageAccuracy(correct count: Int, total amount: Int) {
        if (gamesCount == 0) {
            totalAccuracy = (totalAccuracy + Double(count) / Double(amount) * 100)
        } else {
            totalAccuracy = (totalAccuracy + Double(count) / Double(amount) * 100) / Double(gamesCount)
        }
    }
    
    func refresh(){
        userDefaults.set(0, forKey: Keys.total.rawValue)

        userDefaults.set(0, forKey: Keys.gamesCount.rawValue)

        userDefaults.set(0, forKey: Keys.bestGame.rawValue)
    }
}
