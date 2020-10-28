//
//  main.swift
//  BabaEresTu
//
//  Created by Marco Benzi Tobar on 16-06-20.
//  Copyright © 2020 LiserCorp. All rights reserved.
//

import CSDL2
import Foundation
import SwiftSDL2

// MARK: - Math

struct LevelPosition: Equatable {
  var i: Int
  var j: Int

}

// MARK: - Extensions

extension SDLTexture {

  static func loadWholeTexture(
    into: SDLRenderer,
    resourceURL: URL,
    texturesNamed: String
  ) throws -> SDLTexture? {
    return try load(into: into, resourceURL: resourceURL, texturesNamed: texturesNamed)[
      texturesNamed
    ]
  }

}

// MARK: - Level

var level: Level = Level()

// MARK: - Rules

enum Adjective {
  case You
  case Stop
  case Win
  case Push
}

var rules: [Adjective: [Tile]] = [
  .You: [.Baba],
  .Stop: [.Wall],
  .Win: [.Flag],
  .Push: [.Rock, .TextIs, .TextWin, .TextYou, .TextBaba, .TextFlag, .TextPush, .TextRock, .TextStop]
]

func readRulesForThisStep() -> [Adjective: [Tile]] {
  return rules
}

func getNounsBasedOnTextTiles(at position: LevelPosition) -> [Tile] {
  var nounTiles: [Tile] = []
  let nounTextTiles = level.tiles(at: position)
  if nounTextTiles.contains(.TextBaba) {
    nounTiles.append(.Baba)
  }
  if nounTextTiles.contains(.TextFlag) {
    nounTiles.append(.Flag)
  }
  if nounTextTiles.contains(.TextRock) {
    nounTiles.append(.Rock)
  }
  if nounTextTiles.contains(.TextWall) {
    nounTiles.append(.Wall)
  }

  return nounTiles
}

func getAffectedNouns(for textAdjective: Tile) -> [Tile] {
  let adjectivePositions = level.getPositions(of: textAdjective)
  var nounTiles: [Tile] = []
  for position in adjectivePositions {
    let upperPosition = LevelPosition(i: position.i, j: position.j - 1)
    let upperUpperPosition = LevelPosition(i: position.i, j: position.j - 2)
    let leftPosition = LevelPosition(i: position.i - 1, j: position.j)
    let leftLeftPosition = LevelPosition(i: position.i - 2, j: position.j)
    if level.tiles(at: upperPosition).contains(.TextIs) {
      nounTiles += getNounsBasedOnTextTiles(at: upperUpperPosition)
    }
    if level.tiles(at: leftPosition).contains(.TextIs) {
      nounTiles += getNounsBasedOnTextTiles(at: leftLeftPosition)
    }
  }

  return nounTiles
}

func performAfterStepRuleCheckAndModification() {
  // Write rules
  rules[.You] = getAffectedNouns(for: .TextYou)
  rules[.Stop] = getAffectedNouns(for: .TextStop)
  rules[.Win] = getAffectedNouns(for: .TextWin)
  rules[.Push] = getAffectedNouns(for: .TextPush)

  // Also all text is push at all times
  rules[.Push]?.append(contentsOf: [.TextIs, .TextWin, .TextYou, .TextBaba, .TextFlag, .TextPush, .TextRock, .TextStop])
}

// MARK: Pushing

func pushPush(using di: Int, and dj: Int, startingFrom position: LevelPosition, considering rules: [Adjective: [Tile]]) -> Bool {
  // push tiene 3 reglas
  // 1.- si la cosa que se tiene que mover apunta a un lugar vacio se mueve
  // 2.- si la cosa en la direccion de movimiento es inmovible, entonces nada
  // 3.- si la cosa es push, repetir estas reglas sobre ese tile (recursion)
  guard let pushTiles = rules[.Push] else {
    return false
  }

  if level.isOutOfBounds(position: position) {
    return false
  }

  let tiles = level.tiles(at: position)
  for tile in tiles {
    if pushTiles.contains(tile) {
      // Tenemos otro push, revisar al lado
      let newPos = LevelPosition(i: position.i + di, j: position.j + dj)
      if pushPush(using: di, and: dj, startingFrom: newPos, considering: rules) {
        level.remove(tile: tile, at: position)
        level.add(tile: tile, at: newPos)
      }
    } else {
      if let stopTiles = rules[.Stop] {
        if stopTiles.contains(tile) {
          return false
        }
      }
    }
  }
  return true
}

// MARK: Movement

func moveYou(using di: Int, and dj: Int) {
  let rules = readRulesForThisStep()
  guard let youTiles = rules[.You] else {
    return
  }

  for youTile in youTiles {
    var orderedTilePositions = level.getPositions(of: youTile)
    if di > 0 || dj > 0 {
      orderedTilePositions.reverse()
    }

    for position in orderedTilePositions {
      let nextPosition = LevelPosition(i: position.i + di, j: position.j + dj)
      // Push rule
      let _ = pushPush(using: di, and: dj, startingFrom: nextPosition, considering: rules)

      // Move
      if level.canPlayerMove(to: nextPosition) {
        level.remove(tile: youTile, at: position)
        level.add(tile: youTile, at: nextPosition)
      }
    }
  }
  // Here you would advance one "puzzle step"
  // Check win condition
  if checkIfPlayerHasWon() {
    print("Player won!")
  }

  // Check rule state for next step
  performAfterStepRuleCheckAndModification()

}

// MARK: - Winning

func checkIfPlayerHasWon() -> Bool {
  // WARN: Rules should only be calculated once at every puzzle step
  let rules = readRulesForThisStep()
  guard let youTiles = rules[.You], let winTiles = rules[.Win] else {
    return false
  }

  for youTile in youTiles {
    let youPositions = level.getPositions(of: youTile)
    for winTile in winTiles {
      let winPosition = level.getPositions(of: winTile)
      for position in winPosition {
        if youPositions.contains(position) {
          return true
        }
      }
    }
  }

  return false
}

// MARK: - SDL

try SDL.Run { engine in
  // Start engine ------------------------------------------------------------
  try engine.start(subsystems: .video)

  // Create renderer ---------------------------------------------------------
  let (window, renderer) = try engine.addWindow(
    title: "Baba Eres Tu",
    width: 640,
    height: 480,
    windowFlags: .allowHighDPI,
    renderFlags: [.targetTexturing, .verticalSync]
  )

  // MARK: - Load resources

  let babaTexture = try SDLTexture.loadWholeTexture(
    into: renderer,
    resourceURL: Bundle.main.resourceURL!,
    texturesNamed: "Baba.png"
  )
  let flagTexture = try SDLTexture.loadWholeTexture(
    into: renderer,
    resourceURL: Bundle.main.resourceURL!,
    texturesNamed: "Flag.png"
  )
  let rockTexture = try SDLTexture.loadWholeTexture(
    into: renderer,
    resourceURL: Bundle.main.resourceURL!,
    texturesNamed: "Rock.png"
  )
  let textBabaTexture = try SDLTexture.loadWholeTexture(
    into: renderer,
    resourceURL: Bundle.main.resourceURL!,
    texturesNamed: "TextBaba.png"
  )
  let textFlagTexture = try SDLTexture.loadWholeTexture(
    into: renderer,
    resourceURL: Bundle.main.resourceURL!,
    texturesNamed: "TextFlag.png"
  )
  let textIsTexture = try SDLTexture.loadWholeTexture(
    into: renderer,
    resourceURL: Bundle.main.resourceURL!,
    texturesNamed: "TextIs.png"
  )
  let textPushTexture = try SDLTexture.loadWholeTexture(
    into: renderer,
    resourceURL: Bundle.main.resourceURL!,
    texturesNamed: "TextPush.png"
  )
  let textRockTexture = try SDLTexture.loadWholeTexture(
    into: renderer,
    resourceURL: Bundle.main.resourceURL!,
    texturesNamed: "TextRock.png"
  )
  let textStopTexture = try SDLTexture.loadWholeTexture(
    into: renderer,
    resourceURL: Bundle.main.resourceURL!,
    texturesNamed: "TextStop.png"
  )
  let textWallTexture = try SDLTexture.loadWholeTexture(
    into: renderer,
    resourceURL: Bundle.main.resourceURL!,
    texturesNamed: "TextWall.png"
  )
  let textWinTexture = try SDLTexture.loadWholeTexture(
    into: renderer,
    resourceURL: Bundle.main.resourceURL!,
    texturesNamed: "TextWin.png"
  )
  let textYouTexture = try SDLTexture.loadWholeTexture(
    into: renderer,
    resourceURL: Bundle.main.resourceURL!,
    texturesNamed: "TextYou.png"
  )
  let wallTexture = try SDLTexture.loadWholeTexture(
    into: renderer,
    resourceURL: Bundle.main.resourceURL!,
    texturesNamed: "Wall.png"
  )

  // MARK: - Input
  engine.handleInput = { [weak engine] in
    var event = SDL_Event()
    while SDL_PollEvent(&event) != 0 {
      if event.type == SDL_QUIT.rawValue {
        engine?.removeWindow(window)
        engine?.stop()
      }
      else if event.type == SDL_KEYDOWN.rawValue {
        if event.key.keysym.sym == SDLK_LEFT.rawValue {
          // move left
          moveYou(using: -1, and: 0)
        }
        else if event.key.keysym.sym == SDLK_RIGHT.rawValue {
          // move right
          moveYou(using: 1, and: 0)
        }
        else if event.key.keysym.sym == SDLK_UP.rawValue {
          // move up
          moveYou(using: 0, and: -1)
        }
        else if event.key.keysym.sym == SDLK_DOWN.rawValue {
          // move down
          moveYou(using: 0, and: 1)
        }
      }
    }
  }

  // MARK: - Render
  engine.render = {
    renderer.result(of: SDL_SetRenderDrawColor, 0, 0, 0, 255)
    renderer.result(of: SDL_RenderClear)

    /* Draw your stuff */
    for j in 0..<level.height {
      for i in 0..<level.width {
        for tile in level.tiles(at: LevelPosition(i: i, j: j)) {
          var textureToDraw: SDLTexture? = nil
          switch tile {
          case .Baba:
            textureToDraw = babaTexture
          case .Flag:
            textureToDraw = flagTexture
          case .Rock:
            textureToDraw = rockTexture
          case .TextBaba:
            textureToDraw = textBabaTexture
          case .TextFlag:
            textureToDraw = textFlagTexture
          case .TextIs:
            textureToDraw = textIsTexture
          case .TextPush:
            textureToDraw = textPushTexture
          case .TextRock:
            textureToDraw = textRockTexture
          case .TextStop:
            textureToDraw = textStopTexture
          case .TextWall:
            textureToDraw = textWallTexture
          case .TextWin:
            textureToDraw = textWinTexture
          case .TextYou:
            textureToDraw = textYouTexture
          case .Wall:
            textureToDraw = wallTexture
          default: break
          }

          draw(texture: textureToDraw, at: i, and: j, using: renderer)
        }
      }
    }

    renderer.pass(to: SDL_RenderPresent)
  }
}

// MARK: - Helper functions

func draw(texture: SDLTexture?, at row: Int, and column: Int, using renderer: SDLRenderer) {
  let textureSize = SDL_Rect(x: 0, y: 0, w: 32, h: 32)
  renderer.copy(
    from: texture,
    within: textureSize,
    into: SDL_Rect(x: Int32(row * 32), y: Int32(column * 32), w: 32, h: 32),
    rotatedBy: 0,
    aroundCenter: nil,
    flipped: .none
  )
}
