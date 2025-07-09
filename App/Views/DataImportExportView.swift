//
//  DataImportExportView.swift
//  IWNDWYT
//
//  Created by Claude Code on 1/9/25.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct DataImportExportView: View {
    @EnvironmentObject private var viewModel: DayCounterViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Export state
    @State private var exportPreview = ""
    
    // Import state
    @State private var showingImportPicker = false
    @State private var importPreview = ""
    @State private var importURL: URL?
    @State private var showingImportConfirmation = false
    
    // Alert state
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            .padding()
            
            Text("Data Management")
                .font(.title)
                .padding()
            
            if !exportPreview.isEmpty {
                Text(exportPreview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(spacing: 15) {
                Text("Export Section")
                    .font(.headline)
                
                Text("Create a backup of your streak data")
                    .font(.caption)
                
                Button {
                    performExport()
                } label: {
                    Text("Export Data")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Divider()
                
                Text("Import Section")
                    .font(.headline)
                
                Text("Restore from backup file")
                    .font(.caption)
                
                Button {
                    showingImportPicker = true
                } label: {
                    Text("Import Data")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            loadExportPreview()
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImportSelection(result)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .alert("Confirm Import", isPresented: $showingImportConfirmation) {
            Button("Cancel", role: .cancel) {
                importURL = nil
                importPreview = ""
            }
            Button("Import", role: .destructive) {
                performImport()
            }
        } message: {
            Text("\(importPreview)\n\nThis will replace your current data with the imported data. A backup will be created automatically.")
        }
    }
    
    private func loadExportPreview() {
        exportPreview = viewModel.getExportPreview()
    }
    
    private func performExport() {
        let result = viewModel.exportData()
        
        switch result {
        case .success(let url):
            presentActivityViewController(with: url)
            // No success alert - the share sheet appearance is confirmation enough
            
        case .failure(let error):
            alertTitle = "Export Failed"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
    private func presentActivityViewController(with url: URL) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                return
            }
            
            // Find the topmost presented view controller
            var topViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            // For iPad compatibility
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = topViewController.view
                popoverController.sourceRect = CGRect(x: topViewController.view.bounds.midX, y: topViewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            topViewController.present(activityViewController, animated: true)
        }
    }
    
    private func handleImportSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Start accessing the security-scoped resource
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            // Get import preview
            let previewResult = viewModel.getImportPreview(from: url)
            
            switch previewResult {
            case .success(let preview):
                importURL = url
                importPreview = preview
                showingImportConfirmation = true
                
            case .failure(let error):
                alertTitle = "Import Error"
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            
        case .failure(let error):
            alertTitle = "File Selection Error"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
    private func performImport() {
        guard let url = importURL else { return }
        
        // Start accessing the security-scoped resource again for the actual import
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        let result = viewModel.importData(from: url)
        
        switch result {
        case .success(let message):
            alertTitle = "Import Complete"
            alertMessage = message
            showingAlert = true
            
            // Clear import state
            importURL = nil
            importPreview = ""
            
            // Refresh export preview with new data
            loadExportPreview()
            
        case .failure(let error):
            alertTitle = "Import Failed"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
}


#Preview {
    DataImportExportView()
        .environmentObject(DayCounterViewModel.shared)
}