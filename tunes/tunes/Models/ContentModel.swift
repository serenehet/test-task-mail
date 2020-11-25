//
//  ContentModel.swift
//  tunes
//
//  Created by Sergei Alexeev on 25.11.2020.
//

import Foundation

final class ContentModel {
    
    private var network: ItunesNetwork = Network.instance
    
    private var isMusic: Bool
    
    private var movies: [ItunesElement]?
    
    private var musics: [ItunesElement]?
    
    init() {
        self.isMusic = true
    }
    
    func contentChange() -> Void {
        self.isMusic = !self.isMusic
    }
    
    func size() -> Int {
        return self.isMusic ? self.musics?.count ?? 0 : self.movies?.count ?? 0
    }
    
    func getElement(index: Int) -> ItunesElement? {
        return self.isMusic ? self.musics?[index] : self.movies?[index]
    }
    
    func clear() -> Void {
        self.movies = nil
        self.musics = nil
    }
    
    func ready() -> Bool {
        return self.musics != nil && self.movies != nil
    }
    
    func fillMovies(
        term: String,
        callback: (() -> Void)? = nil,
        failback: ((String) -> Void)? = nil) {
        
        let modelCallback = { [weak self] (movies: [ItunesElement]) in
            self?.movies = movies
            callback?()
        }
        
        self.network.getMovies(term: term, callback: modelCallback, failback: failback)
    }
    
    func fillMusics(
        term: String,
        callback: (() -> Void)? = nil,
        failback: ((String) -> Void)? = nil) {
        
        let modelCallback = { [weak self] (musics: [ItunesElement]) in
            self?.musics = musics
            callback?()
        }
        
        self.network.getMusics(term: term, callback: modelCallback, failback: failback)
    }
    
}
