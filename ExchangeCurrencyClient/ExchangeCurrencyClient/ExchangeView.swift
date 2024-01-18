//
//  ExchangeView.swift
//  ExchangeCurrencyClient
//
//  Created by Anton Gubarenko on 17.01.2024.
//

import SwiftUI
import Combine

struct ExchangeView: View {
    
    @StateObject
    private var viewModel = CurrencyViewModel()
    
    @FocusState
    private var fromNumberInFocus: Bool
    
    @FocusState
    private var toNumberInFocus: Bool
    
    @State
    private var inputValue: String = "0"
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                   fromSection
                    toSection
                }
                .overlay {
                    if viewModel.isLoading {
                        VStack(spacing: 16.0) {
                            ProgressView()
                            Text("Loading rates...")
                        }
                    }
                }
                
                HStack {
                    Text("Rates by")
                    Link("exchangerates", destination: URL(string: Constants.API.infoURL)!)
                }
            }.navigationBarTitle("Exchange Currency")
        }
        .onAppear {
            inputValue = NumberFormatters.inputDigits.string(from: NSNumber(value: viewModel.fromValue)) ?? "0"
            viewModel.exchange()
        }
        .alert(viewModel.exchangeError ?? String(localized: "Error"),
               isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    /// Top source currency section
    private var fromSection: some View {
        Section("From") {
            HStack {
                TextField("", text: $inputValue)
                    .keyboardType(.decimalPad)
                    .focused($fromNumberInFocus)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            if fromNumberInFocus {
                                Button("Done") {
                                    fromNumberInFocus = false
                                }
                            }
                        }
                    }
                    .onChange(of: inputValue){
                        if inputValue.isEmpty {
                            viewModel.fromValue = 0.0
                        } else {
                            viewModel.fromValue = Double(inputValue) ?? 0.0
                        }
                    }
                Picker("", selection: $viewModel.fromCurrency) {
                    ForEach(Currency.allCases, id: \.self) {
                        Text($0.rawValue)
                            .tag(Optional($0))
                    }
                }
            }
        }
    }
    
    /// To currency section
    private var toSection: some View {
        Section {
            HStack {
                TextField("", value: $viewModel.toValue, formatter: NumberFormatters.twoFractionDigits)
                    .disabled(true)
                Picker("", selection: $viewModel.toCurrency) {
                    ForEach(Currency.allCases, id: \.self) {
                        Text($0.rawValue)
                            .tag(Optional($0))
                    }
                }
            }
        } header: {
            Text("To")
        } footer: {
            VStack {
                if viewModel.sameCurrencies {
                    Text("Same destination currency")
                        .foregroundStyle(Color.red)
                        .bold()
                }
            }
        }
    }
}

#Preview {
    ExchangeView()
}
