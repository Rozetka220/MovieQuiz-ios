//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Аделия Исхакова on 17.12.2022.
//
import UIKit

struct AlertModel {
    let title: String
    let message: String //был String
    let buttonText: String
    var completion: (UIAlertAction) -> Void
}
