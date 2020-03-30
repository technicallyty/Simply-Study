//
//  StudyRealm.swift
//  Simple Study Flash Cards
//
//  Created by Tyler Goodman on 3/7/20.
//  Copyright © 2020 Tyler Goodman. All rights reserved.
//

import Foundation
import RealmSwift

class SectionRealm: Object {
    @objc dynamic var sectionName: String?
    @objc dynamic var color: String?
    let decks = RealmSwift.List<DeckRealm>()
    
    override static func primaryKey() -> String? {
        return "sectionName"
    }
}

class DeckRealm: Object {
    @objc dynamic var sectionParent: SectionRealm?
    @objc dynamic var deckName: String?
    @objc dynamic var stackAmount = 0
    @objc dynamic var lastStudied: String?
    let flashCards = RealmSwift.List<flashCardRealm>()
}


class flashCardRealm: Object {
    @objc dynamic var question: String?
    @objc dynamic var answer: String?
    @objc dynamic var deckOnwer: DeckRealm?
}
