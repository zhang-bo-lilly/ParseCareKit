//
//  ParseCareKitError.swift
//  ParseCareKit
//
//  Created by Corey Baker on 12/12/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//

import Foundation

enum ParseCareKitError: Error {
    case userNotLoggedIn
    case relatedEntityNotInCloud
    case requiredValueCantBeUnwrapped
    case objectIdDoesntMatchRemoteId
    case objectNotFoundOnParseServer
    case cloudClockLargerThanLocal
    case couldntUnwrapClock
    case couldntUnwrapRequiredField
    case couldntUnwrapSelf
    case cloudVersionNewerThanLocal
    case uuidAlreadyExists
    case cantCastToNeededClassType
    case cantEncodeACL
    case classTypeNotAnEligibleType
    case couldntCreateConcreteClasses
    case syncAlreadyInProgress
    case parseHealthError
    case errorString(_ string: String)
}

extension ParseCareKitError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userNotLoggedIn:
            return NSLocalizedString("ParseCareKit: Parse User isn't logged in.", comment: "Login error")
        case .relatedEntityNotInCloud:
            return NSLocalizedString("ParseCareKit: Related entity isn't in cloud.", comment: "Related entity error")
        case .requiredValueCantBeUnwrapped:
            return NSLocalizedString("ParseCareKit: Required value can't be unwrapped.", comment: "Unwrapping error")
        case .couldntUnwrapClock:
            return NSLocalizedString("ParseCareKit: Clock can't be unwrapped.", comment: "Clock Unwrapping error")
        case .couldntUnwrapRequiredField:
            return NSLocalizedString("ParseCareKit: Couldn't unwrap required field.",
                                     comment: "Couldn't unwrap required field")
        case .objectIdDoesntMatchRemoteId:
            return NSLocalizedString("ParseCareKit: remoteId and objectId don't match.",
                                     comment: "Remote/Local mismatch error")
        case .cloudClockLargerThanLocal:
            return NSLocalizedString("Cloud clock larger than local during pushRevisions, not pushing",
                                     comment: "Knowledge vector larger in Cloud")
        case .couldntUnwrapSelf:
            return NSLocalizedString("Can't unwrap self. This class has already been deallocated",
                                     comment: "Can't unwrap self, class deallocated")
        case .cloudVersionNewerThanLocal:
            return NSLocalizedString("Can't sync, the Cloud version newere than local version",
                                     comment: "Cloud version newer than local version")
        case .uuidAlreadyExists:
            return NSLocalizedString("Can't sync, the uuid already exists in the Cloud", comment: "UUID isn't unique")
        case .cantCastToNeededClassType:
            return NSLocalizedString("Can't cast to needed class type",
                                     comment: "Can't cast to needed class type")
        case .cantEncodeACL:
            return NSLocalizedString("Can't encode ACL",
                                     comment: "Can't encode ACL")
        case .classTypeNotAnEligibleType:
            return NSLocalizedString("PCKClass type isn't an eligible type",
                                     comment: "PCKClass type isn't an eligible type")
        case .couldntCreateConcreteClasses:
            return NSLocalizedString("Couldn't create concrete classes",
                                     comment: "Couldn't create concrete classes")
        case .objectNotFoundOnParseServer:
            return NSLocalizedString("Object couldn't be found on the Parse Server",
                                     comment: "Object couldn't be found on the Parse Server")
        case .syncAlreadyInProgress:
            return NSLocalizedString("Sync already in progress!", comment: "Sync already in progress!")
        case .parseHealthError:
            return NSLocalizedString("There was a problem with the health of the server!",
                                     comment: "There was a problem with the health of the server!")
        case .errorString(let string): return string
        }
    }
}
