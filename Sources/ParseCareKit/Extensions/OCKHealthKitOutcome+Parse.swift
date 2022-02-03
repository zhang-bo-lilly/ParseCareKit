//
//  OCKHealthKitOutcome+Parse.swift
//  ParseCareKit
//
//  Created by Corey Baker on 2/3/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore
import ParseSwift
import os.log

public extension OCKHealthKitOutcome {
    /**
    The Parse ACL for this object.
    */
    var acl: ParseACL? {
        get {
            guard let aclString = userInfo?[ParseCareKitConstants.acl],
                  let aclData = aclString.data(using: .utf8),
                  let acl = try? PCKUtility.decoder().decode(ParseACL.self, from: aclData) else {
                      return nil
                  }
            return acl
        }
        set {
            do {
                let encodedACL = try PCKUtility.jsonEncoder().encode(newValue)
                guard let aclString = String(data: encodedACL, encoding: .utf8) else {
                    throw ParseCareKitError.cantEncodeACL
                }
                if userInfo != nil {
                    userInfo?[ParseCareKitConstants.acl] = aclString
                } else {
                    userInfo = [ParseCareKitConstants.acl: aclString]
                }
            } catch {
                if #available(iOS 14.0, watchOS 7.0, *) {
                    Logger.ockOutcome.error("Can't set ACL: \(error.localizedDescription)")
                } else {
                    os_log("Can't set ACL: `%{private}@`",
                           log: .ockOutcome,
                           type: .error,
                           error.localizedDescription)
                }
            }
        }
    }
}
