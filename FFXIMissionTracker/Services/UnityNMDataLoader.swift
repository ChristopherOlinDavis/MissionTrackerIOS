//
//  UnityNMDataLoader.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 1/1/26.
//

import Foundation

@Observable
class UnityNMDataLoader {
    private(set) var unmResponse: UnityNMResponse?
    private(set) var categoryGroups: [UNMCategoryGroup] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    init() {
        loadUnityNMData()
    }

    func loadUnityNMData() {
        isLoading = true
        error = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                // Load the JSON file
                guard let url = Bundle.main.url(forResource: "unity-nms", withExtension: "json") else {
                    throw NSError(domain: "UnityNMDataLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find unity-nms.json"])
                }

                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let response = try decoder.decode(UnityNMResponse.self, from: data)

                // Group NMs by category
                let groups = self.groupNMs(response)

                DispatchQueue.main.async {
                    self.unmResponse = response
                    self.categoryGroups = groups
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error
                    self.isLoading = false
                    print("Error loading Unity NM data: \(error)")
                }
            }
        }
    }

    private func groupNMs(_ response: UnityNMResponse) -> [UNMCategoryGroup] {
        var groups: [UNMCategoryGroup] = []

        // Group by category
        let categorizedNMs = Dictionary(grouping: response.unityNotoriousMonsters, by: { $0.category })

        // Create groups for each category in order
        for category in response.metadata.categories {
            if let nms = categorizedNMs[category], !nms.isEmpty {
                // Sort by level, then by name
                let sortedNMs = nms.sorted { first, second in
                    if first.level != second.level {
                        return first.level < second.level
                    }
                    return first.nm < second.nm
                }

                groups.append(UNMCategoryGroup(
                    name: category,
                    nms: sortedNMs
                ))
            }
        }

        return groups
    }

    func allNMs() -> [UnityNotoriousMonster] {
        unmResponse?.unityNotoriousMonsters ?? []
    }

    func totalNMsCount() -> Int {
        unmResponse?.metadata.totalCount ?? 0
    }

    func nms(in category: String) -> [UnityNotoriousMonster] {
        categoryGroups.first { $0.name == category }?.nms ?? []
    }
}
