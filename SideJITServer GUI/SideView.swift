import SwiftUI
import Network

struct SideView: View {
    @State private var port = false
    @State private var pair = false
    @State private var customPort: String = "8080" // Porta predefinita
    @State private var showAlert = false // Flag per mostrare l'avviso
    
    var body: some View {
        VStack {
            Text("SideJITServer GUI")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Group {
                HStack {
                    VStack {
                        Toggle(isOn: $port) {
                            Text("Custom Port")
                        }
                        TextField("Port", text: $customPort)
                            .padding()
                            .disableAutocorrection(true)
                            .disabled(!port)
                    }
                    .padding()
                }
                
                HStack {
                    Button("Run SideJITServer") {
                        runSideJITServer()
                    }
                    Toggle(isOn: $pair) {
                        Text("Pair Mode")
                    }
                }
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Invalid Port"), message: Text("You can't use letters or symbols for the port."), dismissButton: .default(Text("OK")))
        }
    }
    
    // Funzione per eseguire il comando del server con la porta personalizzata
    func runSideJITServer() {
        // Controlla se la porta contiene solo numeri SOLO se "Custom Port" è selezionato
        if port && !customPort.allSatisfy({ $0.isNumber }) {
            showAlert = true // Mostra l'avviso se la porta contiene lettere o simboli
            return
        }
        
        var command = "SideJITServer"
        
        // Aggiungi l'opzione --pair se Pair Mode è abilitato
        if pair {
            command += " --pair"
        }
        
        // Aggiungi l'opzione --port se Custom Port è abilitato
        if port {
            command += " --port \(customPort)"
        }
        
        // Esegui il comando in una sessione del terminale che carica il profilo zsh
        runInTerminal(command: command)
    }
    
    // Funzione per eseguire il comando in una sessione di terminale Zsh
    func runInTerminal(command: String) {
        let task = Process()
        let zshPath = "/bin/zsh"
        task.launchPath = zshPath
        task.arguments = ["-i", "-c", command]
        
        // Redirige l'output (facoltativo, per debugging)
        let pipe = Pipe()
        task.standardOutput = pipe
        let fileHandle = pipe.fileHandleForReading
        
        task.launch()
        fileHandle.readInBackgroundAndNotify()
    }
}

#Preview {
    ContentView()
}
