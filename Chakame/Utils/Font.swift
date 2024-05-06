//
//  Font.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import Foundation
import SwiftUI

extension Font {
    public static var customBody: Font {
        return Font.custom("Vazirmatn-Regular", size: UIFont.preferredFont(forTextStyle: .body).pointSize)
    }
    public static var customcaption1: Font {
        return Font.custom("Vazirmatn-Regular", size: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
    }
    public static var customTitle3: Font {
        return Font.custom("Vazirmatn-Regular", size: UIFont.preferredFont(forTextStyle: .title3).pointSize)
    }
}
