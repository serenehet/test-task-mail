//
//  Network.swift
//  tunes
//
//  Created by Sergei Alexeev on 24.11.2020.
//

import Foundation

protocol ItunesNetwork {
    func getMusics(
        term: String,
        callback: (([ItunesElement]) -> Void)?,
        failback: ((String) -> Void)?) -> Void
    func getMovies(
        term: String,
        callback: (([ItunesElement]) -> Void)?,
        failback: ((String) -> Void)?) -> Void
}

class Network: ItunesNetwork {
    static let instance = Network()
    private init() {}
    func getMusics(
        term: String,
        callback: (([ItunesElement]) -> Void)? = nil,
        failback: ((String) -> Void)? = nil) -> Void {
        guard let fixedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            failback?("Неверный формат запроса")
            return
        }
        let urlString = "https://itunes.apple.com/search?term=\(fixedTerm)&media=music&lang=ru_ru"
        
        self.itunesRequest(urlString: urlString, callback: callback, failback: failback)
    }

    func getMovies(
        term: String,
        callback: (([ItunesElement]) -> Void)? = nil,
        failback: ((String) -> Void)? = nil) -> Void {
        guard let fixedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            failback?("Неверный формат запроса")
            return
        }
        
        let urlString = "https://itunes.apple.com/search?term=\(fixedTerm)&media=movie&lang=ru_ru"
        
        self.itunesRequest(urlString: urlString, callback: callback, failback: failback)
    }
    
    private func itunesRequest(
        urlString: String,
        callback: (([ItunesElement]) -> Void)? = nil,
        failback: ((String) -> Void)? = nil) -> Void {
        
        guard let url = URL(string: urlString) else {
            failback?("Запрос не получилось отправить")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                failback?(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                failback?("Ничего не найдено")
                return
            }
            
            if let body = try? JSONDecoder().decode(ItunesResponse.self, from: data) {
                callback?(body.results)
            } else {
                failback?("Ошибка при получении результа")
            }
        }
        
        task.resume()
    }
}
