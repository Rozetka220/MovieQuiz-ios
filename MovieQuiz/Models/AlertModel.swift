//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 17.12.2022.
//

import Foundation
import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion: (UIAlertAction) -> Void
}
