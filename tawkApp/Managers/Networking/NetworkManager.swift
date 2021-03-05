//
//  NetworkManager.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 03.03.2021.
//

import Foundation
import Combine
import SystemConfiguration

enum GithubError: Error, LocalizedError {
    case urlError(URLError)
    case responseError(Int)
    case decodingError(DecodingError)
    case genericError
    
    var localizedDescription: String {
        switch self {
            case .urlError(let error):
                return error.localizedDescription
            case .decodingError(let error):
                return error.localizedDescription
            case .responseError(let status):
                return "Bad response code: \(status)"
            case .genericError:
                return "An unknown error has been occured"
        }
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    static let baseUrl = "https://api.github.com"
    private let urlSession = URLSession.shared
    private var subscriptions = Set<AnyCancellable>()
    
    private func generateURL(with path: String) -> URL? {
        guard let url = URL(string: "\(NetworkManager.baseUrl)/users\(path)") else {
            return nil
        }
        return url
    }
    
    public func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func getUserList(_ page: Int) -> Future<[UserListModel], GithubError> {
        return Future<[UserListModel], GithubError> { promise in
            guard let url = self.generateURL(with: "?since=\(page)") else {
                return promise(.failure(.urlError(URLError(URLError.unsupportedURL))))
            }
            
            self.urlSession.dataTaskPublisher(for: url)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          200...299 ~= httpResponse.statusCode else {
                        throw GithubError.responseError(
                            (response as? HTTPURLResponse)?.statusCode ?? 500)
                    }
                    return data
                }
                .decode(type: [UserListModel].self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { (completion) in
                    if case let .failure(error) = completion {
                        switch error {
                            case let urlError as URLError:
                                promise(.failure(.urlError(urlError)))
                            case let decodingError as DecodingError:
                                promise(.failure(.decodingError(decodingError)))
                            case let apiError as GithubError:
                                promise(.failure(apiError))
                            default:
                                promise(.failure(.genericError))
                        }
                    }
                }, receiveValue: { promise(.success($0)) })
                .store(in: &self.subscriptions)

        }
    }
    
    func getUserDetails(_ userName: String) -> Future<UserDetailsModel, GithubError> {
        return Future<UserDetailsModel, GithubError> { promise in
            guard let url = self.generateURL(with: "/\(userName)") else {
                return promise(.failure(.urlError(URLError(URLError.unsupportedURL))))
            }
            
            self.urlSession.dataTaskPublisher(for: url)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          200...299 ~= httpResponse.statusCode else {
                        throw GithubError.responseError(
                            (response as? HTTPURLResponse)?.statusCode ?? 500)
                    }
                    return data
                }
                .decode(type: UserDetailsModel.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { (completion) in
                    if case let .failure(error) = completion {
                        switch error {
                            case let urlError as URLError:
                                promise(.failure(.urlError(urlError)))
                            case let decodingError as DecodingError:
                                promise(.failure(.decodingError(decodingError)))
                            case let apiError as GithubError:
                                promise(.failure(apiError))
                            default:
                                promise(.failure(.genericError))
                        }
                    }
                }, receiveValue: { promise(.success($0)) })
                .store(in: &self.subscriptions)
            
        }
    }
}
