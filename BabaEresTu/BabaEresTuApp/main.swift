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

enum Tile {
  case Empty
  case Flag
  case Baba
  case Rock
  case Wall
  case TextWall
  case TextRock
  case TextFlag
  case TextBaba
  case TextIs
  case TextYou
  case TextWin
  case TextStop
  case TextPush
}

var level: [[Tile]] =
  [
    [
      .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty,
      .Empty, .Empty,
    ],
    [
      .Empty, .TextBaba, .TextIs, .TextYou, .Empty, .Empty, .Empty, .Empty, .Empty, .TextFlag,
      .TextIs, .TextWin, .Empty,
    ],
    [
      .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty,
      .Empty, .Empty,
    ],
    [.Empty, .Wall, .Wall, .Wall, .Wall, .Wall, .Wall, .Wall, .Wall, .Wall, .Wall, .Wall, .Empty],
    [
      .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Rock, .Empty, .Empty, .Empty, .Empty,
      .Empty, .Empty,
    ],
    [
      .Empty, .Empty, .Baba, .Empty, .Empty, .Empty, .Rock, .Empty, .Empty, .Empty, .Flag,
      .Empty, .Empty,
    ],
    [
      .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Rock, .Empty, .Empty, .Empty, .Empty,
      .Empty, .Empty,
    ],
    [.Empty, .Wall, .Wall, .Wall, .Wall, .Wall, .Wall, .Wall, .Wall, .Wall, .Wall, .Wall, .Empty],
    [
      .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty,
      .Empty, .Empty,
    ],
    [
      .Empty, .TextWall, .TextIs, .TextStop, .Empty, .Empty, .Empty, .Empty, .Empty, .TextRock,
      .TextIs, .TextPush, .Empty,
    ],
    [
      .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty,
      .Empty, .Empty,
    ],
  ]

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

  // Handle input ------------------------------------------------------------
  engine.handleInput = { [weak engine] in
    var event = SDL_Event()
    while SDL_PollEvent(&event) != 0 {
      if event.type == SDL_QUIT.rawValue {
        engine?.removeWindow(window)
        engine?.stop()
      }
    }
  }

  // Render ------------------------------------------------------------------
  engine.render = {
    renderer.result(of: SDL_SetRenderDrawColor, 0, 0, 0, 255)
    renderer.result(of: SDL_RenderClear)

    /* Draw your stuff */
    for j in 0..<level.count {
      for i in 0..<level.first!.count {
        let tile = level[j][i]
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
