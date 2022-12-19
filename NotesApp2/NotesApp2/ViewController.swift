//
//  ViewController.swift
//  NotesApp2
//
//  Created by Илья Казначеев on 01.12.2022.
//

import UIKit
import PhotosUI
import SwiftUI

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var imageData = ImageData()
    let formatter = DateFormatter()
    
    public let tableView: UITableView = .init(frame: .zero, style: .insetGrouped)
    let reuseIdentifier = "cell"
    
    private var notes: [ImageNote] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    
        formatter.timeStyle = .short
        formatter.dateStyle = .full
        
        tableView.reloadData()
        
        setup()
    }
    
    private func setup() {
        // UserDefaults.standard.removeObject(forKey: "notes")
        notes = imageData.imageNotes
        
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
        title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createTapped))
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.reuseIdentifier)
        
        tableView.dataSource = self
        tableView.reloadData()
        tableView.delegate = self
    }
    
    @objc func createTapped() {
        let imageNoteViewController = ImageNoteViewController()
        imageNoteViewController.delegate = self
        imageNoteViewController.editing_or_creating = false
        navigationController?.pushViewController(imageNoteViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)
        var content = UIListContentConfiguration.valueCell()
        let note = notes[indexPath.item]
        
        let title = note.content.components(separatedBy: CharacterSet.newlines)[0]
        let date = formatter.string(from: note.date)
        
        content.text = title
        content.textProperties.numberOfLines = 1
        content.textProperties.font = .boldSystemFont(ofSize: 16)
        
        content.secondaryText = date
        content.secondaryTextProperties.numberOfLines = 1
        content.secondaryTextProperties.font = .systemFont(ofSize: 14)
        content.secondaryTextProperties.color = .systemGray
        
        cell.accessoryView = UIImageView(image: UIImage(data: note.image!))
        cell.accessoryView?.frame.size = CGSize(width: 40, height: 40)
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let imageNoteViewController = ImageNoteViewController()
        imageNoteViewController.setNote(note: notes[indexPath.item])
        imageNoteViewController.delegate = self
        imageNoteViewController.editing_or_creating = true
        navigationController?.pushViewController(imageNoteViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        imageData.removeNote(id: notes[indexPath.item].id)
        notes = imageData.imageNotes.sorted(by: { $0.date > $1.date} )
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

}

extension ViewController: CreateNoteDelegate{
    func saveNote() {
        imageData = ImageData()
        notes = imageData.imageNotes.sorted(by: { $0.date > $1.date} )
        tableView.reloadData()
    }
}
