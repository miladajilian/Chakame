//
//  Font.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import SwiftUI

/// Vazirmatn at the system text style sizes. `relativeTo:` makes it follow Dynamic Type
/// live, like the system font does.
public extension Font {
    static var customBody: Font {
        Font.custom("Vazirmatn-Regular", size: 17, relativeTo: .body)
    }

    static var customcaption1: Font {
        Font.custom("Vazirmatn-Regular", size: 12, relativeTo: .caption)
    }

    static var customTitle3: Font {
        Font.custom("Vazirmatn-Regular", size: 20, relativeTo: .title3)
    }
}
