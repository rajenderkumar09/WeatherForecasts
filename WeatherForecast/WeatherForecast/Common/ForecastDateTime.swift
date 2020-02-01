//
//  Created by Jake Lin on 9/11/15.
//  Copyright © 2015 Jake Lin. All rights reserved.
//

import Foundation
import AFDateHelper


struct ForecastDateTime {
    let rawDate: Double

    init(date: Double) {
        self.rawDate = date
    }

	var date: Date {
        let date = Date(timeIntervalSince1970: rawDate)
		let dateString = date.toString(format: .custom("dd/MM/yyyy"))
		return Date(fromString: dateString, format: .custom("dd/MM/yyyy"))!
    }

    var shortTimeString: String {
        let date = Date(timeIntervalSince1970: rawDate)
		return date.toString(format: .custom("HH:mm"))
    }

	var dateTimeString: String {
        let date = Date(timeIntervalSince1970: rawDate)
		return date.toString(format: .custom("dd MMM, yyyy HH:mm"))
    }
}
