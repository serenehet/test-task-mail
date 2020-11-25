//
//  StartViewController.swift
//  tunes
//
//  Created by Sergei Alexeev on 24.11.2020.
//

import UIKit

final class StartViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var contentSwitch: UISegmentedControl!
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    private var term: String = ""
    private var musics: [ItunesElement]?
    private var movies: [ItunesElement]?
    
    private lazy var model = ContentModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loaderChange(animate: false)
        self.contentChange(hidden: true)
        
        self.contentTableView.delegate = self
//        self.contentTableView.dataSource = self
    }
    
    private func contentChange(hidden: Bool) -> Void {
        self.contentTableView.isHidden = hidden
        self.contentSwitch.isHidden = hidden
    }
    
    private func loaderChange(animate: Bool) -> Void {
        self.loader.isHidden = !animate
        animate ? self.loader.startAnimating() : self.loader.stopAnimating()
    }
    
    private func hideKeyboard() -> Void {
        // при нажатии вне клавиатуры скрываем её
        // при изменении дизигна можем навесить еще что-нибудь
        self.searchTextField.resignFirstResponder()
    }
    
    private func renderError(text: String) -> Void {
        let alertController = UIAlertController(title: "Ошибка", message: text, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Закрыть", style: .cancel)
        alertController.addAction(actionCancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func validateSearchInput() -> String? {
        guard let input = self.searchTextField.text else {
            self.renderError(text: "вы ничего не ввели")
            return nil
        }
        
        if input == "" {
            self.renderError(text: "Вы ничего не ввели")
            return nil
        }
        
        if input == self.term {
            self.renderError(text: "Вы уже вводили такое =)")
            return nil
        }
        
        return input
    }
    
    private func updateTableView() -> Void {
        if (self.movies == nil || self.musics == nil) {
            return
        }

        DispatchQueue.main.async {
            self.contentTableView.reloadData()
            self.loaderChange(animate: false)
            self.contentChange(hidden: false)
        }
    }

    
    
    @IBAction func clickSearchButton(_ sender: Any) {
        guard let term = self.validateSearchInput() else {
            return
        }
        self.term = term
        
        self.loaderChange(animate: true)
        self.hideKeyboard()
        self.contentChange(hidden: true)
        
        self.musics = nil
        self.movies = nil
        
        let callbackMusics = { [weak self] (musics: [ItunesElement]) in
            self?.musics = musics
            print("music", self?.musics![0])
            self?.updateTableView()
        }
        
        let failback = { [weak self] (error: String) in
            DispatchQueue.main.async {
                self?.loaderChange(animate: false)
                self?.contentChange(hidden: true)
                self?.renderError(text: error)
            }
        }
        
        self.model.getMusics(term: term, callback: callbackMusics, failback: failback)
        
        let callbackMovies = { [weak self] (movies: [ItunesElement]) in
            self?.movies = movies
            print("movie", self?.movies![0])
            self?.updateTableView()
        }
        
        self.model.getMovies(term: term, callback: callbackMovies, failback: failback)
    }
    
    @IBAction func tapView(_ sender: Any) {
        self.hideKeyboard()
    }
    
}

extension StartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.musics?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ElementCell", for: indexPath)
        
        let element = self.musics![indexPath.row]
        cell.textLabel?.text = element.trackName
        cell.detailTextLabel?.text = element.artistName
        return cell
    }
}

extension StartViewController: UITableViewDelegate {
    
}

