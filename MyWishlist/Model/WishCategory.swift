//
//  WishCategory.swift
//  MyWishlist
//
//  Created by Volha on 11.11.2022.
//

import Foundation
import RealmSwift

class WishCategory: Object {
    @Persisted var name: String = ""
    @Persisted var items: List<WishItem>
}
