//
//  Future.swift
//  CLibdillExample
//
//  Created by Max Desiatov on 13/02/2018.
//

import Foundation

class Future<T> {
    private var coroutine: Coroutine! = nil
    private let channel: Channel<T>
    private var result: T?
    private var error: Error?
    private var success: ((T) -> ())?
    private var failure: ((Error) -> ())?

    init(_ closure: @escaping () throws -> T) throws {
        channel = try Channel<T>()

        coroutine = try Coroutine { [weak self] in
            do {
                let res = try closure()
                self?.result = res
                self?.success?(res)
                try self?.channel.send(res, deadline: .immediately)
            } catch {
                self?.error = error
                self?.failure?(error)
            }
        }
    }

    func wait() throws -> T {
      guard let result = result else {
        return try channel.receive(deadline: .never)
      }

      return result
    }

    func then(_ success: @escaping (T) -> (), failure: ((Error) -> ())? = nil) {
        if let error = error {
            failure?(error)
        } else if let result = result {
            success(result)
        } else {
            self.success = success
            self.failure = failure
        }
    }
}
