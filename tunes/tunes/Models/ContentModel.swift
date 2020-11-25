//
//  ContentModel.swift
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

struct Movie: Decodable {
    
}

final class ContentModel {    
    init() {}
    
    func getMusics(
        term: String,
        callback: (([ItunesElement]) -> Void)? = nil,
        failback: ((String) -> Void)? = nil) {
        let urlString = "https://itunes.apple.com/search?term=\(term.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&media=music&entity=musicTrack&lang=ru_ru"
        
        self.itunesRequest(urlString: urlString, callback: callback, failback: failback)
    }

    func getMovies(
        term: String,
        callback: (([ItunesElement]) -> Void)? = nil,
        failback: ((String) -> Void)? = nil) {
        
        let urlString = "https://itunes.apple.com/search?term=\(term.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&media=movie&entity=movie&lang=ru_ru"
        
        self.itunesRequest(urlString: urlString, callback: callback, failback: failback)
    }
    
    private func itunesRequest(
        urlString: String,
        callback: (([ItunesElement]) -> Void)? = nil,
        failback: ((String) -> Void)? = nil) {
        
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                failback?(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                failback?("Ничего не найдено")
                return
            }
            
            let stringBody = String(data: data, encoding: .utf8) //для русских символов
            if let body = try? JSONDecoder().decode(ItunesResponse.self, from: stringBody!.data(using: .utf8)!) {
                if (body.resultCount == 0) {
                    failback?("Ничего не найдено")
                    return
                }
                
                callback?(body.results)
            } else {
                failback?("Ошибка при получении результа")
            }
        }
        
        task.resume()
    }
}