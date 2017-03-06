//
//  Variable.swift
//  RemoteSignal
//
//  Created by Jordane Belanger on Mar 6, 2017.
//  Copyright © 2017 Jordane Belanger. All rights reserved.
//

import Foundation

/// Base concrete class of the `VariableType`, use for simple two way binding of
/// a signal.
public final class Variable<T>: VariableType {
    public typealias DataType = T
    
    /// The current value of the variable, changing this value will notify
    /// all subscribers of the change.
    public var value: DataType {
        didSet {
            signal.fire(value)
        }
    }
    
    private let signal: Signal<DataType> = Signal()
    
    public init(initialValue: DataType) {
        self.value = initialValue
    }
    
    /// Subscribe the observer to signal value event notification on this
    /// signal.
    public func subscribe(on observer: AnyObject, callback: @escaping SignalCallback<DataType>) {
        signal.subscribe(on: observer, callback: callback)
    }
    
    /// Subscribe the observer to signal value event notification on this
    /// signal and immeditely calling the callback with the latest signal
    /// payload sent if any.
    public func subscribePast(on observer: AnyObject, callback: @escaping SignalCallback<DataType>) {
        signal.subscribe(on: observer, callback: callback)
        callback(value)
    }
    
    /// Stop the observer from receiving signal value event notification from
    /// this signal.
    public func cancelSubscription(for observer: AnyObject) {
        signal.cancelSubscription(for: observer)
    }
    
    /// Stop all observers from receiving signal value event notification from
    /// this signal.
    public func cancelAllSubscriptions() {
        signal.cancelAllSubscriptions()
    }
    
}
