//
//  GameScene.swift
//  IceBreaker
//
//  Created by Brandon Torres on 9/30/19.
//  Copyright © 2019 Funcade  LLC. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

enum GameState {
    case Playing
    case NotPlayedYet
    indirect case Paused(previousState: GameState)
    case Ended
    case Menu
}

protocol ModelDialogDelegate: class {
    func intermediateScreenDismissed()
}



class GameScene: SKScene, GamePlayDelegate, ModelDialogDelegate {
    
   var background: BackgroundNode!
       var boardNode: BoardNode!
       var gameLogic: GameLogic!
       var panGestureRecognizer: UIPanGestureRecognizer!
       var gameState: GameState = .NotPlayedYet
       var pauseNode: PauseNode!
       var gameEndNode: GameEndNode!
       var menuNode: MenuNode!
       var player: AVAudioPlayer?
       
       var soundOn: Bool = false
       var musicOn: Bool = false
       
    override func didMove(to view: SKView) {
        
          setUpPreferences()
           
           background = BackgroundNode(parentSize: view.frame.size)
           boardNode = BoardNode(parentSize: view.frame.size)
           background.addBoardNode(board: boardNode)
           gameLogic = GameLogic(boardDelegate: boardNode, gameScoreDelegate: nil, gamePlayDelegate: self)
           boardNode.boardTouchDelegate = gameLogic
           boardNode.presenterCallback = gameLogic
           background.addBoardTouchDelegate(boardTouchDelegate: gameLogic)
           
           gameLogic.gameScoreDelegate = background.display!
           if let view = self.view {
            panGestureRecognizer = UIPanGestureRecognizer(target: boardNode, action: Selector(("handlePan:")))
               view.addGestureRecognizer(panGestureRecognizer)
           }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
           appDelegate.gameScene = self
           pauseNode = PauseNode(parentSize: self.frame.size)
           pauseNode.delegate = self
           background.addChild(pauseNode)
           gameEndNode = GameEndNode(parentSize: self.frame.size)
           menuNode = MenuNode(parentSize: self.frame.size)
           gameEndNode.delegate = self
           gameEndNode.isHidden = true
           menuNode.isHidden = true
           menuNode.delegate = self
           menuNode.gameScoreDelegate = background.display!
           boardNode.soundDelegate = menuNode
           setupMusic()
           background.addChild(gameEndNode)
           background.addChild(menuNode)
        pauseNode.showScreen(parentSize: self.frame.size)
        background.curtain?.isUserInteractionEnabled = false
        panGestureRecognizer.isEnabled = false
           let defaults = UserDefaults.standard
        background.display!.setHighScore(highScore: defaults.integer(forKey: PreferencesKeys.highscoreKey))
           addChild(background)
       }
       
       private func setupMusic() {
        guard let bg_music_url = Bundle.main.url(forResource: "bg_music", withExtension: "wav") else {
               return
           }
           do {
            player = try AVAudioPlayer(contentsOf: bg_music_url)
               player?.numberOfLoops = -1
               boardNode.player = player
           } catch {
               return
           }
       }
       
       private func setUpPreferences() {
           let defaults = UserDefaults.standard
        if let _ = defaults.object(forKey: PreferencesKeys.soundKey) {
            soundOn = defaults.bool(forKey: PreferencesKeys.soundKey)
            musicOn = defaults.bool(forKey: PreferencesKeys.musicKey)
           } else {
               soundOn = true
               musicOn = true
            defaults.set(soundOn, forKey: PreferencesKeys.soundKey)
            defaults.set(musicOn, forKey: PreferencesKeys.musicKey)
            defaults.set(0, forKey: PreferencesKeys.highscoreKey)
           }
       }
       
    override func didChangeSize(_ oldSize: CGSize) {
           background?.relayout(parentSize: self.frame.size)
           pauseNode?.relayout(parentSize: self.frame.size)
           gameEndNode?.relayout(parentSize: self.frame.size)
           menuNode?.relayout(parentSize: self.frame.size)
       }

       var pauseHackToggled = true
       var lastUpdateTimeInterval: CFTimeInterval = 0
       
    override func update(_ currentTime: TimeInterval) {
            var delta = currentTime - lastUpdateTimeInterval
           lastUpdateTimeInterval = currentTime
           switch gameState {
           case .Paused(let pState):
               if !pauseHackToggled {
                   pauseHackToggled = true
                   switch pState {
                   case .Playing:
                    boardNode.isPaused = true
                    background.curtain?.isPaused = true
                   default:
                       break
                   }
               }
           case .Menu:
               if !pauseHackToggled {
                   pauseHackToggled = true
                boardNode.isPaused = true
                background.curtain?.isPaused = true
               }
           case .Playing:
               if delta > 1 {
                   delta = 1.0 / 60.0
               }
               background.display!.timePassed(delta: delta)
           default:
               break
           }
       }
       
       func pauseApp() {
           switch gameState {
           case .Paused(_):
               pauseHackToggled = false
           case .Menu:
               pauseHackToggled = false
           case .Ended:
               pauseHackToggled = false
               gameEndNode.tapLabel.removeAllActions()
               gameEndNode.tapLabel.alpha = 1
               // to pause bg music
               gameLogic.pause()
           case .Playing:
            background.curtain?.isUserInteractionEnabled = false
            panGestureRecognizer.isEnabled = false
            boardNode.isPaused = true
            background.curtain?.isPaused = true
               gameLogic.pause()
            pauseNode.isHidden = false
            pauseNode.showScreen(parentSize: self.frame.size)
               fallthrough
           default:
               pauseHackToggled = false
               gameState = .Paused(previousState: gameState)
           }
       }

       func resumeApp() {
           switch gameState {
           case .Ended:
               // to start bg music
               gameLogic.resume()
               gameEndNode?.touchEnabled = true
           default:
               break
           }
       }
       
       func resumeGame() {
           switch gameState {
           case .NotPlayedYet:
               fallthrough
           case .Ended:
            background.curtain?.isUserInteractionEnabled = true
            panGestureRecognizer.isEnabled = true
               gameLogic.startNewGame()
           case .Paused(let pState):
               switch pState {
               case .Playing:
                boardNode.isPaused = false
                   background.curtain?.isPaused = false
                   background.curtain?.isUserInteractionEnabled = true
                   panGestureRecognizer.isEnabled = true
                   gameLogic.resume()
                   fallthrough
               default:
                   gameState = pState
               }
           case .Playing:
               return
           case .Menu:
               boardNode.isPaused = false
               background.curtain?.isPaused = false
               background.curtain?.isUserInteractionEnabled = true
               panGestureRecognizer.isEnabled = true
               gameLogic.resume()
               gameState = .Playing
           }
           gameState = .Playing
       }
       
       // MARK: GamePlayDelegate
       
       func gameEnded(score: Int, newHighScore: Bool, board: Board, timeIsUp: Bool) {
        background.curtain?.isUserInteractionEnabled = false
        panGestureRecognizer.isEnabled = false
        gameEndNode.isHidden = false
           if newHighScore {
            let defaults = UserDefaults.standard
            defaults.set(score, forKey: PreferencesKeys.highscoreKey)
            background.display!.setHighScore(highScore: score)
           }
        gameEndNode.showScreen(score: score, newHighScore: newHighScore, parentSize: self.frame.size)
           gameState = .Ended
       }
       
       func menuPressed() {
        background.curtain?.isUserInteractionEnabled = false
        panGestureRecognizer.isEnabled = false
        boardNode.isPaused = true
           background.curtain?.isPaused = true
           gameLogic.pause()
           menuNode.isHidden = false
           menuNode.showScreen(parentSize: self.frame.size)
           pauseHackToggled = false
           gameState = .Menu
       }
       
       // MARK: ModelDialogDelegate
       
       func intermediateScreenDismissed() {
        pauseNode.isHidden = true
        gameEndNode.isHidden = true
        menuNode.isHidden = true
           resumeGame()
       }
}
