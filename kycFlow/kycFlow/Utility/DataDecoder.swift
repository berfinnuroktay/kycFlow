import Foundation

// Protocol which allows us to support decoding different file types in the future
protocol DataDecoder {
    func decode<T: Decodable>(from data: Data) throws -> T
}


struct JSONDataDecoder: DataDecoder {

    private let decoder = JSONDecoder()

    func decode<T>(from data: Data) throws -> T where T : Decodable {
        return try decoder.decode(T.self, from: data)
    }
}
