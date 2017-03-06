//
//  RemoteSignal.swift
//  RemoteSignal
//
//  Created by Jordane Belanger on Mar 6, 2017.
//  Copyright © 2017 Jordane Belanger. All rights reserved.
//

import Foundation

/// A type erasure of the SignalType protocol. Using an AnySignal instance
/// instead of a concrete SignalType class can be useful if want to hide the
/// signaling interface of your signals from other classes.
///
/// For example, you may want to hide the fire method of a public Signal owned
/// by a ViewModel from the ViewModel's owner to avoid unwanted 2 way bindings.
///
public struct AnySignal<T>: SignalType {
    public typealias DataType = T
    
    private let _subscribe: (AnyObject, @escaping (DataType) -> Void) -> Void
    private let _cancelSubscription: (AnyObject) -> Void
    private let _cancelAllSubscriptions: (Void) -> Void
    
    public init<S: AnyObject>(_ signal: S) where S: SignalType, S.DataType == T {
        self._subscribe = signal.subscribe
        self._cancelSubscription = signal.cancelSubscription
        self._cancelAllSubscriptions = signal.cancelAllSubscriptions
    }
    
    /// Should subscribe to any new value change notification on this SignalType
    /// instance.
    public func subscribe(on observer: AnyObject, callback: @escaping (T) -> Void) {
        _subscribe(observer, callback)
    }
    
    /// Should stop the observer from receiving change notifications coming from
    /// this signal.
    public func cancelSubscription(for observer: AnyObject) {
        _cancelSubscription(observer)
    }
    
    /// Should stop all observers from receiving change notifications coming
    /// from this signal.
    public func cancelAllSubscriptions() {
        _cancelAllSubscriptions()
    }
    
}

/// Base concrete `SignalType` class.
public final class Signal<T>: SignalType, RemoteType {
    public typealias DataType = T
    
    private var subscriptions: [SignalSubscription<T>] = []
    
    public init() {}
    
    /// Subscribe the observer to signal value event notification on this
    /// signal.
    public func subscribe(on observer: AnyObject, callback: @escaping SignalCallback<T>) {
        flushDeadSubscribers()
        if !subscriptions.contains { $0.observer === observer } {
            subscriptions.append(SignalSubscription(observer: observer, callback: callback))
        }
    }
    
    /// Stop the observer from receiving signal value event notification from
    /// this signal.
    public func cancelSubscription(for observer: AnyObject) {
        subscriptions = subscriptions.filter {
            if let strongObserver = $0.observer, strongObserver === observer {
                return false
            }
            return true
        }
    }
    
    /// Stop all observers from receiving signal value event notification from
    /// this signal.
    public func cancelAllSubscriptions() {
        subscriptions.removeAll()
    }
    
    /// Fire a signal payload to all of this signal's subscribers.
    public func fire(_ payload: T) {
        flushDeadSubscribers()
        for sub in subscriptions {
            sub.callback(payload)
        }
    }
    
    // MARK: Private
    
    private func flushDeadSubscribers() {
        subscriptions = subscriptions.filter { $0.observer != nil }
    }
    
}

fileprivate final class SignalSubscription<T> {
    weak var observer: AnyObject?
    let callback: (T) -> Void
    
    init(observer: AnyObject, callback: @escaping (T) -> Void) {
        self.observer = observer
        self.callback = callback
    }
}
