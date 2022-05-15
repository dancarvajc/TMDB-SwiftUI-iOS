//
//  CastTransformation.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 05-05-22.
//

import UIKit
import CoreData

public class CastTransformer: ValueTransformer {
    
    public override func transformedValue(_ value: Any?) -> Any? {
        guard let cast = value as? [Cast]
    else { return nil }
    
    do {
       
        let data = try NSKeyedArchiver.archivedData(withRootObject: cast, requiringSecureCoding: true) as NSData
      return data
    } catch {
      print("Failed to transform Cast -> Data")
      return nil
    }
  }
  
    public override func reverseTransformedValue(_ value: Any?) -> Any? {
    guard let data = value as? Data
    else { return nil }
    
    do {
      let cast = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, Cast.self], from: data) as? [Cast]
      return cast
    } catch {
      print("Failed to transform `Data` to `Cast`")
      return nil
    }
  }
}

class CastTransformer2: NSSecureUnarchiveFromDataTransformer {

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override class func transformedValueClass() -> AnyClass {
        return Cast.self
    }

    override class var allowedTopLevelClasses: [AnyClass] {
        return [NSArray.self, Cast.self]
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            fatalError("Wrong data type: value must be a Data object; received \(type(of: value))")
        }
        return super.transformedValue(data)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let cast = value as? [Cast] else {
            fatalError("Wrong data type: value must be a Reminder object; received \(type(of: value))")
        }
        return super.reverseTransformedValue(cast)
    }
}
