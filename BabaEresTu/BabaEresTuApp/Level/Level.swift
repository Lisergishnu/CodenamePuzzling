//
//  Level.swift
//  BabaEresTuApp
//
//  Created by Marco Benzi Tobar on 23-06-20.
//  Copyright © 2020 LiserCorp. All rights reserved.
//

import Foundation

// MARK: - Tile

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

// MARK: - Level Square

typealias LevelSquare = [Tile]

// MARK: - Level

class Level {

  // MARK: Properties

  var height: Int {
    return level.count
  }
  var width: Int {
    return level.first!.count
  }
  private var level: [[LevelSquare]] =
    [
      [
        [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty],
        [.Empty], [.Empty],
      ],
      [
        [.Empty], [.TextBaba], [.TextIs], [.TextYou], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.TextFlag],
        [.TextIs], [.TextWin], [.Empty],
      ],
      [
        [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty],
        [.Empty], [.Empty],
      ],
      [
        [.Empty], [.Wall], [.Wall], [.Wall], [.Wall], [.Wall], [.Wall], [.Wall], [.Wall], [.Wall], [.Wall], [.Wall], [.Empty],
      ],
      [
        [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Rock], [.Empty], [.Empty], [.Empty], [.Empty],
        [.Empty], [.Empty],
      ],
      [
        [.Empty], [.Empty], [.Baba], [.Empty], [.Empty], [.Empty], [.Rock], [.Empty], [.Empty], [.Empty], [.Flag],
        [.Empty], [.Empty],
      ],
      [
        [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Rock], [.Empty], [.Empty], [.Empty], [.Empty],
        [.Empty], [.Empty],
      ],
      [
        [.Empty], [.Wall], [.Wall], [.Wall], [.Wall], [.Wall], [.Wall], [.Wall], [.Wall], [.Wall], [.Wall], [.Wall], [.Empty],
      ],
      [
        [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty],
        [.Empty], [.Empty],
      ],
      [
        [.Empty], [.TextWall], [.TextIs], [.TextStop], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.TextRock],
        [.TextIs], [.TextPush], [.Empty],
      ],
      [
        [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty], [.Empty],
        [.Empty], [.Empty],
      ],
  ]

  // MARK: Public API

  func tiles(at position: LevelPosition) -> [Tile] {
    return level[position.j][position.i]
  }

  func add(tile: Tile, at position: LevelPosition) {
    level[position.j][position.i].append(tile)
  }

  func remove(tile: Tile, at position: LevelPosition) {
    let localTiles = self.tiles(at: position)
    if localTiles.contains(tile) {
      level[position.j][position.i].removeAll { $0 == tile }
      if level[position.j][position.i].isEmpty {
        add(tile: .Empty, at: position)
      }
    }
  }

  func getPositions(of tile: Tile) -> [LevelPosition] {
    var positions: [LevelPosition] = []
    for j in 0..<height {
      for i in 0..<width {
        if level[j][i].contains(tile) {
          positions.append(LevelPosition(i: i, j: j))
        }
      }
    }
    return positions
  }

  func canPlayerMove(to position: LevelPosition) -> Bool {
    if position.i < 0 || position.j < 0 || position.i >= width || position.j >= height {
      return false
    }

    if let stopTiles = readRulesForThisStep()[.Stop] {
      let tilesAtPosition = tiles(at: position)
      for tile in tilesAtPosition {
        if stopTiles.contains(tile) {
          return false
        }
      }
    }

    return true
  }
}
