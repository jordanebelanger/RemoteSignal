//
//  CoreProtocols.swift
//  RemoteSignal
//
//  Created by monaco on 3/6/17.
//  Copyright © 2017 Jordane Belanger. All rights reserved.
//

import Foundation

public typealias SignalCallback<T> = (T) -> Void

public protocol SignalType {
    associatedtype DataType
    
    /// Should subscribe the observer to signal value event notification coming
    /// from this signal.
    func subscribe(on observer: AnyObject, callback: @escaping SignalCallback<DataType>)
    
    /// Should stop the observer from receiving signal value event notification
    /// from this signal.
    func cancelSubscription(for observer: AnyObject)
    
    /// Should stop all observers from receiving change notifications coming
    /// from this signal.
    func cancelAllSubscriptions()
}

public protocol RetainedSignalType: SignalType {
    /// Should contains the value of the latest payload fired from this signal
    /// or nil if the signal has never been fired.
    var latestSignalPayload: DataType? { get }
    
    /// Should subscribe the observer to signal value event notification coming
    /// from this signal and immedietaly be notified of the latest payload fired
    /// if any.
    func subscribePast(on observer: AnyObject, callback: @escaping SignalCallback<DataType>)
}

public protocol VariableType: SignalType {
    /// Should contain the current value of this `VariableType`.
    var value: DataType { get set }
    
    /// Should subscribe to any new value change notification on this
    /// SignalType instance as well as instantly calling your callback
    /// with the current variable's value.
    func subscribePast(on observer: AnyObject, callback: @escaping SignalCallback<DataType>)
}

/// This is meant to be the **remote** used by a Signal owner to **fire** new
/// Signal's event.
///
/// You can imagine it as using a remote to remotely fire a rocket :)
///
/// The remote interface should be used by concrete class of SignalType to
/// define their signal firing function to notify observers of new signal
/// values. Having a separate Remote interface allows you to hide the signaling
/// inteface of your signal from your observers by using the AnySignal type
/// erasure as the public interface for your signal.
///
public protocol RemoteType {
    associatedtype DataType
    
    /// Should fire a signal to observers containing a new value.
    func fire(_ payload: DataType)
}
