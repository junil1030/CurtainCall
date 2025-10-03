//
//  MainTabBarController.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAppearance()
        setupVC()
    }
    
    private func setupAppearance() {
        tabBar.backgroundColor = .white
        tabBar.tintColor = .ccTabSelected
        tabBar.unselectedItemTintColor = .ccTabUnselected
        tabBar.backgroundImage = UIImage()
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: UIFont.ccFootnote
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: UIFont.ccFootnoteBold
        ]
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func setupVC() {
        let homeVC = createHomeViewController()
        let statisticsVC = createStatisticsViewController()
        let moreVC = createMoreViewController()
        
        viewControllers = [homeVC, statisticsVC, moreVC]
    }
    
    private func createHomeViewController() -> UINavigationController {
        let repository = FavoriteRepository()
        let toggleFavoriteUseCase = ToggleFavoriteUseCase(repository: repository)
        let checkMultipleFavoriteStatusUseCase = CheckMultipleFavoriteStatusUseCase(repository: repository)
        let viewModel = HomeViewModel(
            toggleFavoriteUseCase: toggleFavoriteUseCase,
            checkMultipleFavoriteStatusUseCase: checkMultipleFavoriteStatusUseCase
        )
        
        let vc = HomeViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(
            title: CCStrings.Title.homeViewName,
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        nav.tabBarItem.tag = 0
        
        return nav
    }
    
    private func createStatisticsViewController() -> UINavigationController {
        let repository = ViewingRecordRepository()
        let fetchStatsUseCase = FetchStatsUseCase(repository: repository)
        let viewModel = StatsViewModel(useCase: fetchStatsUseCase)
        let statsViewController = StatsViewController(viewModel: viewModel)
        
        let nav = UINavigationController(rootViewController: statsViewController)
        nav.tabBarItem = UITabBarItem(
            title: CCStrings.Title.statisticsName,
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        nav.tabBarItem.tag = 1
        
        return nav
    }
    
    private func createMoreViewController() -> UINavigationController {
        let vc = MoreViewController()
        
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(
            title: CCStrings.Title.moreName,
            image: UIImage(systemName: "ellipsis.circle"),
            selectedImage: UIImage(systemName: "ellipsis.circle.fill")
        )
        nav.tabBarItem.tag = 2
        
        return nav
    }
}
