//
//  ContentView.swift
//  Simple Study Flash Cards
//
//  Created by Tyler Goodman on 2/27/20.
//  Copyright © 2020 Tyler Goodman. All rights reserved.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    @EnvironmentObject var selection: Selector
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View{
        VStack{
            if(viewRouter.currentPage == "home"){
                HomePage()
            } else if viewRouter.currentPage == "study" {
                FlashCardPage(flashCards: viewRouter.currentCards, sectionName: viewRouter.currentSection, deckName: viewRouter.currentDeck).transition(.scale)
                
            } else if viewRouter.currentPage == "create" {
                CreateDeckPage()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


