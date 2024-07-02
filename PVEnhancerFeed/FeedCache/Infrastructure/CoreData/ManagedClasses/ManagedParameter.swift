//
//  ManagedParameter.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 01/07/2024.
//


import CoreData


// MARK: - ManagedParameter
@objc(ManagedParameter)
class ManagedParameter: NSManagedObject {
    @NSManaged var allskySfcSwDiff: String?
    @NSManaged var allskySfcSwDni: String?
    @NSManaged var allskySfcSwDwn: String?
    @NSManaged var properties: ManagedProperties?
}


// MARK: - Extension
extension ManagedParameter {
    var local: Parameter {
        let localParameter = Parameter(
            allskySfcSwDni: allskySfcSwDni?.toDictionary(),
            allskySfcSwDwn: allskySfcSwDwn?.toDictionary(),
            allskySfcSwDiff: allskySfcSwDiff?.toDictionary()
        )
        
        return localParameter
    }
    
    
    static func insert(_ parameter: Parameter?, in context: NSManagedObjectContext) -> ManagedParameter? {
        guard let parameter = parameter else {
            return nil
        }
        
        let managedParameter = ManagedParameter(context: context)
        managedParameter.allskySfcSwDni = parameter.allskySfcSwDni?.toString()
        managedParameter.allskySfcSwDwn = parameter.allskySfcSwDwn?.toString()
        managedParameter.allskySfcSwDiff = parameter.allskySfcSwDiff?.toString()
        
        return managedParameter
    }
}


// MARK: - Extension. Dictionary
public extension Dictionary where Key == String, Value == Double {
    func toString() -> String {
        return self.map { "\($0.key):\($0.value)" }.joined(separator: ",")
    }
}


// MARK: - Extension. String
public extension String {
    func toDictionary() -> [String: Double]? {
        let pairs = self.split(separator: ",").map { $0.split(separator: ":") }
        var dictionary = [String: Double]()
      
        for pair in pairs {
            if pair.count == 2, let value = Double(pair[1]) {
                dictionary[String(pair[0])] = value
            }
        }
       
        return dictionary
    }
}
