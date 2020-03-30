//
//  StudyPage.swift
//  Studier
//
//  Created by Tyler Goodman on 3/22/20.
//  Copyright © 2020 Tyler Goodman. All rights reserved.
//

import SwiftUI
import RealmSwift

class StudySettings: ObservableObject {
    @Published var bgColor = Color(red: 63 / 255, green: 202 / 255, blue: 254 / 255)
    @Published var progressValue: Float = 0.0
    @Published var userSize: Float = 0
    @Published var helperText = " "
}

struct FlashCard: Hashable, CustomStringConvertible {
    var id: Int
    let question: String
    let answer: String
    
    var description: String {
        return "\(question), id: \(id)"
    }
}

struct FlashCardPage: View {
    
    
    init(flashCards: [flashCardRealm], sectionName: String, deckName: String){
        self.sectionName = sectionName
        self.deckName = deckName
        self.deckAmount = flashCards.count
        var flashCardslocal: [FlashCard] = []
        for x in (0...flashCards.count - 1){
            flashCardslocal.append(FlashCard(id: x, question: flashCards[x].question!, answer: flashCards[x].answer!))
        }
        if(flashCardslocal.count > 1){
            _buffer = State(initialValue: flashCardslocal)
            
        }
        else{
            _buffer = State(initialValue: [])
        }
        
        let initial: [FlashCard] = [flashCardslocal[0]]
        _flashCardsz = State(initialValue: initial)
    }
    @State var buffer: [FlashCard]
    @State var flashCardsz: [FlashCard]
    @State var correctDeck: [FlashCard] = []
    @State var incorrectDeck: [FlashCard] = []
    @State var currentCard: Int = 0
    var deckAmount: Int
    var sectionName: String
    var deckName: String
    @EnvironmentObject var settings: StudySettings
    @EnvironmentObject var viewRouter: ViewRouter
    
    func updateRealm() -> Void {
        let realm = try! Realm()
        let section = realm.objects(SectionRealm.self).filter("sectionName = %@", self.sectionName)
        let currentSection = section[0]
        
        let index = currentSection.decks.firstIndex(where: {$0.deckName == self.deckName})
        if(index != nil){
            let currentDeck = currentSection.decks[index!]
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "MM-dd-yy"
            let formattedDate = format.string(from: date)
            
            try! realm.write{
                currentDeck.lastStudied = formattedDate
            }
        }
    }
    
    var body: some View {
        ZStack{
            settings.bgColor.edgesIgnoringSafeArea(.all).animation(.linear)
            VStack{
                GeometryReader{ geometry in
                    HStack{
                        if(!self.flashCardsz.isEmpty){
                            Button(action: {
                                self.viewRouter.currentPage = "home"
                            }){
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                
                            }
                            .offset(x: 15 ,y: geometry.size.height*1.4)
                        }
                        Spacer()
                        Text("\(self.settings.helperText)")
                            .foregroundColor(Color.white)
                            .fontWeight(.heavy)
                            .font(.largeTitle)
                            .offset(y: geometry.size.height*1)
                        Spacer()
                        
                    }
                    
                }
                .fixedSize(horizontal: false, vertical: true)
                
                ZStack{
                    if(self.flashCardsz.count > 0){
                        
                        ForEach(self.flashCardsz, id: \.self){ user in
                            CardView(user: user, onRemove: { removedUser, result in
                                let index = self.flashCardsz.firstIndex(where: {$0.id == removedUser.id})!
                                if(result == true){
                                    self.correctDeck.append(self.flashCardsz[index])
                                } else {
                                    self.incorrectDeck.append(self.flashCardsz[index])
                                }
                                
                                if(!self.buffer.isEmpty){
                                    self.buffer.removeFirst()
                                    if(!self.buffer.isEmpty){
                                        self.flashCardsz.append(self.buffer[0])
                                    }
                                }
                                
                                self.flashCardsz.remove(at: index)
                            }, stackAmount: Float(self.buffer.count))
                                .frame(height: 550).padding()
                                .shadow(radius: 5)
                            
                        }
                        
                    } else {
                        if(self.incorrectDeck.count > 0){
                            VStack{
                                Text("Review \(self.incorrectDeck.count) flash cards?")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.white)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 30))
                                    .lineLimit(10)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding()
                                    .animation(.easeIn)
                                HStack{
                                    Button(action: {
                                        //do something.
                                        self.settings.progressValue = 0.0
                                        self.incorrectDeck.reverse()
                                        self.buffer = self.incorrectDeck
                                        self.flashCardsz = [self.buffer[0]]
                                        self.incorrectDeck = []
                                    }){
                                        Image(systemName: "arrow.clockwise")
                                            .foregroundColor(Color.white)
                                            .font(.system(size: 50))
                                            .padding()
                                            .padding(.horizontal)
                                    }
                                    
                                    Button(action: {
                                        //do something to save the timestamp into realm
                                        self.updateRealm()
                                        self.settings.progressValue = 0.0
                                        self.viewRouter.currentPage = "home"
                                    }){
                                        Image(systemName: "xmark")
                                            .foregroundColor(Color.white)
                                            .font(.system(size: 50))
                                            .padding()
                                            .padding(.horizontal)
                                    }
                                }
                                
                            }
                        } else {
                            VStack {
                                Text("All good! Would you like to study this deck again?")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.white)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 30))
                                    .lineLimit(10)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding()
                                    .animation(.easeIn)
                                HStack{
                                    Button(action: {
                                        self.settings.progressValue = 0.0
                                        self.correctDeck.reverse()
                                        self.buffer = self.correctDeck
                                        self.flashCardsz = [self.buffer[0]]
                                        self.correctDeck = []
                                    }){
                                        Image(systemName: "arrow.clockwise")
                                            .foregroundColor(Color.white)
                                            .font(.system(size: 50))
                                            .padding()
                                            .padding(.horizontal)
                                    }
                                    
                                    Button(action: {
                                        //do something to save the timestamp into realm
                                        self.updateRealm()
                                        self.settings.progressValue = 0.0
                                        self.viewRouter.currentPage = "home"
                                    }){
                                        Image(systemName: "xmark")
                                            .foregroundColor(Color.white)
                                            .font(.system(size: 50))
                                            .padding()
                                            .padding(.horizontal)
                                        
                                    }
                                }
                                
                                
                            }
                        }
                    }
                    
                }.animation(.easeIn(duration: 0.5))
                if(self.flashCardsz.count > 0){
                    ProgressBar(value: $settings.progressValue).frame(height: 20).padding()
                }
                
            }
        }
        .onAppear(){
            let realm = try! Realm()
            
            let section = realm.objects(SectionRealm.self)
            var delete: [SectionRealm] = []
            
            for item in section {
                if(item.decks.count == 0){
                    delete.append(item)
                }
            }
            
            try! realm.write{
                realm.delete(delete)
            }
    }
    }
}


// MARK: PROGRESS BAR
struct ProgressBar: View {
    @Binding var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.black))
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(red: 209 / 255, green: 243 / 255, blue: 219 / 255))
                    .animation(.linear)
            }.cornerRadius(50.0)
        }
    }
}

// MARK: Card View

struct CardView: View {
    
    init(user: FlashCard, onRemove: @escaping (_ user: FlashCard, _ result: Bool) -> Void, stackAmount: Float){
        self.question = user.question
        self.answer = user.answer
        self.user = user
        self.onRemove = onRemove
        self.stackAmount = stackAmount
        self.cardText = user.question
    }
    
    
    private var user: FlashCard
    private var onRemove: (_ user: FlashCard, _ result: Bool) -> Void
    private var stackAmount: Float
    
    @State private var translation: CGSize = .zero
    @State private var flipped = false
    @State private var cardText: String = ""
    @EnvironmentObject  var settings: StudySettings
    var negativeColor = Color(red: 255 / 255, green: 123 / 255, blue: 82 / 255)
    var positiveColor = Color(red: 114 / 255, green: 222 / 255, blue: 123 / 255)
    var neutralColor = Color(red: 63 / 255, green: 202 / 255, blue: 254 / 255)
    
    private func getGesturePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }
    
    var question: String
    var answer: String
    
    var body: some View {
        // 1
        GeometryReader { geometry in
            
            // 2
            VStack(alignment: .leading) {
                Text("\(self.cardText)")
                    .onAppear{
                        self.cardText = self.question
                }
                .animation(.easeIn(duration: 0.5))
                .rotation3DEffect(self.flipped ? Angle(degrees: 180): Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
            }
            .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
            .clipped()
                // Add padding, corner radius and shadow with blur radius
                .padding(.bottom)
                .background(Color("createCard"))
                .cornerRadius(10)
                .offset(x: self.translation.width, y: self.translation.height)
                .rotationEffect(.degrees(Double(self.translation.width / geometry.size.width) * 25), anchor: .bottom)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            self.translation = value.translation
                            if(!self.flipped){
                                if (self.getGesturePercentage(geometry, from: value)) > 0.5 {
                                    if(self.settings.bgColor != self.positiveColor){
                                        self.settings.bgColor = self.positiveColor
                                        self.settings.helperText = "I got it!"
                                    }
                                    
                                } else if (self.getGesturePercentage(geometry, from: value)) < -0.5 {
                                    //do something for negative interaction.
                                    if(self.settings.bgColor != self.negativeColor){
                                        self.settings.bgColor = self.negativeColor
                                        self.settings.helperText = "Need to review"
                                    }
                                } else {
                                    if(self.settings.bgColor != self.neutralColor){
                                        self.settings.bgColor = self.neutralColor
                                        self.settings.helperText = " "
                                    }
                                }
                            } else {
                                if (self.getGesturePercentage(geometry, from: value)) > 0.5 {

                                    if(self.settings.bgColor != self.negativeColor){
                                        self.settings.bgColor = self.negativeColor
                                        self.settings.helperText = "Need to review"
                                    }
                                    
                                } else if (self.getGesturePercentage(geometry, from: value)) < -0.5 {
                                        if(self.settings.bgColor != self.positiveColor){
                                        self.settings.bgColor = self.positiveColor
                                        self.settings.helperText = "I got it!"
                                    }
                                } else {
                                    if(self.settings.bgColor != self.neutralColor){
                                        self.settings.bgColor = self.neutralColor
                                        self.settings.helperText = " "
                                    }
                                }
                            }
                    }
                    .onEnded { value in
                        
                        self.settings.bgColor = self.neutralColor
                        self.settings.helperText = " "
                        
                        if(self.getGesturePercentage(geometry, from: value)) < -0.5 {
                            self.translation = value.translation
                            self.flipped ? self.onRemove(self.user, true) : self.onRemove(self.user, false)
                            self.settings.progressValue += 1/self.stackAmount
                        } else if (self.getGesturePercentage(geometry, from: value)) > 0.5 {
                            self.translation = value.translation
                            self.flipped ? self.onRemove(self.user, false) : self.onRemove(self.user, true)
                            self.settings.progressValue += 1/self.stackAmount
                        } else {
                            self.translation = .zero
                        }
                    }
            )
                .rotation3DEffect(self.flipped ? Angle(degrees: 180): Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                .animation(.easeIn(duration: 0.5)) // implicitly applying animation
                .onTapGesture {
                    // explicitly apply animation on toggle (choose either or)
                    //withAnimation {
                    self.flipped.toggle()
                    if(self.flipped){
                        self.cardText = self.answer
                    } else {
                        self.cardText = self.question
                    }
            }
        }
    }
}
