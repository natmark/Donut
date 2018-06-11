//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#if os(iOS)
import UIKit
#elseif os(OSX)
import Cocoa
#endif

class ___FILEBASENAMEASIDENTIFIER___: Donut {
    let name: String {
        return "Chocolate"
    }

    let cost: Float {
        return 1.25
    }

    let ingredients: [String: Any] = {
        return [
            "all purpose flour":  "1 cup",
            "baking powder": "1tsp",
        ]
    }
}
