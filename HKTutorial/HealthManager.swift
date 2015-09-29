//
//  HealthManager.swift
//  HKTutorial
//
//  Created by ernesto on 18/10/14.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import Foundation
import HealthKit

class HealthManager {
  let healthkitStore:HKHealthStore = HKHealthStore()
  
  func authorizeHealthKit(completion: ((success:Bool, error:NSError!) ->Void)!){
    
    //    Types to Share (Write) to HK Store
    let healthKitTypesToShare: Set = [
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
      HKQuantityType.workoutType()
      ]
    //    Types to Read from HK Store
    let healthKitTypesToRead: Set = [
      HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
      HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType)!,
      HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
      HKObjectType.workoutType()
    ]
    
    // If the store is not available return error
    if !HKHealthStore.isHealthDataAvailable(){
      let error = NSError(domain: "com.oscarmorrison", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
      if( completion != nil ){
        completion(success:false, error:error)
      }
      return
    }
    
    // Request HealthKit authorisation
    healthkitStore.requestAuthorizationToShareTypes(healthKitTypesToShare, readTypes: healthKitTypesToRead) { (sucess, error) -> Void in
      if completion != nil{
        completion(success:sucess, error:error)
      }
    }
    
  }
  
}



















