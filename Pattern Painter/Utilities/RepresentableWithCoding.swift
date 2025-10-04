//
//  RepresentableWithCoding.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 8/26/25.
//

import Foundation

protocol RepresentableWithCoding: Codable, RawRepresentable where RawValue == String {}

extension RepresentableWithCoding {
    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8), let decoded = try? JSONDecoder().decode(Self.self, from: data) else { return nil }
        self = decoded
    }

    var rawValue: String {
        String(data: (try? JSONEncoder().encode(self)) ?? Data(), encoding: .utf8) ?? ""
    }
}
