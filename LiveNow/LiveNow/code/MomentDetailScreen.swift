//
//  MomentDetailScreen.swift
//  LiveNow
//
//  Created by Maja on 24. 4. 2026.
//

import SwiftUI

// MARK: - MOMENT DETAIL

struct MomentDetailScreen: View {
    @ObservedObject var vm: AppViewModel
    let entry: ThoughtEntry
    let orange: Color
    let lightOrange: Color
    var onClose: () -> Void
    
    @State private var noteText: String = ""
    @State private var showDeleteConfirmation: Bool = false
    
    private var currentEntry: ThoughtEntry {
        vm.entries.first(where: { $0.id == entry.id }) ?? entry
    }
    
    @ScaledMetric private var iconCircleSize: CGFloat = 110
    @ScaledMetric private var titleSize: CGFloat = 22
    @ScaledMetric private var bodySize: CGFloat = 14
    @ScaledMetric private var cardRadius: CGFloat = 16
    @ScaledMetric private var impactIconSize: CGFloat = 28
    
    var body: some View {
        return ZStack {
            Color(red: 0.97, green: 0.96, blue: 0.94)
                .ignoresSafeArea()
            
            GeometryReader { geo in
                let horizontalPadding = min(geo.size.width * 0.055, 24)
                let topPadding = min(geo.size.height * 0.025, 22)
                let circleSize = min(iconCircleSize, geo.size.width * 0.30)
                
                VStack(spacing: 0) {
                    HStack {
                        Button(action: onClose) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, topPadding)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [lightOrange, orange],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: circleSize, height: circleSize)
                                
                                Image(systemName: entry.selectedActionIcon ?? "sparkles")
                                    .font(.system(size: circleSize * 0.34, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 6) {
                                Text(formattedDate(currentEntry.date))
                                    .font(.system(size: bodySize))
                                    .foregroundColor(.gray)
                                
                                Text(currentEntry.selectedActionLabel ?? "moment")
                                    .font(.system(size: titleSize, weight: .semibold))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Your thought")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text(entry.thought)
                                    .font(.system(size: 17))
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.72))
                            .cornerRadius(22)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Analysis")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                                
                                ForEach(Array(entry.ai.analysis.prefix(3).enumerated()), id: \.offset) { index, item in
                                    HStack(alignment: .top, spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(orange.opacity(0.14))
                                                .frame(width: 42, height: 42)
                                            
                                            Image(systemName: analysisIcon(for: index))
                                                .font(.system(size: 18, weight: .medium))
                                                .foregroundColor(orange)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(item.label)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.black)
                                            
                                            Text(item.sub)
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.72))
                            .cornerRadius(22)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Chosen reframe")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text(entry.selectedReframe ?? "No reframe saved")
                                    .font(.system(size: 17))
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.72))
                            .cornerRadius(22)
                            
                            VStack(alignment: .leading, spacing: 14) {
                                Text("did this actually happen?")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                HStack(spacing: 12) {
                                    OutcomeButton(title: "no", selected: currentEntry.didHappen == .no, color: .green) {
                                        vm.updateOutcome(for: entry.id, outcome: .no)
                                    }
                                    
                                    OutcomeButton(title: "maybe", selected: currentEntry.didHappen == .maybe, color: .orange) {
                                        vm.updateOutcome(for: entry.id, outcome: .maybe)
                                    }
                                    
                                    OutcomeButton(title: "yes", selected: currentEntry.didHappen == .yes, color: .red) {
                                        vm.updateOutcome(for: entry.id, outcome: .yes)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(cardRadius)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Note")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                ZStack(alignment: .topLeading) {
                                    if noteText.isEmpty {
                                        Text("what did you learn from this?")
                                            .foregroundColor(.gray)
                                            .padding(.top, 20)
                                            .padding(.leading, 16)
                                    }
                                    
                                    TextEditor(text: $noteText)
                                        .padding(12)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.clear)
                                }
                                .frame(minHeight: 110)
                                .background(Color.white)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                                )
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                            
                            Button(action: {
                                showDeleteConfirmation = true
                            }) {
                                Text("delete reset")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(14)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, 22)
                        .padding(.bottom, 28)
                    }
                }
            }
            .onAppear {
                noteText = entry.note ?? ""
            }
            .onChange(of: noteText) {
                vm.updateNote(for: entry.id, note: noteText)
            }
            .alert("Delete reset?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                
                Button("Delete", role: .destructive) {
                    vm.deleteEntry(entry.id)
                    onClose()
                }
            } message: {
                Text("This reset will be permanently deleted.")
            }
        }
    }
    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy • h:mm a"
        return f.string(from: date)
    }
    private func analysisIcon(for index: Int) -> String {
        switch index {
        case 0:
            return "magnifyingglass"
        case 1:
            return "brain.head.profile"
        case 2:
            return "heart"
        default:
            return "sparkles"
        }
    }
}

struct ImpactRow: View {
        let text: String
        let iconSize: CGFloat
        
        var body: some View {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: iconSize, height: iconSize)
                    .overlay(
                        Image(systemName: "bolt.fill")
                            .font(.system(size: iconSize * 0.43))
                            .foregroundColor(.orange)
                    )
                
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }


