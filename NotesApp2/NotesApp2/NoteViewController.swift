//
//  NoteViewController.swift
//  NotesApp2
//
//  Created by Илья Казначеев on 01.12.2022.
//

import UIKit
import PhotosUI

protocol CreateNoteDelegate: AnyObject {
    func saveNote()
}


class NoteViewController: UIViewController, UITextViewDelegate, PHPickerViewControllerDelegate {
    
    weak var delegate: CreateNoteDelegate?
    
    private let dateLabel = UILabel()
    private let contentText = UITextView()
    private var has_bold_title: Bool = false
    private var note = Note()
    private var item = 0
    private var editing_or_creating = false
    private var imageNote: UIImageView! = .init()
    
    public func setNote(note: Note, item: Int, editing_or_creating: Bool) {
        self.item = item
        self.note = note
        self.editing_or_creating = editing_or_creating
    }
    
    public func setImage(image: UIImage) {
        self.imageNote.image = image
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    private func setup() {
        
        contentText.delegate = self
        
        view.backgroundColor = .white
        
        navigationItem.largeTitleDisplayMode = .never
        
        // date
        
        dateLabel.textAlignment = .center
        dateLabel.numberOfLines = 1
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .systemGray

        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long

        dateLabel.text = formatter.string(from: note.date)
        
        // contentText
        
        if (note.has_bold_title && note.content.components(separatedBy: CharacterSet.newlines).count <= 1) {
            contentText.font = UIFont.boldSystemFont(ofSize: 28)
            contentText.text = note.content
        } else if (note.has_bold_title && note.content.components(separatedBy: CharacterSet.newlines).count > 1) {
            let title = note.content.components(separatedBy: CharacterSet.newlines)[0]
            if let i = note.content.firstIndex(of: "\n") {
                let start = note.content.index(i, offsetBy: 0)
                let end = note.content.index( note.content.endIndex, offsetBy: 0)
                let range = start..<end
                let mySubstring = note.content[range]

                let attributedText = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28)])

                attributedText.append(NSAttributedString(string: String(mySubstring), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]))

                contentText.attributedText = attributedText
                has_bold_title = true
            }
        } else {
            contentText.font = UIFont.systemFont(ofSize: 18)
            contentText.text = note.content
            has_bold_title = true
        }
        

        
        // stack
    
        let stackView = UIStackView(arrangedSubviews: [dateLabel, imageNote!, contentText])
        stackView.axis = .vertical
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        view.addSubview(stackView)
        
        if imageNote.image == nil{
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
                stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
                dateLabel.heightAnchor.constraint(equalToConstant: 14)
            ])
        } else {
            NSLayoutConstraint.activate([
                imageNote.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.33),
                stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
                stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
                dateLabel.heightAnchor.constraint(equalToConstant: 14)
            ])
        }
        

        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        let addPhoto = UIBarButtonItem(image: UIImage(systemName: "photo.on.rectangle.fill"), style: .plain, target: self, action: #selector(addPhotoTapped))
        
        navigationItem.rightBarButtonItems = [saveButton, addPhoto]
    }
    
    @objc func saveTapped() {
        let note = Note(date: note.date, content: contentText.attributedText.string, has_bold_title: note.has_bold_title)
        if contentText.hasText {
            saveNoteToUserDefaults(note: note)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func addPhotoTapped() {
        print("Choose photo")
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let phPicker = PHPickerViewController(configuration: configuration)
        phPicker.delegate = self
        self.present(phPicker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        results.forEach { result in
            print("Asset identifier: \(result.assetIdentifier ?? "none")")
            result.itemProvider.loadObject(ofClass: UIImage.self) {  reading, error in
                if let error {
                    print("Got error loading image: \(error)")
                } else if let image = reading as? UIImage {
                    DispatchQueue.main.async {
                        self.setImage(image: image)
                        NSLayoutConstraint.activate([
                            self.imageNote.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.33)
                        ])
                    }
                }
            }
        }

    }
    
    func textViewDidChange(_ textView: UITextView) {
        let str = contentText.text
        if ((str!.contains { $0.isNewline }) && !has_bold_title) {
            contentText.font = UIFont.systemFont(ofSize: 18)
            let attributedText = NSMutableAttributedString(string: contentText.text, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28)])
            contentText.attributedText = attributedText
            has_bold_title = true
        }
        if (!(str!.contains { $0.isNewline }) && has_bold_title && contentText.text == "") {
            contentText.font = UIFont.systemFont(ofSize: 18)
            self.note.has_bold_title = false
        }
    }
    
    private func saveNoteToUserDefaults(note: Note) {
        if (editing_or_creating) {
            _ = Note.remove(indexOfNote: item)
        }
        delegate?.saveNote()
    }

}
