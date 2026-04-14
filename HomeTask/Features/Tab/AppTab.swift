//
//  AppTab.swift
//  HomeTask
//
//  Created by 어재선 on 4/7/26.
//

import Foundation

enum AppTab: String, CaseIterable, Hashable {
    case chore
    case shopping
    case settings
}

extension AppTab {
    var title: String {
        switch self {
        case .chore:    return "집안일"
        case .shopping: return "쇼핑"
        case .settings: return "설정"
        }
    }

    var icon: String {
        switch self {
        case .chore:    return "checklist"
        case .shopping: return "cart.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
