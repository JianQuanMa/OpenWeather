//
//  Then+.swift
//  OpenWeather
//
//  Created by Jian Quan Ma on 1/16/23.
//

import Foundation

public protocol Then {}

extension Then where Self: AnyObject {
  @inlinable
  public func then(_ block: (Self) throws -> Void) rethrows -> Self {
    try block(self)
    return self
  }
}

extension NSObject: Then {}
extension JSONDecoder: Then {}
