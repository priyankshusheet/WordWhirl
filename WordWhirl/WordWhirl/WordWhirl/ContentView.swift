//
//  ContentView.swift
//  WordWhirl
//
//  Created by Priyankshu Sheet on 17/07/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    @State private var highscore = UserDefaults.standard.integer(forKey: "Highscore")
    @State private var showHint = false
    @State private var gradientOffset: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            FlowingGradient()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("WordWhirl")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                Text("  \(rootWord)  ")
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical)
                
                Text("Score: \(score)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                TextField("Enter your word", text: $newWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .onSubmit(addNewWord)
                
                List {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                                .foregroundColor(.yellow)
                                .shadow(radius: 5)
                            Text(word)
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.5).gradient)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .transition(.slide)
                        .animation(.spring, value: usedWords)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
                .padding(.horizontal, 20)
                
                Button ("Hint") {
                    showHint.toggle()
                }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
                .foregroundColor(.black)
                
                if showHint {
                    Text("Try to think of the words that are related to \(rootWord)!")
                }
                
                Text("High Score: \(highscore)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                }
            }
        
        .onAppear(perform: startGame)
               .alert(errorTitle, isPresented: $showingError) {
                   Button("OK", role: .cancel) { }
               } message: {
                   Text(errorMessage)
               }
        }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        score += answer.count
        if score > highscore {
            highscore = score
            UserDefaults.standard.set(highscore, forKey: "HighScore")
        }
        
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords.removeAll()
                score = 0
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    func isOriginal (word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            }
            else {
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "on")
        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct FlowingGradient: View {
    @State private var gradientOffset: CGFloat = -1.0

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.orange,
                Color.mint,
                Color.blue,
                Color.purple,
                Color.orange,
                Color.orange
            ]),
            startPoint: UnitPoint(x: 0.5, y: gradientOffset),
            endPoint: UnitPoint(x: 0.5, y: gradientOffset + 2)
        )
        .onAppear {
            withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                gradientOffset = 1.0
            }
        }
        .animation(.linear(duration: 24).repeatForever(autoreverses: false), value: gradientOffset)
    }
}




#Preview {
    ContentView()
}
