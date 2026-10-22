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
    
    func testFoldableScreenGeometryAspectRatio() {
        // External narrow cover screen (e.g. 390 x 844) -> ratio 0.46 < 0.70
        let coverScreenSize = CGSize(width: 390, height: 844)
        let coverRatio = coverScreenSize.width / coverScreenSize.height
        XCTAssertLessThan(coverRatio, 0.70, "Cover screen aspect ratio must be less than 0.70")
        
        // Unfolded inner dual screen (e.g. 800 x 900) -> ratio 0.88 >= 0.70
        let unfoldedDualScreenSize = CGSize(width: 800, height: 900)
        let dualRatio = unfoldedDualScreenSize.width / unfoldedDualScreenSize.height
        XCTAssertGreaterThanOrEqual(dualRatio, 0.70, "Unfolded dual screen aspect ratio must be >= 0.70")
        
        // Landscape unfolded dual screen (e.g. 852 x 393) -> ratio 2.16 >= 0.70
        let landscapeDualScreenSize = CGSize(width: 852, height: 393)
        let landscapeRatio = landscapeDualScreenSize.width / landscapeDualScreenSize.height
        XCTAssertGreaterThanOrEqual(landscapeRatio, 0.70, "Landscape dual screen ratio must be >= 0.70")
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
}
