//
//  StartViewController.swift
//  tunes
//
//  Created by Sergei Alexeev on 24.11.2020.
//

import UIKit
import SafariServices

final class StartViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var contentSwitch: UISegmentedControl!
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var labelNothingElements: UILabel!
    
    @IBOutlet var tapView: UITapGestureRecognizer!
    
    private var term: String = ""
    private let idCell = "ElementCell"
    
    private var model = ContentModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.configureTableView()
        self.loaderChange(animate: false)
        self.contentChange(hidden: true)
        self.labelNothingElements.isHidden = true
        
        
        self.tapView.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardChanged), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardChanged), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardChanged() -> Void {
        self.tapView.isEnabled = !self.tapView.isEnabled
    }
    
    private func configureTableView() -> Void {
        // убираем линии у неиспользуемых ячеек
        self.contentTableView.tableFooterView = UIView(frame: .zero)
        self.contentTableView.delegate = self
        self.contentTableView.dataSource = self
        
        self.contentTableView.register(UINib(nibName: "ContentTableViewCell", bundle: nil), forCellReuseIdentifier: self.idCell)
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
        
        self.term = input
        return input
    }
    
    private func updateTableView() -> Void {
        if (!self.model.ready()) {
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
        
        self.loaderChange(animate: true)
        self.hideKeyboard()
        self.contentChange(hidden: true)
        
        self.model.clear()
    
        
        let callbackMusics: () -> Void = { [weak self] in
            self?.updateTableView()
        }
        
        let failback = { [weak self] (error: String) in
            DispatchQueue.main.async {
                self?.loaderChange(animate: false)
                self?.contentChange(hidden: true)
                self?.renderError(text: error)
            }
        }
        
        self.model.fillMusics(term: term, callback: callbackMusics, failback: failback)
        
        let callbackMovies: () -> Void = { [weak self] in
            self?.updateTableView()
        }
        
        self.model.fillMovies(term: term, callback: callbackMovies, failback: failback)
    }
    
    @IBAction func changeTypeContent(_ sender: Any) {
        self.model.contentChange()
        self.contentTableView.reloadData()
        self.hideKeyboard()
    }
    @IBAction func clickView(_ sender: UITapGestureRecognizer) {
        self.hideKeyboard()
    }
}

extension StartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let size = self.model.size()
        self.labelNothingElements.isHidden = !(size == 0) || (self.searchTextField.text == "")
        return size
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ElementCell", for: indexPath) as! ContentTableViewCell
        
        
        if let element = self.model.getElement(index: indexPath.row) {
            cell.titleLabel.text = element.trackName
            cell.subtitleLabel.text = element.artistName
            cell.loadImage(urlString: element.artworkUrl100)
        }

        return cell
    }
}

extension StartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.hideKeyboard()
        self.contentTableView.deselectRow(at: indexPath, animated: true)
        
        guard let element = self.model.getElement(index: indexPath.row) else {
            return
        }
        guard let url = URL(string: element.previewUrl) else {
            return
        }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {}
}
