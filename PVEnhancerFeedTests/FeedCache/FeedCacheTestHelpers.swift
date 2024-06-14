//
//  FeedCacheTestHelpers.swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 13/06/2024.
//


import Foundation
import PVEnhancerFeed


func uniqueIrradiancesFeed() -> (model: IrradiancesFeed, local: LocalIrradiancesFeed) {
       let modelIrradiances = IrradiancesFeed(
           geometry: Geometry(
               coordinates: [-3.88, 42.63, 917.61]),
           properties: Properties(
               parameter: Parameter(
                   allskySfcSwDni: [
                       "JAN": 2.38,
                       "FEB": 3.1,
                       "MAR": 3.77,
                       "APR": 4.12,
                       "MAY": 4.94,
                       "JUN": 5.85,
                       "JUL": 6.97,
                       "AUG": 6.31,
                       "SEP": 5.28,
                       "OCT": 3.87,
                       "NOV": 2.62,
                       "DEC": 2.5,
                       "ANN": 4.32
                   ],
                   allskySfcSwDwn: [
                       "JAN": 1.61,
                       "FEB": 2.46,
                       "MAR": 3.73,
                       "APR": 4.87,
                       "MAY": 5.98,
                       "JUN": 6.71,
                       "JUL": 7.06,
                       "AUG": 6.17,
                       "SEP": 4.75,
                       "OCT": 3.1,
                       "NOV": 1.83,
                       "DEC": 1.48,
                       "ANN": 4.16
                   ],
                   allskySfcSwDiff: [
                       "JAN": 0.84,
                       "FEB": 1.2,
                       "MAR": 1.78,
                       "APR": 2.36,
                       "MAY": 2.71,
                       "JUN": 2.73,
                       "JUL": 2.38,
                       "AUG": 2.18,
                       "SEP": 1.82,
                       "OCT": 1.35,
                       "NOV": 0.93,
                       "DEC": 0.74,
                       "ANN": 1.75
                   ]
               )
           )
       )

       let localIrradiances = LocalIrradiancesFeed(
           geometry: Geometry(
               coordinates: [-3.88, 42.63, 917.61]),
           properties: Properties(
               parameter: Parameter(
                   allskySfcSwDni: [
                       "JAN": 2.38,
                       "FEB": 3.1,
                       "MAR": 3.77,
                       "APR": 4.12,
                       "MAY": 4.94,
                       "JUN": 5.85,
                       "JUL": 6.97,
                       "AUG": 6.31,
                       "SEP": 5.28,
                       "OCT": 3.87,
                       "NOV": 2.62,
                       "DEC": 2.5,
                       "ANN": 4.32
                   ],
                   allskySfcSwDwn: [
                       "JAN": 1.61,
                       "FEB": 2.46,
                       "MAR": 3.73,
                       "APR": 4.87,
                       "MAY": 5.98,
                       "JUN": 6.71,
                       "JUL": 7.06,
                       "AUG": 6.17,
                       "SEP": 4.75,
                       "OCT": 3.1,
                       "NOV": 1.83,
                       "DEC": 1.48,
                       "ANN": 4.16
                   ],
                   allskySfcSwDiff: [
                       "JAN": 0.84,
                       "FEB": 1.2,
                       "MAR": 1.78,
                       "APR": 2.36,
                       "MAY": 2.71,
                       "JUN": 2.73,
                       "JUL": 2.38,
                       "AUG": 2.18,
                       "SEP": 1.82,
                       "OCT": 1.35,
                       "NOV": 0.93,
                       "DEC": 0.74,
                       "ANN": 1.75
                   ]
               )
           )
       )

       return (modelIrradiances, localIrradiances)
   }


// MARK: - Extensions. Date.
extension Date {
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}


extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
