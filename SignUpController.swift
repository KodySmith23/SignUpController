//
//  SignUpController.swift
//
//
//  Created by Kody Smith on 1/8/24.
//

import Vapor
import BCrypt

struct SignupController {
    static func signupHandler(req: Request) throws -> EventLoopFuture<Response> {
        do {
            let signUpData = try req.content.decode(SignUpData.self)

            let hashedPassword = try hashPassword(signUpData.password)

            let newUser = User(
                email: signUpData.email,
                firstName: signUpData.firstName,
                lastName: signUpData.lastName,
                passwordHash: hashedPassword
            )

            return newUser.save(on: req.db).transform(to: Response(
                status: .ok,
                version: req.version,
                headers: HTTPHeaders([("Content-Type", "application/json")]),
                body: .init(string: "Signup successful")
            ))
        } catch {
            let errorResponse = ErrorResponse(message: "Signup failed")
            return req.eventLoop.makeFailedFuture(errorResponse)
        }
    }
    
    private static func hashPassword(_ password: String) throws -> String {
        do {
            let hashedPassword = try Bcrypt.hash(password)
            return hashedPassword
        } catch {
            throw Abort(.internalServerError, reason: "Failed to hash the password.")
        }
    }
}

