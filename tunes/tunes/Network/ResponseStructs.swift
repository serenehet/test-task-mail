//
//  ResponseStructs.swift
//  tunes
//
//  Created by Sergei Alexeev on 25.11.2020.
//

import Foundation

struct ItunesElement: Decodable {
    var artistName: String
    var trackName: String
    var artworkUrl100: String
    var previewUrl: String
}

struct ItunesResponse: Decodable {
    var resultCount: Int
    var results: [ItunesElement]
}
