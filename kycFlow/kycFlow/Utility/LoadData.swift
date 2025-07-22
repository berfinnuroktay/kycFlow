import Foundation

/// Loads data from the file in the main app bundle
/// - Parameter filename: The name of the file
/// - Returns: Data which is the content of the filename
func loadData(from filename: String) -> Data? {

    guard let fileURL = Bundle.main.url(forResource: filename, withExtension: nil) else {
        print("=== Error: Could not find \(filename) in the main bundle")
        return nil
    }

    guard let data = try? Data(contentsOf: fileURL) else {
        print("=== Error: Could not create data from the contents of \(filename)")
        return nil
    }

    return data
}
