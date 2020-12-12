//
//  BaseManager.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 27/02/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BaseManager {
    
    static var defaultContext: NSManagedObjectContext {
        get {
            return NSManagedObjectContext.mr_default()
        }
    }
    
    static func dataFromAsset(with name: String) -> Data? {
        let asset = NSDataAsset(name: name.lowercased())
        return asset?.data
    }
}
