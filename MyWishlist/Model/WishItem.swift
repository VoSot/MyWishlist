//
//  WishItem.swift
//  MyWishlist
//
//  Created by Volha on 26.10.2022.
//

import Foundation
import RealmSwift

class WishItem: Object {
    @Persisted var title: String = ""
    @Persisted var link: String = ""
    @Persisted(originProperty: "items") var parentCategory: LinkingObjects<WishCategory>
    
}
