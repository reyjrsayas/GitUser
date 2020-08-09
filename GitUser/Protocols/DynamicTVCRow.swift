//
//  DynamicTVCRow.swift
//  GitUser
//
//  Created by Ray Sayas on 8/9/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

protocol DynamicTVCRow {
    func getCellFor(_ tableView:UITableView, indexPath: IndexPath) -> UITableViewCell
    func selectRow()
}

extension DynamicTVCRow {
    func selectRow() {
        
    }
}
