//
//  UserDefaultSystem.swift
//  NotesApp2
//
//  Created by Илья Казначеев on 02.12.2022.
//

import Foundation

class Note: Codable {

    let date: Date
    let content: String
    var has_bold_title: Bool
    
    init() {
        self.date = Date()
        self.content = ""
        self.has_bold_title = true
    }
    
    init(date: Date, content: String, has_bold_title: Bool) {
        self.date = date
        self.content = content
        self.has_bold_title = has_bold_title
    }
    
    
    public static func addNote(note: Note) {
        var notes: [Note] = getNotes().sorted(by: { $0.date > $1.date} )
        notes.append(note)

        do {
            let encoder = JSONEncoder()

            let data = try encoder.encode(notes)

            UserDefaults.standard.set(data, forKey: "notes")

        } catch {
            print("Unable to Encode Array of Notes (\(error))")
        }
    }
    
    
    public static func getNotes() -> [Note]{
        if let data = UserDefaults.standard.data(forKey: "notes") {
            do {
                let decoder = JSONDecoder()
                let notes = try decoder.decode([Note].self, from: data)
                return notes
            } catch {
                print("Unable to Decode Notes (\(error))")
            }
        }
        return [Note]()
    }
    
    public static func remove(indexOfNote: Int) -> Bool{
        var notes: [Note] = getNotes().sorted(by: { $0.date > $1.date} )
        notes.remove(at: indexOfNote)
        do {
            let encoder = JSONEncoder()

            let data = try encoder.encode(notes)

            UserDefaults.standard.set(data, forKey: "notes")
            
            return true

        } catch {
            print("Unable to Encode Array of Notes (\(error))")
        }
        
        return false
        
    }

}
