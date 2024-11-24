//
//  GameManagerTests.swift
//  ShootingAppTests
//
//  Created by Jose on 24/11/2024.
//

import XCTest
@testable import ShootingApp

final class GameManagerTests: XCTestCase {
    private var sut: GameManager!
    private var mockWebSocketService: MockWebSocketService!
    
    override func setUp() {
        super.setUp()
        sut = GameManager.shared
        mockWebSocketService = MockWebSocketService()
    }
    
    override func tearDown() {
        sut = nil
        mockWebSocketService = nil
        super.tearDown()
    }
    
    func testPlayerDiesAfterLivesReachZero() {
        // Given
        let expectation = expectation(forNotification: .playerDied, object: nil)
        let damage = 10
        
        // When
        let message = createHitMessage(damage: damage)
        sut.webSocketDidReceiveMessage(message)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.currentLives, 0)
        XCTAssertFalse(sut.isAlive)
    }
    
    func testDeadPlayerCannotBeHit() {
        // Given
        let notificationCenter = NotificationCenter.default
        var didReceiveHit = false
        
        let observer = notificationCenter.addObserver(
            forName: .playerWasHit,
            object: nil,
            queue: nil
        ) { _ in
            didReceiveHit = true
        }
        
        // When
        let message = createHitMessage(damage: 10)
        sut.handleShot(message)
        
        // Then
        XCTAssertFalse(didReceiveHit)
        notificationCenter.removeObserver(observer)
    }
    
    func testScoreIncrementsOnHit() {
        // Given
        let initialHits = sut.gameScore.hits
        
        // When
        let message = createHitConfirmedMessage()
        sut.webSocketDidReceiveMessage(message)
        
        // Then
        XCTAssertEqual(sut.gameScore.hits, initialHits + 1)
    }
    
    func testScoreIncrementsOnKill() {
        // Given
        let initialKills = sut.gameScore.kills
        
        // When
        let message = createKillMessage()
        sut.webSocketDidReceiveMessage(message)
        
        // Then
        XCTAssertEqual(sut.gameScore.kills, initialKills + 1)
    }
    
    func testPlayerRespawnsAfterCooldown() {
        // Given
        let expectation = expectation(forNotification: .playerRespawned, object: nil)
        expectation.expectedFulfillmentCount = 1
        
        // When
        sut.respawnPlayer()
        
        // Then
        wait(for: [expectation], timeout: 61.0)
        XCTAssertTrue(sut.isAlive)
        XCTAssertEqual(sut.currentLives, 10)
    }
    
    // MARK: - Helper Methods
    
    private func createHitMessage(damage: Int) -> GameMessage {
        GameMessage(
            type: .hit,
            playerId: "testShooter",
            data: MessageData(
                player: createTestPlayer(),
                shotId: "test",
                hitPlayerId: sut.playerId,
                damage: damage
            ),
            timestamp: Date(),
            targetPlayerId: sut.playerId
        )
    }
    
    private func createHitConfirmedMessage() -> GameMessage {
        GameMessage(
            type: .hitConfirmed,
            playerId: "testPlayer",
            data: MessageData(
                player: createTestPlayer(),
                shotId: "test",
                hitPlayerId: nil,
                damage: 10
            ),
            timestamp: Date(),
            targetPlayerId: sut.playerId
        )
    }
    
    private func createKillMessage() -> GameMessage {
        GameMessage(
            type: .kill,
            playerId: "testPlayer",
            data: MessageData(
                player: createTestPlayer(),
                shotId: "test",
                hitPlayerId: "testTarget",
                damage: 10
            ),
            timestamp: Date(),
            targetPlayerId: sut.playerId
        )
    }
    
    private func createTestPlayer() -> Player {
        Player(
            id: "testPlayer",
            location: LocationData(
                latitude: 0,
                longitude: 0,
                altitude: 0,
                accuracy: 0
            ),
            heading: 0,
            timestamp: Date()
        )
    }
}

final class MockWebSocketService: WebSocketService {
    var messages: [GameMessage] = []
    
    override func send(message: GameMessage) {
        messages.append(message)
    }
}
