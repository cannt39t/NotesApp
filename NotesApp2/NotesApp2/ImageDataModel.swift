//
//  ImageDataModel.swift
//  NotesApp2
//
//  Created by Илья Казначеев on 08.12.2022.
//

import Foundation
import UIKit

struct ImageNote : Codable, Hashable, Identifiable {
    var id = UUID()
    var image: Data?
    var date: Date
    var content: String
    var has_bold_title: Bool
    
    init() {
        self.date = Date()
        self.content = ""
        self.has_bold_title = true
        self.image = .init()
    }
    
    init(image: Data?, date: Date, content: String, has_bold_title: Bool){
        self.image = image!
        self.date = date
        self.content = content
        self.has_bold_title = has_bold_title
    }
}

class ImageData {
    private let IMAGES_KEY = "ImagesKey"
    var imageNotes: [ImageNote] {
        didSet {
            saveData()
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: IMAGES_KEY) {
            if let decodedNotes = try? JSONDecoder().decode([ImageNote].self, from: data) {
                imageNotes = decodedNotes
                return
            }
        }
        imageNotes = []
    }
    
    func addNote(image: UIImage?, content: String, has_bold_title: Bool) {
        if image == nil{
            let tempNote = ImageNote(image: .init(), date: Date(), content: content, has_bold_title: has_bold_title)
            imageNotes.insert(tempNote, at: 0)
            saveData()
        }
        else if let pngRepresantation = image!.pngData() {
            let tempNote = ImageNote(image: pngRepresantation, date: Date(), content: content, has_bold_title: has_bold_title)
            imageNotes.insert(tempNote, at: 0)
            saveData()
        }
    }
    
    func editNote(id: UUID, content: String, has_bold_title: Bool) {
        if let note = imageNotes.first(where: { $0.id == id }) {
            let index = imageNotes.firstIndex(of: note)
            
            imageNotes[index!].content = content
            imageNotes[index!].has_bold_title = has_bold_title
        }
    }
    
    private func saveData() {
        if let encodedNotes = try? JSONEncoder().encode(imageNotes) {
            UserDefaults.standard.set(encodedNotes, forKey: IMAGES_KEY)
        }
    }
    
    public func removeNote(id: UUID) {
        if let note = imageNotes.first(where: { $0.id == id }) {
            let index = imageNotes.firstIndex(of: note)
            imageNotes.remove(at: index!)
            saveData()
        }
    }
}

