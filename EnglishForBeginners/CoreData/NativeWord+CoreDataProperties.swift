//
//  NativeWord+CoreDataProperties.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 01/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//
//

import Foundation
import CoreData


extension NativeWord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NativeWord> {
        return NSFetchRequest<NativeWord>(entityName: "NativeWord")
    }

    @NSManaged public var id: String?
    @NSManaged public var word: String?
    @NSManaged public var englishWord: VocabularyItem?

}
