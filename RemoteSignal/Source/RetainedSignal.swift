//
//  RetainedSignal.swift
//  RemoteSignal
//
//  Created by Jordane Belanger on Mar 6, 2017.
//  Copyright © 2017 Jordane Belanger. All rights reserved.
//

import Foundation

/// A type erasure of the RetainedSignalType protocol. Using an AnyRetainedSignal instance
/// instead of a concrete RetainedSignalType class can be useful if want to hide the
/// signaling interface of your signals from other classes.
///
/// For example, you may want to hide the fire method of a public Signal owned
/// by a ViewModel from the ViewModel's owner to avoid unwanted 2 way bindings.
///
public struct AnyRetainedSignal<T>: RetainedSignalType {
    public typealias DataType = T
    
    private let _subscribe: (AnyObject, @escaping (DataType) -> Void) -> Void
    private let _subscribePast: (AnyObject, @escaping (DataType) -> Void) -> Void
    private let _cancelSubscription: (AnyObject) -> Void
    private let _cancelAllSubscriptions: (Void) -> Void
    private let _latestSignalPayload: (Void) -> DataType?
    
    /// Should contains the value of the latest payload fired from this signal
    /// or nil if the signal has never been fired.
    public var latestSignalPayload: T? {
        return _latestSignalPayload()
    }
    
    public init<S: AnyObject>(_ signal: S) where S: RetainedSignalType, S.DataType == T {
        self._subscribe = signal.subscribe
        self._subscribePast = signal.subscribePast
        self._cancelSubscription = signal.cancelSubscription
        self._cancelAllSubscriptions = signal.cancelAllSubscriptions
        self._latestSignalPayload = { [weak signal] in
            return signal?.latestSignalPayload
        }
    }
    
    /// Should subscribe to any new value change notification on this SignalType
    /// instance.
    public func subscribe(on observer: AnyObject, callback: @escaping (T) -> Void) {
        _subscribe(observer, callback)
    }
    
    /// Should subscribe the observer to signal value event notification coming
    /// from this signal and immedietaly be notified of the latest payload fired
    /// if any.
    public func subscribePast(on observer: AnyObject, callback: @escaping (T) -> Void) {
        _subscribePast(observer, callback)
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

/// Base concrete class of `RetainedSignalType`.
public final class RetainedSignal<T>: RetainedSignalType, RemoteType {
    public typealias DataType = T
    
    /// The latest signal payload fired if any.
    public private(set) var latestSignalPayload: DataType?
    
    private let signal: Signal<DataType> = Signal()
    
    /// Fire a signal payload to all of this signal's subscribers and updates 
    /// the latestSignalPayload value at the same time.
    public func fire(_ payload: DataType) {
        latestSignalPayload = payload
        signal.fire(payload)
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
        if let latestSignalPayload = latestSignalPayload {
            callback(latestSignalPayload)
        }
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
