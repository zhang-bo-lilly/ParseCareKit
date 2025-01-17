//
//  PCKObjectable.swift
//  ParseCareKit
//
//  Created by Corey Baker on 5/26/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import ParseSwift
import CareKitStore
import os.log

/**
 Objects that conform to the `PCKObjectable` protocol are Parse interpretations of `OCKObjectCompatible` objects.
*/
public protocol PCKObjectable: ParseObject {
    /// A universally unique identifier for this object.
    var uuid: UUID? { get }

    /// A human readable unique identifier. It is used strictly by the developer and will never be shown to a user
    var id: String { get }

    /// A human readable unique identifier (same as `id`, but this is what's on the Parse server, `id` is
    /// already taken in Parse). It is used strictly by the developer and will never be shown to a user
    var entityId: String? { get set }

    // The clock value of when this object was added to the Parse server.
    var logicalClock: Int? { get set }

    /// The semantic version of the database schema when this object was created.
    /// The value will be nil for objects that have not yet been persisted.
    var schemaVersion: OCKSemanticVersion? { get set }

    /// The date at which the object was first persisted to the database.
    /// It will be nil for unpersisted values and objects.
    var createdDate: Date? { get set }

    /// The last date at which the object was updated.
    /// It will be nil for unpersisted values and objects.
    var updatedDate: Date? { get set }

    /// The timezone this record was created in.
    var timezone: TimeZone? { get set }

    /// A dictionary of information that can be provided by developers to support their own unique
    /// use cases.
    var userInfo: [String: String]? { get set }

    /// A user-defined group identifier that can be used both for querying and sorting results.
    /// Examples may include: "medications", "exercises", "family", "males", "diabetics", etc.
    var groupIdentifier: String? { get set }

    /// An array of user-defined tags that can be used to sort or classify objects or values.
    var tags: [String]? { get set }

    /// Specifies where this object originated from. It could contain information about the device
    /// used to record the data, its software version, or the person who recorded the data.
    var source: String? { get set }

    /// Specifies the location of some asset associated with this object. It could be the URL for
    /// an image or video, the bundle name of a audio asset, or any other representation the
    /// developer chooses.
    var asset: String? { get set }

    /// Any array of notes associated with this object.
    var notes: [OCKNote]? { get set }

    /// A unique id optionally used by a remote database. Its precise format will be
    /// determined by the remote database, but it is generally not expected to be human readable.
    var remoteID: String? { get set }

    /// A boolean that is `true` when encoding the object for Parse. If `false` the object is encoding for CareKit.
    var encodingForParse: Bool { get set }

    /// Copy the values of a ParseCareKit object
    static func copyValues(from other: Self, to here: Self) throws -> Self
}

// MARK: Defaults
extension PCKObjectable {
    public var uuid: UUID? {
        guard let objectId = objectId,
            let uuid = UUID(uuidString: objectId) else {
            return nil
        }
        return uuid
    }

    public var id: String {
        guard let returnId = entityId else {
            return ""
        }
        return returnId
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.uuid == rhs.uuid
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.uuid)
    }
}

extension PCKObjectable {

    mutating func copyRelationalEntities(_ parse: Self) -> Self {
        var current = self
        current.notes = parse.notes
        return current
    }

    /// Copies the common values of another PCKObjectable object.
    /// - parameter from: The PCKObjectable object to copy from.
    mutating public func copyCommonValues(from other: Self) {
        entityId = other.entityId
        updatedDate = other.updatedDate
        timezone = other.timezone
        userInfo = other.userInfo
        remoteID = other.remoteID
        createdDate = other.createdDate
        notes = other.notes
        logicalClock = other.logicalClock
        source = other.source
        asset = other.asset
        schemaVersion = other.schemaVersion
        groupIdentifier = other.groupIdentifier
        tags = other.tags
    }

    /// Stamps all related entities with the current `logicalClock` value
    /*mutating public func stampRelationalEntities() throws -> Self {
        guard let logicalClock = self.logicalClock else {
            throw ParseCareKitError.couldntUnwrapSelf
        }
        var updatedNotes = [OCKNote]()
        notes?.forEach {
            var update = $0
            update.stamp(logicalClock)
            updatedNotes.append(update)
        }
        self.notes = updatedNotes
        return self
    }*/

    /// Determines if this PCKObjectable object can be converted to CareKit
    public func canConvertToCareKit() -> Bool {
        guard self.entityId != nil else {
            return false
        }
        return true
    }

    /**
     Finds the first object on the server that has the same `uuid`.
     - Parameters:
        - uuid: The UUID to search for.
        - options: A set of header options sent to the server. Defaults to an empty set.
        - relatedObject: An object that has the same `uuid` as the one being searched for.
        - completion: The block to execute.
     It should have the following argument signature: `(Result<Self,Error>)`.
    */
    static public func first(_ uuid: UUID?,
                             options: API.Options = [],
                             completion: @escaping(Result<Self, Error>) -> Void) {

        guard let uuidString = uuid?.uuidString else {
            completion(.failure(ParseCareKitError.requiredValueCantBeUnwrapped))
                return
        }

        let query = Self.query(ParseKey.objectId == uuidString)
            .includeAll()
        query.first(options: options,
                    callbackQueue: ParseRemote.queue) { result in

            switch result {

            case .success(let object):
                completion(.success(object))
            case .failure(let error):
                completion(.failure(error))
            }

        }
    }

    /**
     Create a `DateInterval` like how CareKit generates one.
     - Parameters:
        - for: the date to start the interval.
    
     - returns: a interval from `for` to the next day.
    */
    public static func createCurrentDateInterval(for date: Date) -> DateInterval {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay)!
        return DateInterval(start: startOfDay, end: endOfDay)
    }
}

// MARK: Encodable
extension PCKObjectable {

    /**
     Encodes the PCKObjectable properties of the object
     - Parameters:
        - to: the encoder the properties should be encoded to.
    */
    public func encodeObjectable(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PCKCodingKeys.self)

        if encodingForParse {
            if !(self is PCKOutcome) {
                try container.encodeIfPresent(entityId, forKey: .entityId)
            }
            try container.encodeIfPresent(objectId, forKey: .objectId)
            try container.encodeIfPresent(ACL, forKey: .ACL)
            try container.encodeIfPresent(logicalClock, forKey: .logicalClock)
        } else {
            if !(self is PCKOutcome) {
                try container.encodeIfPresent(entityId, forKey: .id)
            }
            try container.encodeIfPresent(uuid, forKey: .uuid)
        }
        try container.encodeIfPresent(schemaVersion, forKey: .schemaVersion)
        try container.encodeIfPresent(createdDate, forKey: .createdDate)
        try container.encodeIfPresent(updatedDate, forKey: .updatedDate)
        try container.encodeIfPresent(timezone, forKey: .timezone)
        try container.encodeIfPresent(userInfo, forKey: .userInfo)
        try container.encodeIfPresent(groupIdentifier, forKey: .groupIdentifier)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encodeIfPresent(asset, forKey: .asset)
        try container.encodeIfPresent(remoteID, forKey: .remoteID)
        try container.encodeIfPresent(notes, forKey: .notes)
    }
}
