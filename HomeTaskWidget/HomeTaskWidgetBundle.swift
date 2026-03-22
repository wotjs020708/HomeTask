//
//  HomeTaskWidgetBundle.swift
//  HomeTaskWidget
//
//  Created by 어재선 on 3/19/26.
//

import WidgetKit
import SwiftUI

@main
struct HomeTaskWidgetBundle: WidgetBundle {
    var body: some Widget {
        HomeTaskWidget()
        HomeTaskWidgetControl()
        HomeTaskWidgetLiveActivity()
    }
}
