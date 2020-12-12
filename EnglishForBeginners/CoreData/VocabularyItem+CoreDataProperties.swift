//
//  VocabularyItem+CoreDataProperties.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 01/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//
//

import Foundation
import CoreData


extension VocabularyItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VocabularyItem> {
        return NSFetchRequest<VocabularyItem>(entityName: "VocabularyItem")
    }

    @NSManaged public var id: String?
    @NSManaged public var transcription: String?
    @NSManaged public var word: String?
    @NSManaged public var imageName: String?
    @NSManaged public var nativeWord: NativeWord?

}
