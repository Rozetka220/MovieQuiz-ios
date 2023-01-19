//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Аделия Исхакова on 15.01.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testScreenCast() throws {
        XCUIApplication()/*@START_MENU_TOKEN@*/.staticTexts["Нет"]/*[[".buttons[\"Нет\"].staticTexts[\"Нет\"]",".buttons[\"No\"].staticTexts[\"Нет\"]",".staticTexts[\"Нет\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
                
    }
    
    func testYesButton() throws {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    func testNoButton() throws {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testAlert() throws {
        sleep(5)
        let alert = app.alerts["gameOverAlertId"]
        
        for _ in 0...9 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        sleep(5)
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
        sleep(5)
    }
    
    func testAlertDismiss() throws {
        sleep(5)
        let alert = app.alerts["gameOverAlertId"]
        
        for _ in 0...9 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        sleep(5)
        
        alert.buttons.firstMatch.tap()
        
        sleep(5)
        
        let indexLabel = app.staticTexts["Index"]
        
        sleep(5)
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
        sleep(5)
    }
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
