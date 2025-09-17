//
//  ReportView.swift
//  Skyliner
//
//  Created by Rayan Waked on 9/15/25.
//

import SwiftUI

// MARK: - REPORT SHEET
struct ReportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    
    @State private var selectedReason: ReportReason = .spam
    @State private var additionalContext: String = ""
    @State private var isSubmitting = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Why are you reporting this?")
                        .font(.headline)
                    
                    // MARK: - REASON SELECTION
                    LazyVStack(spacing: 8) {
                        ForEach(Array(ReportReason.allCases.enumerated()), id: \.offset) { index, reason in
                            Button {
                                selectedReason = reason
                                hapticFeedback(.success)
                            } label: {
                                HStack {
                                    Image(systemName: selectedReason == reason ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(selectedReason == reason ? .blue : .gray)
                                    
                                    Text(reason.displayName)
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // MARK: - ADDITIONAL CONTEXT
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional details (optional)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    TextField("Provide more context about this report...", text: $additionalContext, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
                
                Spacer()
                
                // MARK: - SUBMIT BUTTON
                Button {
                    Task {
                        await submitReport()
                    }
                } label: {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .controlSize(.small)
                        }
                        Text(isSubmitting ? "Submitting..." : "Submit Report")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isSubmitting)
            }
            .padding()
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - SUBMIT REPORT
    private func submitReport() async {
        isSubmitting = true
        
        do {
            let context = additionalContext.isEmpty ? nil : additionalContext
            
            try await appState.postManager
                .reportPost(
                    postID: routerCoordinator.reportID,
                    reason: selectedReason,
                    additionalContext: context
                )
            
            hapticFeedback(.success)
            dismiss()
            
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        
        isSubmitting = false
    }
}

// MARK: - HAPTIC FEEDBACK HELPER
private func hapticFeedback(_ type: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: type)
    generator.impactOccurred()
}
