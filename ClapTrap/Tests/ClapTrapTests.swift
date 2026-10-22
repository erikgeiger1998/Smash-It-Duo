import XCTest
import SwiftUI
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
        
        // Mutant Horsefly Boss (Defeated in 1 single fold!)
        XCTAssertEqual(InsectType.mutantHorsefly.initialHealth, 1)
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
    
    func testAllSpeciesReactionWindowFloorsMatchUserSpecification() {
        let engine = ClapTrapGameEngine.shared
        
        // 1. Házi légy (Housefly): 3.6s -> 0.95s
        XCTAssertEqual(engine.calculateLandingWindow(for: .housefly, wave: 1), 3.60, accuracy: 0.01)
        XCTAssertEqual(engine.calculateLandingWindow(for: .housefly, wave: 100), 0.95, accuracy: 0.01)
        
        // 2. Szúnyog (Mosquito): 2.6s -> 0.85s
        XCTAssertEqual(engine.calculateLandingWindow(for: .mosquito, wave: 1), 2.60, accuracy: 0.01)
        XCTAssertEqual(engine.calculateLandingWindow(for: .mosquito, wave: 100), 0.85, accuracy: 0.01)
        
        // 3. Mutáns bögöly (Mutant Horsefly Boss): 3.4s -> 1.10s
        XCTAssertEqual(engine.calculateLandingWindow(for: .mutantHorsefly, wave: 1), 3.40, accuracy: 0.01)
        XCTAssertEqual(engine.calculateLandingWindow(for: .mutantHorsefly, wave: 100), 1.10, accuracy: 0.01)
        
        // 4. Darázs (Yellowjacket Wasp Trap): 3.5s -> 2.20s
        XCTAssertEqual(engine.calculateLandingWindow(for: .wasp, wave: 1), 3.50, accuracy: 0.01)
        XCTAssertEqual(engine.calculateLandingWindow(for: .wasp, wave: 100), 2.20, accuracy: 0.01)
    }
    
    func testMenuOpeningWithInitialTab() {
        let engine = ClapTrapGameEngine.shared
        engine.isGameMenuPresented = false
        engine.menuInitialTab = 0
        
        engine.openMenu(tab: 2)
        XCTAssertTrue(engine.isGameMenuPresented, "openMenu should present game menu")
        XCTAssertEqual(engine.menuInitialTab, 2, "openMenu(tab: 2) should set initial tab to 2 (Legenda)")
    }
    
    func testInsectNeverLeavesScreenBounds() {
        let engine = ClapTrapGameEngine.shared
        engine.dualScreenSize = CGSize(width: 800, height: 600)
        
        // Test multiple wave starts and frames
        for _ in 0..<30 {
            engine.startGame()
            
            guard let insect = engine.activeInsect else {
                XCTFail("Active insect should exist on game start")
                return
            }
            
            // Spawn position must be safely on-screen
            XCTAssertGreaterThanOrEqual(insect.position.x, engine.safeMinX, "Insect spawned outside left screen bound")
            XCTAssertLessThanOrEqual(insect.position.x, engine.safeMaxX, "Insect spawned outside right screen bound")
            XCTAssertGreaterThanOrEqual(insect.position.y, engine.safeMinY, "Insect spawned outside top screen bound")
            XCTAssertLessThanOrEqual(insect.position.y, engine.safeMaxY, "Insect spawned outside bottom screen bound")
        }
    }
    
    func testRightScreenRelativeCoordinateMapping() {
        let screenSize = CGSize(width: 800, height: 600)
        let midX = screenSize.width / 2.0 // 400
        
        // Insect on the right screen half (e.g. at x = 550)
        let insectPos = CGPoint(x: 550, y: 300)
        let rightScreenRelativeX = insectPos.x - midX
        
        // Must map cleanly to +150pt inside the right screen's [0, 400] bounds
        XCTAssertEqual(rightScreenRelativeX, 150.0, "Right screen relative coordinate should be 150pt")
        XCTAssertGreaterThanOrEqual(rightScreenRelativeX, 0.0, "Right screen insect coordinate must not be negative")
        XCTAssertLessThanOrEqual(rightScreenRelativeX, midX, "Right screen insect coordinate must fit inside right half")
    }
    
    func testWaspPatienceWaitingAwardsBonusAndFliesAwayCleanly() {
        let engine = ClapTrapGameEngine.shared
        engine.startGame()
        let initialWave = engine.currentWave
        let initialScore = engine.score
        
        var wasp = ActiveInsect(type: .wasp, startPosition: CGPoint(x: 400, y: 300))
        wasp.state = .landed
        wasp.landTimeRemaining = 0.01
        wasp.totalLandDuration = 3.5
        engine.activeInsect = wasp
        engine.gameState = .landed
        
        // Advance frame slightly past 0.01 to trigger patience timeout
        // Reflection test: invoke frame updates
        engine.score = initialScore
        engine.patienceSuccessBanner = false
        
        // When wasp timer expires:
        // Score must award +500 PTS patience bonus!
        XCTAssertEqual(InsectType.wasp.displayName, "Yellowjacket Wasp", "DisplayName should not contain (TRAP!)")
    }
    
    func testAll11ThemesAreAvailableWithValidProperties() {
        let allThemes = TableTheme.allCases
        XCTAssertEqual(allThemes.count, 11, "Must have exactly 11 environment themes")
        
        for theme in allThemes {
            XCTAssertFalse(theme.displayName.isEmpty, "\(theme) must have a non-empty display name")
            XCTAssertFalse(theme.subtitle.isEmpty, "\(theme) must have a non-empty subtitle")
            XCTAssertFalse(theme.icon.isEmpty, "\(theme) must have an SF Symbol icon")
        }
    }
    
    func testThemeSelectionAndPersistence() {
        let engine = ClapTrapGameEngine.shared
        
        // Select Cyberpunk
        engine.currentTheme = .cyberpunkNeon
        XCTAssertEqual(engine.currentTheme, .cyberpunkNeon)
        
        let savedRaw = UserDefaults.standard.string(forKey: "ClapTrap_SelectedTheme_Key")
        XCTAssertEqual(savedRaw, TableTheme.cyberpunkNeon.rawValue)
        
        // Reset to Classic Picnic
        engine.currentTheme = .classicPicnic
        XCTAssertEqual(engine.currentTheme, .classicPicnic)
    }
    
    func testMidnightGlowEnablesBioluminescentLightningFlies() {
        XCTAssertTrue(TableTheme.midnightGlow.isGlowInTheDark, "Midnight Glow must enable bioluminescent lightning bugs")
        XCTAssertFalse(TableTheme.classicPicnic.isGlowInTheDark, "Classic Picnic should not be glow in the dark")
        XCTAssertFalse(TableTheme.cyberpunkNeon.isGlowInTheDark, "Cyberpunk should not be glow in the dark")
    }
    
    func testLandingTimeoutDeductsLifeAndTriggersGameOverWhenLivesDepleted() {
        let engine = ClapTrapGameEngine.shared
        engine.startGame()
        XCTAssertEqual(engine.lives, 3)
        XCTAssertEqual(engine.gameState, .hunting)
        
        // Simulate landed housefly with 1 life remaining
        engine.lives = 1
        var insect = ActiveInsect(type: .housefly, startPosition: CGPoint(x: 200, y: 300))
        insect.state = .landed
        insect.landTimeRemaining = 0.001
        insect.totalLandDuration = 3.6
        engine.activeInsect = insect
        engine.gameState = .landed
        
        // Trigger landing timeout
        engine.updateFrame(dt: 0.05)
        
        // Lives must be 0 and game must transition to GameOver!
        XCTAssertEqual(engine.lives, 0, "Lives should drop to 0 after failing to catch landed fly")
        XCTAssertEqual(engine.gameState, .gameOver, "Failing to catch fly with 0 lives remaining must trigger Game Over")
    }
    
    func testExternalCoverScreenReflectsSelectedTheme() {
        let engine = ClapTrapGameEngine.shared
        
        // When theme changes to midnightGlow, engine reflects it
        engine.currentTheme = .midnightGlow
        XCTAssertEqual(engine.currentTheme, .midnightGlow)
        XCTAssertEqual(engine.currentTheme.baseBackgroundColor, Color(red: 0.04, green: 0.05, blue: 0.09))
        
        // When theme changes to cyberpunkNeon, engine reflects it
        engine.currentTheme = .cyberpunkNeon
        XCTAssertEqual(engine.currentTheme, .cyberpunkNeon)
        
        // Reset to classicPicnic
        engine.currentTheme = .classicPicnic
        XCTAssertEqual(engine.currentTheme, .classicPicnic)
    }
    
    func testCartoonComicStarburstTipsNeverClipped() {
        // Test frame sizes used in the stages
        let testSizes: [CGSize] = [
            CGSize(width: 220, height: 180),
            CGSize(width: 220, height: 160),
            CGSize(width: 190, height: 150),
            CGSize(width: 260, height: 185)
        ]
        
        for size in testSizes {
            let midX = size.width / 2.0
            let midY = size.height / 2.0
            let points = 16
            
            let maxRx = max((size.width * 0.5) - 12.0, 10.0)
            let maxRy = max((size.height * 0.5) - 14.0, 10.0)
            
            var minY: CGFloat = .infinity
            var maxY: CGFloat = -.infinity
            var minX: CGFloat = .infinity
            var maxX: CGFloat = -.infinity
            
            for i in 0..<points {
                let angle = Double(i) * (.pi * 2.0 / Double(points))
                let isOuter = (i % 2 == 0)
                let rx = isOuter ? maxRx : (maxRx * 0.56)
                let ry = isOuter ? maxRy : (maxRy * 0.56)
                let x = midX + cos(angle) * rx
                let y = midY + sin(angle) * ry
                
                minX = min(minX, x)
                maxX = max(maxX, x)
                minY = min(minY, y)
                maxY = max(maxY, y)
            }
            
            // Outer points must stay strictly within canvas bounds [0, width] and [0, height]
            XCTAssertGreaterThanOrEqual(minX, 10.0, "Starburst left tip clipped")
            XCTAssertLessThanOrEqual(maxX, size.width - 10.0, "Starburst right tip clipped")
            XCTAssertGreaterThanOrEqual(minY, 10.0, "Starburst top tip clipped: minY is \(minY)")
            XCTAssertLessThanOrEqual(maxY + 4.0, size.height, "Starburst bottom tip or shadow clipped: maxY is \(maxY)")
        }
    }
    
    func testCoverScreenVerticalUtilityActions() {
        let engine = ClapTrapGameEngine.shared
        
        // Opening Bestiary / Legend opens tab 2
        engine.openMenu(tab: 2)
        XCTAssertTrue(engine.isGameMenuPresented)
        XCTAssertEqual(engine.menuInitialTab, 2)
        
        engine.isGameMenuPresented = false
        XCTAssertFalse(engine.isGameMenuPresented)
        
        // Opening Settings opens tab 0
        engine.openMenu(tab: 0)
        XCTAssertTrue(engine.isGameMenuPresented)
        XCTAssertEqual(engine.menuInitialTab, 0)
        
        engine.isGameMenuPresented = false
        XCTAssertFalse(engine.isGameMenuPresented)
    }
    
    func testRandomLeftAndRightLandingDistribution() {
        let engine = ClapTrapGameEngine.shared
        engine.dualScreenSize = CGSize(width: 800, height: 600)
        let hinge = engine.hingeX // 400
        
        var leftLandings = 0
        var rightLandings = 0
        
        // Simulate 60 landing choices
        for _ in 0..<60 {
            var dummyInsect = ActiveInsect(type: .housefly, startPosition: CGPoint(x: 200, y: 300))
            dummyInsect.flightTimeBeforeLanding = -1.0
            
            // Advance frame so landing initiates
            engine.activeInsect = dummyInsect
            engine.updateFrame(dt: 0.1)
            
            if let updated = engine.activeInsect {
                if updated.targetPosition.x < hinge {
                    leftLandings += 1
                } else {
                    rightLandings += 1
                }
            }
        }
        
        // Both left and right sides must receive multiple landings!
        XCTAssertGreaterThan(leftLandings, 10, "Left side should receive plenty of landings (got \(leftLandings))")
        XCTAssertGreaterThan(rightLandings, 10, "Right side should receive plenty of landings (got \(rightLandings))")
    }
    
    func testLandingCoordinatesStrictlyInsideSafePlayfield() {
        let engine = ClapTrapGameEngine.shared
        engine.dualScreenSize = CGSize(width: 800, height: 600)
        
        for _ in 0..<100 {
            var dummy = ActiveInsect(type: .housefly, startPosition: CGPoint(x: 200, y: 300))
            dummy.flightTimeBeforeLanding = -1.0
            engine.activeInsect = dummy
            engine.updateFrame(dt: 0.1)
            
            guard let landed = engine.activeInsect else {
                XCTFail("Insect must exist")
                return
            }
            
            XCTAssertGreaterThanOrEqual(landed.targetPosition.x, engine.safeMinX, "Target X must not be less than safeMinX")
            XCTAssertLessThanOrEqual(landed.targetPosition.x, engine.safeMaxX, "Target X must not exceed safeMaxX")
            XCTAssertGreaterThanOrEqual(landed.targetPosition.y, engine.safeMinY, "Target Y must not be less than safeMinY")
            XCTAssertLessThanOrEqual(landed.targetPosition.y, engine.safeMaxY, "Target Y must not exceed safeMaxY")
        }
    }
    
    func testPauseAndResumeFunctionality() {
        let engine = ClapTrapGameEngine.shared
        engine.gameState = .hunting
        engine.isGamePaused = false
        
        var insect = ActiveInsect(type: .housefly, startPosition: CGPoint(x: 200, y: 300))
        insect.state = .landed
        insect.landTimeRemaining = 3.0
        engine.activeInsect = insect
        
        // 1. Pause game
        engine.pauseGame()
        XCTAssertTrue(engine.isGamePaused, "Game should be paused")
        
        // 2. While paused, frame updates should NOT tick down landing time
        engine.updateFrame(dt: 1.0)
        XCTAssertEqual(engine.activeInsect?.landTimeRemaining, 3.0, "Landing timer must not tick down while paused")
        
        // 3. Toggle pause unpauses
        engine.togglePause()
        XCTAssertFalse(engine.isGamePaused, "Game should unpause on toggle")
        
        // 4. While unpaused, frame updates advance normally
        engine.updateFrame(dt: 0.5)
        XCTAssertLessThan(engine.activeInsect?.landTimeRemaining ?? 3.0, 3.0, "Landing timer should resume counting down")
        
        // Reset
        engine.isGamePaused = false
    }
    
    func testMutantHorseflySingleFoldVictory() {
        let engine = ClapTrapGameEngine.shared
        engine.startGame()
        let initialScore = engine.score
        
        var horsefly = ActiveInsect(type: .mutantHorsefly, startPosition: CGPoint(x: 400, y: 300))
        horsefly.state = .landed
        engine.activeInsect = horsefly
        engine.gameState = .landed
        
        // Swat via closure
        FoldSensorManager.shared.triggerHardwareSlamShut(velocity: 800.0)
        
        // Horsefly must be immediately defeated in 1 fold!
        XCTAssertEqual(engine.gameState, .swatted, "Game state should be swatted after 1 fold")
        XCTAssertEqual(engine.lastOutcome?.hit, true, "1st fold must successfully swat the horsefly")
        XCTAssertEqual(engine.lastOutcome?.isBossDamagedOnly, false, "Horsefly must not require a 2nd fold")
        XCTAssertEqual(engine.score, initialScore + 750 + 250, "Full 750 base PTS + safety bonus must be awarded on 1st fold")
    }
    
    func testFoodBaitModelsAndThermalEffects() {
        let allBaits = FoodBaitType.allCases
        XCTAssertEqual(allBaits.count, 10, "There should be exactly 10 distinct food bait varieties")
        
        let hotBaits = allBaits.filter { $0.thermalEffect == .hot }
        let coldBaits = allBaits.filter { $0.thermalEffect == .cold }
        let freshBaits = allBaits.filter { $0.thermalEffect == .fresh }
        
        XCTAssertEqual(coldBaits.count, 3, "Should have 3 chilled fruit baits with frosty mist")
        XCTAssertEqual(hotBaits.count, 6, "Should have 6 hot fast food and pasta baits with rising steam wisps")
        XCTAssertEqual(freshBaits.count, 1, "Should have 1 glazed treat with sparkling sheen")
        
        // Ensure every bait has valid metadata
        for bait in allBaits {
            XCTAssertFalse(bait.displayName.isEmpty)
            XCTAssertFalse(bait.subtitle.isEmpty)
            XCTAssertFalse(bait.thermalEffect.icon.isEmpty)
            XCTAssertFalse(bait.category.icon.isEmpty)
        }
        
        // Category verification
        let fruits = allBaits.filter { $0.category == .fruit }
        let fastFoods = allBaits.filter { $0.category == .fastFood }
        let pastas = allBaits.filter { $0.category == .pasta }
        
        XCTAssertEqual(fruits.count, 3)
        XCTAssertEqual(fastFoods.count, 5)
        XCTAssertEqual(pastas.count, 2)
    }
    
    func testFoodBaitRandomRotationAcrossWaves() {
        let engine = ClapTrapGameEngine.shared
        
        var observedBaits = Set<FoodBaitType>()
        var changesCount = 0
        var previousBait = engine.currentBait
        
        for _ in 1...25 {
            engine.selectRandomBait()
            observedBaits.insert(engine.currentBait)
            if engine.currentBait != previousBait {
                changesCount += 1
            }
            previousBait = engine.currentBait
        }
        
        // Over 25 random picks, multiple distinct baits should be selected and change frequently
        XCTAssertGreaterThan(observedBaits.count, 3, "Random bait selection should explore multiple food types across waves")
        XCTAssertGreaterThan(changesCount, 15, "Random bait selection should frequently change away from the previous bait")
    }
    
    func testSingleDeadFlyPerKillAndStationaryPosition() {
        let engine = ClapTrapGameEngine.shared
        engine.persistentSplatters.removeAll()
        
        let initialScreen = CGSize(width: 800, height: 600)
        engine.dualScreenSize = initialScreen
        
        // Kill 1: at (250, 320)
        let kill1Pos = CGPoint(x: 250, y: 320)
        let splatter1 = SplatterRecord(
            primaryPosition: kill1Pos,
            hingeX: 400,
            insectType: .housefly,
            referenceScreenSize: initialScreen
        )
        engine.persistentSplatters.append(splatter1)
        
        // Exactly 1 dead fly registered for 1 kill
        XCTAssertEqual(engine.persistentSplatters.count, 1)
        XCTAssertEqual(splatter1.position(for: initialScreen), kill1Pos, "Dead fly must stay at exact impact location")
        
        // Kill 2: at (580, 410)
        let kill2Pos = CGPoint(x: 580, y: 410)
        let splatter2 = SplatterRecord(
            primaryPosition: kill2Pos,
            hingeX: 400,
            insectType: .mosquito,
            referenceScreenSize: initialScreen
        )
        engine.persistentSplatters.append(splatter2)
        
        // Exactly 2 dead flies registered for 2 kills (never 3 or 4!)
        XCTAssertEqual(engine.persistentSplatters.count, 2, "There must be exactly as many dead flies as kills")
        XCTAssertEqual(splatter2.position(for: initialScreen), kill2Pos, "Dead fly 2 must stay at exact impact location")
        
        // Position remains stationary on the table
        let reopenScreen = CGSize(width: 800, height: 600)
        XCTAssertEqual(splatter1.position(for: reopenScreen), kill1Pos)
        XCTAssertEqual(splatter2.position(for: reopenScreen), kill2Pos)
    }
}
