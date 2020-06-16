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
    ]
  ]

try SDL.Run { engine in
  // Start engine ------------------------------------------------------------
  try engine.start(subsystems: .video)

  // Create renderer ---------------------------------------------------------
  let (window, renderer) = try engine.addWindow(width: 640, height: 480)

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
    renderer.result(of: SDL_SetRenderDrawColor, 255, 0, 0, 255)
    renderer.result(of: SDL_RenderClear)

    /* Draw your stuff */

    renderer.pass(to: SDL_RenderPresent)
  }
}
