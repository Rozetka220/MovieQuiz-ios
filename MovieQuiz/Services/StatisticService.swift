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
    var totalAccuracy: Double = 0.0
    
    var gamesCount: Int = 0
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    var getSetTotalAccuracy: Double {
        get{
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let totalAccuracy = try? JSONDecoder().decode(Double.self, from: data) else {
                    return 0
                    }
            return totalAccuracy
        }set{
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            totalAccuracy = newValue
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    var getSetGamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let gamesCount = try? JSONDecoder().decode(Int.self, from: data) else {
                        return 0
                    }
            return gamesCount
        }set{
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            gamesCount = newValue
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
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
        //здесь должны записывать новый лучший результат в бестгейм
        //refresh()
        var newBestGame = GameRecord(correct: count, total: amount, date: Date())
        getSetGamesCount += 1
        if newBestGame > bestGame {
            bestGame = newBestGame
        }
        averageAccuracy(correct: count, total: amount)
        print("count = \(count) total = \(amount) totalAccuracy = \(totalAccuracy)")
    }
    func averageAccuracy(correct count: Int, total amount: Int) {
        if (gamesCount == 0) {
            getSetTotalAccuracy = (getSetTotalAccuracy + Double(count) / Double(amount) * 100)
        } else {
            getSetTotalAccuracy = (getSetTotalAccuracy + Double(count) / Double(amount) * 100) / Double(gamesCount)
        }
        print("count = \(count) total = \(amount) totalAccuracy = \(totalAccuracy)")
    }
    
    func refresh(){
        userDefaults.set(0, forKey: Keys.total.rawValue)
        
        userDefaults.set(0, forKey: Keys.gamesCount.rawValue)
        
        userDefaults.set(0, forKey: Keys.bestGame.rawValue)
    }
}
