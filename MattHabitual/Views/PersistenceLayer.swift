//
//  PersistenceLayer.swift
//  Habitual
//
//  Created by MacAir23 on 11/27/18.
//  Copyright © 2018 Matthew Phraxayavong. All rights reserved.
//

import Foundation

struct PersistenceLayer {
    
    // MARK: - VARS
    
    // Line 1
    private(set) var habits: [Habit] = []
    
    // Line 2
    private static let userDefaultsHabitsKeyValue = "HABITS_ARRAY"
    
    init() {
        // Line 3
        self.loadHabits()
    }
    
    private mutating func loadHabits() {
        
        // Line 2
        let userDefaults = UserDefaults.standard
        
        // Line 3
        guard
            let habitData = userDefaults.data(forKey: PersistenceLayer.userDefaultsHabitsKeyValue),
            let habits = try? JSONDecoder().decode([Habit].self, from: habitData) else {
                return
        }
        
        self.habits = habits
    }
    
    // Line 1
    @discardableResult
    
    // Line 2
    mutating func createNewHabit(name: String, image: Habit.Images) -> Habit {
        
        //Line 3
        let newHabit = Habit(title: name, image: image)
        self.habits.insert(newHabit, at: 0) // Prepend the habits to the array
        self.saveHabits()
        
        return newHabit
    }
    
    //save
    private func saveHabits() {
        // Line 1
        guard let habitsData = try? JSONEncoder().encode(self.habits) else {
            fatalError("could not encode list of habits")
        }
        
        // Line 2
        let userDefaults = UserDefaults.standard
        userDefaults.set(habitsData, forKey: PersistenceLayer.userDefaultsHabitsKeyValue)
    }
    
    // delete habit
    mutating func delete(_ habitIndex: Int) {
        // Remove habit at the given index
        self.habits.remove(at: habitIndex)
        
        // Persist the changes we made to our habits array
        self.saveHabits()
    }
    
    // Line 1
    mutating func markHabitAsCompleted(_ habitIndex: Int) -> Habit {
        
        // Line 2
        var updatedHabit = self.habits[habitIndex]
        
        // Line 3
        guard updatedHabit.hasCompletedForToday == false else { return updatedHabit }
        
        // Line 4
        updatedHabit.numberOfCompletions += 1
        
        // Line 5
        if let lastCompletionDate = updatedHabit.lastCompletionDate, lastCompletionDate.isYesterday {
            updatedHabit.currentStreak += 1
        } else {
            updatedHabit.currentStreak = 1
        }
        
        // Line 6
        if updatedHabit.currentStreak > updatedHabit.bestStreak {
            updatedHabit.bestStreak = updatedHabit.currentStreak
        }
        
        // Line 7
        let now = Date()
        updatedHabit.lastCompletionDate = now
        
        // Line 8
        self.habits[habitIndex] = updatedHabit
        self.saveHabits()
        
        return updatedHabit
    }
    
    // Line 1
    mutating func swapHabits(habitIndex: Int, destinationIndex: Int) {
        let habitToSwap = self.habits[habitIndex]
        self.habits.remove(at: habitIndex)
        self.habits.insert(habitToSwap, at: destinationIndex)
        self.saveHabits()
    }
    
    // Line 2
    mutating func setNeedsToReloadHabits() {
        self.loadHabits()
    }
}
