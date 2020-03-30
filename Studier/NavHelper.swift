import Foundation
import Combine
import SwiftUI

class ViewRouter: ObservableObject {
    let objectWillChange = PassthroughSubject<ViewRouter, Never>()
    
    var currentCards: [flashCardRealm] = []
    var currentSection: String = ""
    var currentDeck: String = ""
    var currentPage: String = "home"{
        didSet{
            withAnimation(){
                objectWillChange.send(self)
            }
        }
    }
}
