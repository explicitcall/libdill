//
//  Generator.swift
//  CLibdillExample
//
//  Created by Max Desiatov on 13/02/2018.
//

import Foundation

class Generator<T>: Sequence, IteratorProtocol {
  private let channel: Channel<T>
  private var coroutine: Coroutine! = nil
  private var isFinished = false

  init(_ closure: @escaping ((T) -> ()) -> ()) {
    channel = try! Channel<T>()

    coroutine = try! Coroutine { [weak self] in
      closure { try! self?.channel.send($0, deadline: .never) }
      self?.isFinished = true
    }
  }

  func next() -> T? {
    // FIXME: correctly handle cancelled coroutines, which happen when
    // generators go out of scope before finished
    return isFinished ? nil : try? channel.receive(deadline: .never)
  }
}
