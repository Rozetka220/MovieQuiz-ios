//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Аделия Исхакова on 15.01.2023.
//

import Foundation
import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws { // тест на успешное взятие элемента по индексу
        //Given
        let array = [1,1,2,5,6]
        
        //When
        let value = array[safe: 2]
        
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws { // тест на взятие элемента по неправильному индексу
        //Given
        let array = [1,1,2,5,6]
        
        //When
        let value = array[safe: 6]
        
        //Then
        XCTAssertNil(value)
    }
}
