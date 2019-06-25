//
//  IntentHandler.swift
//  SpartappIntent
//
//  Created by 童开文 on 2018/11/6.
//  Copyright © 2018 童开文. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is ClassesOfTheDayIntent else {
            return TomorrowClassIntentHandler()
        }
        
        return ClassesOfTheDayIntentHandler()
    }
    
}
