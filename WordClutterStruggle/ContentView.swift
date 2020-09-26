//
//  ContentView.swift
//  WordClutterStruggle
//
//  Created by Jonathan Sweeney on 9/25/20.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingMessage = false
    
    @State private var score: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                Text("Score \(score)")
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(trailing: Button("New Word", action: {
                self.startGame()
            }))
            .onAppear(perform: { startGame() })
            .alert(isPresented: $showingMessage) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "Same Word", message: "Cannot use the same word silly.")
            return
        }
        
        guard isLong(word: answer) else {
            wordError(title: "No Short Words", message: "Someone needs to extend their vocabulary...")
            return
        }
        
        guard isOriginalWord(word: answer) else {
            wordError(title: "Word used already", message: "Use your head")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word is not Possible", message: "Use a dictionary fool.")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Fake Word Alert", message: "I can makeup word too!")
            return
        }
        
        score += score(word: answer)
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURl) {
                let allWords = startWords
                    .components(separatedBy: "\n")
                usedWords = []
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle")
    }
    
    func isOriginalWord(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isLong(word: String) -> Bool {
        return word.count >= 3
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingMessage = true
    }
    
    func score(word: String) -> Int {
        return word.count + usedWords.count
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
