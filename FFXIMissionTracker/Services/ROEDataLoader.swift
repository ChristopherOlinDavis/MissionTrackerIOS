//
//  ROEDataLoader.swift
//  FFXIMissionTracker
//
//  Created by Chris Davis on 1/1/26.
//

import Foundation

@Observable
class ROEDataLoader {
    private(set) var roeResponse: ROEResponse?
    private(set) var categoryGroups: [ROECategoryGroup] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    init() {
        loadROEData()
    }

    func loadROEData() {
        isLoading = true
        error = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                // Load the JSON file
                guard let url = Bundle.main.url(forResource: "roe-objectives", withExtension: "json") else {
                    throw NSError(domain: "ROEDataLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find roe-objectives.json"])
                }

                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let response = try decoder.decode(ROEResponse.self, from: data)

                // Group objectives by category and subcategory
                let groups = self.groupObjectives(response)

                DispatchQueue.main.async {
                    self.roeResponse = response
                    self.categoryGroups = groups
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error
                    self.isLoading = false
                    print("Error loading ROE data: \(error)")
                }
            }
        }
    }

    private func groupObjectives(_ response: ROEResponse) -> [ROECategoryGroup] {
        var groups: [ROECategoryGroup] = []

        for categoryInfo in response.categories {
            var subcategoryGroups: [ROESubcategoryGroup] = []

            for subcategoryName in categoryInfo.subcategories {
                let objectives = response.objectives.filter {
                    $0.category == categoryInfo.name && $0.subcategory == subcategoryName
                }

                if !objectives.isEmpty {
                    subcategoryGroups.append(ROESubcategoryGroup(
                        name: subcategoryName,
                        categoryName: categoryInfo.name,
                        objectives: objectives
                    ))
                }
            }

            // Also check for objectives with empty subcategory
            let noSubcategoryObjectives = response.objectives.filter {
                $0.category == categoryInfo.name && $0.subcategory.isEmpty
            }

            if !noSubcategoryObjectives.isEmpty {
                subcategoryGroups.append(ROESubcategoryGroup(
                    name: "General",
                    categoryName: categoryInfo.name,
                    objectives: noSubcategoryObjectives
                ))
            }

            if !subcategoryGroups.isEmpty {
                groups.append(ROECategoryGroup(
                    name: categoryInfo.name,
                    subcategories: subcategoryGroups
                ))
            }
        }

        return groups
    }

    func objectives(in subcategory: ROESubcategoryGroup) -> [ROEObjective] {
        subcategory.objectives
    }

    func allObjectives() -> [ROEObjective] {
        roeResponse?.objectives ?? []
    }

    func totalObjectivesCount() -> Int {
        roeResponse?.stats.totalObjectives ?? 0
    }
}
