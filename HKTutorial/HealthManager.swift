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
  
  func readProfile()-> (age:Int?, biologicalsex:HKBiologicalSexObject?, bloodtype: HKBloodTypeObject?){

    // Request birthday and calculate the age
    var age: Int?
    var biologicalSex:HKBiologicalSexObject?
    var bloodType: HKBloodTypeObject?
    
    //Get user's age
    var dateOfBirth: NSDate?
    do{
      dateOfBirth = try healthkitStore.dateOfBirth()
    }catch let error as NSError{
      dateOfBirth = nil
      print("\(error) error with date of birth")
    }
    let now: NSDate = NSDate()
    let ageComponents = NSCalendar.currentCalendar().components(.Year, fromDate: dateOfBirth!, toDate: now, options: .WrapComponents)
    age = ageComponents.year
    
    //Get user's sex
    do{
      biologicalSex = try healthkitStore.biologicalSex()
    }catch let error as NSError{
      biologicalSex = nil
      print("\(error) error with sex")
    }
    
    //Get user's blood type
    do{
      bloodType = try healthkitStore.bloodType()
    }catch let error as NSError{
      bloodType = nil
      print("\(error) error with blood type")
    }

    return (age, biologicalSex, bloodType)
  }
  
  func readMostRecentSample(sampleType:HKSampleType, completion: ((HKSample!, NSError!) -> Void)!){
    //Build the predicate
    let past = NSDate.distantPast()
    let now = NSDate()
    let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate: now, options: .None)
    
    //Build the sort descriptor, descending order
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    
    //return one sample
    let limit = 1
    
    //Build sample query
    let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
      { (sampleQuery, results, error ) -> Void in
        
        if let queryError = error {
          completion(nil,queryError)
          return;
        }
        
        // Get the first sample
        let mostRecentSample = results!.first as? HKQuantitySample
        
        // Execute the completion closure
        if completion != nil {
          completion(mostRecentSample,nil)
        }
    }
    
    //Execute the Query
    self.healthkitStore.executeQuery(sampleQuery)
    
  }
  
  
}




















