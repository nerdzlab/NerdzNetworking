//
//  File.swift
//  
//
//  Created by Vasyl Khmil on 28.11.2024.
//

import Foundation

/// An actor-based container that provides thread-safe access to a property of a given type
@available(iOS 13.0.0, *)
actor SyncPropertyActor<T> {
    /// The current value stored in the actor's property
    public var value: T
    
    /// Initializes a new instance of `SyncPropertyActor` with the specified initial value
    /// - Parameter value: The initial value to be stored in the property
    public init(_ value: T) {
        self.value = value
    }
    
    /// Sets a new value for the property, ensuring thread safety
    /// - Parameter value: The new value to be set
    public func setNewValue(_ value: T) {
        self.value = value
    }
    
    /// Modifies the property's value using a closure, ensuring thread safety.
    /// - Parameter closure: A closure that takes an inout parameter representing the property's value.
    ///                      Use this closure to modify the value safely
    ///
    /// Example usage:
    /// ```
    /// // Create an instance of SyncPropertyActor with an initial value of nil.
    /// private var nextPageLinks = SyncPropertyActor<PaginationLinksModel?>(nil)
    ///
    /// Task {
    ///     // Use the setNewValue method to set the property to nil in a thread-safe manner.
    ///     await nextPageLinks.setNewValue(nil)
    /// }
    /// ```
    public func modify(with closure: (inout T) -> Void) {
        closure(&value)
    }
}
