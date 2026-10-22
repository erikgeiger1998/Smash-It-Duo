import XCTest
@testable import ClapTrap

final class ClapTrapTests: XCTestCase {
    
    func testSymmetricalMirroringCoordinates() {
        let hingeX: CGFloat = 200.0
        let insectPos = CGPoint(x: 120.0, y: 350.0)
        
        let splatter = SplatterRecord(
            primaryPosition: insectPos,
            hingeX: hingeX,
            insectType: .housefly
        )
        
        // Primary position should match insect position
        XCTAssertEqual(splatter.primaryPosition.x, 120.0)
        XCTAssertEqual(splatter.primaryPosition.y, 350.0)
        
        // Mirrored position across hinge at 200: 2 * 200 - 120 = 280
        XCTAssertEqual(splatter.mirroredPosition.x, 280.0)
        XCTAssertEqual(splatter.mirroredPosition.y, 350.0)
        
        // The midpoint between primary and mirrored should be exactly the hinge!
        let mid = (splatter.primaryPosition.x + splatter.mirroredPosition.x) / 2.0
        XCTAssertEqual(mid, hingeX)
    }
    
    func testInsectWaveProgression() {
        // Waves 1-5: Housefly
        XCTAssertEqual(InsectType.housefly.initialHealth, 1)
        XCTAssertEqual(InsectType.housefly.baseScore, 100)
        
        // Mosquito
        XCTAssertEqual(InsectType.mosquito.initialHealth, 1)
        XCTAssertEqual(InsectType.mosquito.baseScore, 250)
        
        // Mutant Horsefly Boss
        XCTAssertEqual(InsectType.mutantHorsefly.initialHealth, 2)
        XCTAssertEqual(InsectType.mutantHorsefly.baseScore, 750)
        
        // The Wasp (Trap)
        XCTAssertEqual(InsectType.wasp.initialHealth, 1)
        XCTAssertEqual(InsectType.wasp.baseScore, 500)
    }
    
    func testFoldSensorManagerClosureDetection() {
        let sensor = FoldSensorManager.shared
        
        // Open flat
        sensor.reopenFlat()
        XCTAssertEqual(sensor.hingeAngle, 180.0)
        XCTAssertFalse(sensor.isClosed)
        
        // Half fold
        sensor.setHingeAngle(90.0)
        XCTAssertEqual(sensor.hingeAngle, 90.0)
        XCTAssertFalse(sensor.isClosed)
        
        // Close past threshold (<= 35 degrees)
        sensor.setHingeAngle(25.0)
        XCTAssertTrue(sensor.isClosed)
        
        // Reopen
        sensor.reopenFlat()
        XCTAssertFalse(sensor.isClosed)
    }
    
    func testSlamVelocityMach2Detection() {
        let sensor = FoldSensorManager.shared
        sensor.reopenFlat()
        
        // Simulate Mach 2 clap (> 1200 deg/sec)
        sensor.simulateSlamShut(velocity: 1450.0)
        XCTAssertTrue(sensor.isClosed)
        XCTAssertTrue(sensor.isMach2Slam)
        XCTAssertEqual(sensor.slamVelocity, 1450.0)
    }
    
    func testExternalCoverScreenAutoStartOnOpening() {
        let sensor = FoldSensorManager.shared
        let engine = ClapTrapGameEngine.shared
        
        // Put in cover screen mode
        sensor.isCoverScreen = true
        XCTAssertTrue(sensor.isCoverScreen)
        
        // Open hinge flat (simulating user unfolding the phone)
        sensor.reopenFlat()
        XCTAssertFalse(sensor.isCoverScreen)
        XCTAssertEqual(sensor.hingeAngle, 180.0)
        
        // Game automatically starts upon unfolding!
        XCTAssertEqual(engine.gameState, .hunting)
        XCTAssertNotNil(engine.activeInsect)
    }
    
    func testFoldableScreenGeometryHardwareDimensions() {
        // External cover screen in portrait (e.g. 390 x 844): min is 390 < 580
        let coverPortrait = CGSize(width: 390, height: 844)
        XCTAssertLessThan(min(coverPortrait.width, coverPortrait.height), 580.0, "Cover screen in portrait must be detected as cover screen")
        
        // External cover screen in landscape (e.g. 844 x 390): min is 390 < 580
        // CRITICAL: The game must NOT open when rotating the cover screen into landscape!
        let coverLandscape = CGSize(width: 844, height: 390)
        XCTAssertLessThan(min(coverLandscape.width, coverLandscape.height), 580.0, "Cover screen in landscape must still be detected as cover screen")
        
        // Unfolded inner dual screen (e.g. 800 x 900): min is 800 >= 580
        let unfoldedDualScreen = CGSize(width: 800, height: 900)
        XCTAssertGreaterThanOrEqual(min(unfoldedDualScreen.width, unfoldedDualScreen.height), 580.0, "Unfolded inner dual screen must have both dimensions >= 580")
        
        // Unfolded inner screen rotated (e.g. 900 x 800): min is 800 >= 580
        let unfoldedRotated = CGSize(width: 900, height: 800)
        XCTAssertGreaterThanOrEqual(min(unfoldedRotated.width, unfoldedRotated.height), 580.0, "Unfolded inner screen in either orientation must have min >= 580")
    }
    
    func testSwatMissCausesGameOverAndOpeningHingeRestarts() {
        let engine = ClapTrapGameEngine.shared
        let sensor = FoldSensorManager.shared
        sensor.reopenFlat()
        
        engine.startGame()
        XCTAssertEqual(engine.gameState, .hunting)
        
        // Ensure active insect is flying (not landed)
        engine.activeInsect?.state = .flying
        
        // User claps phone shut while insect is flying (whiff / missed!)
        sensor.simulateSlamShut(velocity: 800.0)
        
        // Did not trap fly -> GAME OVER!
        XCTAssertEqual(engine.gameState, .gameOver)
        XCTAssertEqual(engine.lastOutcome?.hit, false)
        
        // Opening hinge starts new game!
        engine.handleDeviceUnfolded()
        XCTAssertEqual(engine.gameState, .hunting)
        XCTAssertEqual(engine.currentWave, 1)
        XCTAssertEqual(engine.score, 0)
    }
    
    func testSwatHitTrapsFlyAndOpeningHingeAdvancesWave() {
        let engine = ClapTrapGameEngine.shared
        let sensor = FoldSensorManager.shared
        sensor.reopenFlat()
        
        engine.startGame()
        XCTAssertEqual(engine.currentWave, 1)
        
        // Insect lands
        engine.activeInsect?.state = .landed
        engine.gameState = .landed
        
        // User claps phone shut -> SUCCESSFUL SWAT!
        sensor.simulateSlamShut(velocity: 950.0)
        
        // Trapped the fly!
        XCTAssertEqual(engine.lastOutcome?.hit, true)
        XCTAssertGreaterThan(engine.score, 0)
        
        // Opening hinge advances to next wave!
        engine.handleDeviceUnfolded()
        XCTAssertEqual(engine.gameState, .hunting)
        XCTAssertEqual(engine.currentWave, 2)
    }
    
    func testPhysicalPhoneClosureTriggersSwat() {
        let engine = ClapTrapGameEngine.shared
        let sensor = FoldSensorManager.shared
        sensor.reopenFlat()
        
        engine.startGame()
        engine.activeInsect?.state = .landed
        engine.gameState = .landed
        
        // Simulating the phone closing shut completely
        sensor.triggerHardwareSlamShut(velocity: 1100.0)
        
        XCTAssertTrue(sensor.isClosed)
        XCTAssertEqual(engine.lastOutcome?.hit, true)
        
        // Simulating reopening the phone
        sensor.reopenFlat()
        XCTAssertFalse(sensor.isClosed)
        XCTAssertEqual(engine.gameState, .hunting)
        XCTAssertEqual(engine.currentWave, 2)
    }
    
    func testProceduralAudioSynthesizerSafety() {
        let soundEngine = ProceduralSoundEngine.shared
        
        // Ensure continuous spatial updates execute cleanly without crashing
        soundEngine.updateInsectSpatialBuzz(
            normalizedX: -0.75,
            altitude: 0.8,
            insectType: .housefly,
            active: true
        )
        
        soundEngine.updateInsectSpatialBuzz(
            normalizedX: 0.5,
            altitude: 0.0,
            insectType: .mosquito,
            active: true
        )
        
        soundEngine.stopBuzz()
    }
    
    func testScreenSpongeWiping() {
        let engine = ClapTrapGameEngine.shared
        engine.persistentSplatters = [
            SplatterRecord(primaryPosition: CGPoint(x: 100, y: 200), hingeX: 195, insectType: .housefly),
            SplatterRecord(primaryPosition: CGPoint(x: 250, y: 300), hingeX: 195, insectType: .mosquito)
        ]
        
        XCTAssertEqual(engine.persistentSplatters.count, 2)
        
        let expectation = XCTestExpectation(description: "Sponge cleans all splats")
        engine.wipeScreenWithSponge()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(engine.persistentSplatters.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.5)
    }
    
    func testReactionWindowSpeedsUpWithWaveProgression() {
        let engine = ClapTrapGameEngine.shared
        
        let wave1Time = engine.calculateLandingWindow(for: .housefly, wave: 1)
        let wave5Time = engine.calculateLandingWindow(for: .housefly, wave: 5)
        let wave10Time = engine.calculateLandingWindow(for: .housefly, wave: 10)
        let wave20Time = engine.calculateLandingWindow(for: .housefly, wave: 20)
        
        // Time must strictly decrease as waves advance!
        XCTAssertGreaterThan(wave1Time, wave5Time, "Wave 1 should have longer reaction window than Wave 5")
        XCTAssertGreaterThan(wave5Time, wave10Time, "Wave 5 should have longer reaction window than Wave 10")
        XCTAssertGreaterThan(wave10Time, wave20Time, "Wave 10 should have longer reaction window than Wave 20")
        
        // At wave 1, housefly gives 3.6s
        XCTAssertEqual(wave1Time, 3.60, accuracy: 0.01)
        
        // Never drops below floor of 0.95s
        let wave50Time = engine.calculateLandingWindow(for: .housefly, wave: 50)
        XCTAssertEqual(wave50Time, 0.95, accuracy: 0.01)
    }
}
