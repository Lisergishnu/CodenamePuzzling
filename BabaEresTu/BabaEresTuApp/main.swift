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

struct LevelPosition {
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
}

func readRulesForThisStep() -> [Adjective: [Tile]] {
  let rules: [Adjective: [Tile]] = [.You: [.Baba], .Stop: [.Wall, .Rock]]

  return rules
}

// MARK: Movement

func moveYou(using di: Int, and dj: Int) {
  let rules = readRulesForThisStep()
  guard let affectedTiles = rules[.You] else {
    return
  }

  for affectedTile in affectedTiles {
    for position in level.getPositions(of: affectedTile) {
      let nextPosition = LevelPosition(i: position.i + di, j: position.j + dj)
      if level.canMove(to: nextPosition) {
        move(tile: affectedTile, from: position, to: nextPosition)
      }
    }
  }
}

func move(tile: Tile, from startingPosition: LevelPosition, to endPosition: LevelPosition) {
  level.remove(tile: tile, at: startingPosition)
  level.add(tile: tile, at: endPosition)
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
