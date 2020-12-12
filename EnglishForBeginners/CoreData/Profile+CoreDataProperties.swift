//
//  Profile+CoreDataProperties.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 17/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//
//

import Foundation
import CoreData


extension Profile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Profile> {
        return NSFetchRequest<Profile>(entityName: "Profile")
    }

    @NSManaged public var experience: Int32
    @NSManaged public var starsInfo: [String: Int]?
    @NSManaged public var unsynchronisedExperience: Int32
    @NSManaged public var purchasedThemes: [String]?
}
