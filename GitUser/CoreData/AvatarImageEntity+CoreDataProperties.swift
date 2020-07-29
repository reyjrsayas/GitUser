//
//  AvatarImageEntity+CoreDataProperties.swift
//  GitUser
//
//  Created by Rey Sayas on 7/28/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//
//

import Foundation
import CoreData


extension AvatarImageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AvatarImageEntity> {
        return NSFetchRequest<AvatarImageEntity>(entityName: "AvatarImageEntity")
    }

    @NSManaged public var id: Double
    @NSManaged public var avatar: Data?

}
