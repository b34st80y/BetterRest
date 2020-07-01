//
//  ContentView.swift
//  BetterRest
//
//  Created by Adam Ghaffarian on 7/1/20.
//  Copyright © 2020 Adam Ghaffarian. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount: Double = 8
    @State private var coffeeCount: Int = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("When do you want to wake up?")
                    .font(.headline)
                    .lineLimit(nil)
                
                DatePicker("Date", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Text("Desired Amount of Sleep")
                    .font(.headline)
                    .lineLimit(nil)
                
                Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                    Text("\(sleepAmount, specifier: "%g") hours")
                }.padding(.bottom)
                
                Text("Daily Cofee Intake")
                    .font(.headline)
                    .lineLimit(nil)
                
                Stepper(value: $coffeeCount, in: 1...20, step: 1) {
                    if coffeeCount == 1 {
                        Text("1 Cup")
                    } else {
                        Text("\(coffeeCount) Cups")
                    }
                }
                Spacer()
            }
            .navigationBarTitle(Text("BetterRest"))
            .navigationBarItems(trailing: Button(action: calculateBedtime){
                Text("Calculate Bedtime!")
            })
            .padding()
            .alert(isPresented: $showingAlert) {
                alertBox()
            }
        }
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    fileprivate func alertBox() -> Alert {
        return Alert(title: Text(alertTitle),
                     message: Text(alertMessage),
                     dismissButton: .default(Text("OK")))
    }
    
    func calculateBedtime() {
        let model = SleepCalculator()
        
        do {
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(coffee: Double(coffeeCount), estimatedSleep: sleepAmount, wake: Double(hour + minute))
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bedtime is..."
            
        } catch{
            alertTitle = "Error"
            alertMessage = "There was a problem calculating bedtime..."
        }
        showingAlert = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
