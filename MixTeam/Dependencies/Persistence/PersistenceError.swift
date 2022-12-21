enum PersistenceError: Error, Equatable {
    case cannotGetDocumentDirectoryWithUserDomainMask
    case notFound
}
