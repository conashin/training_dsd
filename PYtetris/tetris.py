import pygame
import random

BLACK = (0, 0, 0)
GRAY = (128, 128, 128)
WHITE = (255, 255, 255)
BLOCK_SIZE = 30
SCREEN_WIDTH, SCREEN_HEIGHT = 300, 600

COLORS = [
    (0, 255, 255), (255, 255, 0), (128, 0, 128),
    (0, 255, 0), (255, 0, 0), (0, 0, 255), (255, 165, 0)
]

SHAPES = [
    # I
    [['..O..',
      '..O..',
      '..O..',
      '..O..',
      '.....'],
     ['.....',
      '.OOOO',
      '.....',
      '.....',
      '.....']],

    # O
    [['.....',
      '.....',
      '..OO.',
      '..OO.',
      '.....']],

    # T
    [['.....',
      '..O..',
      '.OOO.',
      '.....',
      '.....'],
     ['.....',
      '..O..',
      '..OO.',
      '..O..',
      '.....'],
     ['.....',
      '.....',
      '.OOO.',
      '..O..',
      '.....'],
     ['.....',
      '..O..',
      '.OO..',
      '..O..',
      '.....']],

    # S
    [['.....',
      '.....',
      '..OO.',
      '.OO..',
      '.....'],
     ['..O..',
      '..OO.',
      '...O.',
      '.....',
      '.....']],

    # Z
    [['.....',
      '.....',
      '.OO..',
      '..OO.',
      '.....'],
     ['..O..',
      '.OO..',
      '.O...',
      '.....',
      '.....']],

    # J
    [['.....',
      '.O...',
      '.OOO.',
      '.....',
      '.....'],
     ['.....',
      '..OO.',
      '..O..',
      '..O..',
      '.....'],
     ['.....',
      '.....',
      '.OOO.',
      '...O.',
      '.....'],
     ['.....',
      '..O..',
      '..O..',
      '.OO..',
      '.....']],

    # L
    [['.....',
      '...O.',
      '.OOO.',
      '.....',
      '.....'],
     ['.....',
      '..O..',
      '..O..',
      '..OO.',
      '.....'],
     ['.....',
      '.....',
      '.OOO.',
      '.O...',
      '.....'],
     ['.....',
      '.OO..',
      '..O..',
      '..O..',
      '.....']]
]

SCORE_TABLE = {1: 100, 2: 300, 3: 500, 4: 800}

class Piece:
    def __init__(self, x, y, shape, color):
        self.x = x
        self.y = y
        self.shape = shape
        self.color = color
        self.rotation = 0

def create_grid(locked_positions={}):
    grid = [[BLACK for _ in range(10)] for _ in range(20)]
    for (x, y), color in locked_positions.items():
        if y > -1:
            grid[y][x] = color
    return grid

def convert_shape_format(piece):
    positions = []
    format = piece.shape[piece.rotation % len(piece.shape)]
    for i, line in enumerate(format):
        for j, char in enumerate(line):
            if char == 'O':
                positions.append((piece.x + j - 2, piece.y + i - 4))
    return positions

def valid_space(piece, grid):
    accepted_positions = [[(j, i) for j in range(10) if grid[i][j] == BLACK] for i in range(20)]
    accepted_positions = [pos for sub in accepted_positions for pos in sub]
    for pos in convert_shape_format(piece):
        if pos not in accepted_positions and pos[1] > -1:
            return False
    return True

def check_lost(positions):
    for x, y in positions:
        if y < 1:
            return True
    return False

def get_shape():
    index = random.randint(0, len(SHAPES) - 1)
    return Piece(5, 0, SHAPES[index], COLORS[index])

def clear_rows(grid, locked):
    cleared_rows = []
    for i in range(len(grid) - 1, -1, -1):
        if BLACK not in grid[i]:
            cleared_rows.append(i)
            for j in range(len(grid[i])):
                try:
                    del locked[(j, i)]
                except:
                    continue

    if cleared_rows:
        for row in sorted(cleared_rows):
            for key in sorted(list(locked.keys()), key=lambda x: x[1], reverse=True):
                x, y = key
                if y < row:
                    while (x, y + 1) in locked:
                        y += 1
                    locked[(x, y + 1)] = locked.pop(key)

    return len(cleared_rows)

def draw_grid(surface, grid):
    for i in range(len(grid)):
        for j in range(len(grid[i])):
            pygame.draw.rect(surface, grid[i][j], (j * BLOCK_SIZE, i * BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE))
    for i in range(21):
        pygame.draw.line(surface, GRAY, (0, i * BLOCK_SIZE), (SCREEN_WIDTH, i * BLOCK_SIZE))
    for j in range(11):
        pygame.draw.line(surface, GRAY, (j * BLOCK_SIZE, 0), (j * BLOCK_SIZE, SCREEN_HEIGHT))

def draw_next_piece(surface, piece):
    font = pygame.font.SysFont('Arial', 20)
    label = font.render("Next:", True, (255, 255, 255))
    surface.blit(label, (SCREEN_WIDTH + 10, 20))
    format = piece.shape[piece.rotation % len(piece.shape)]
    for i, line in enumerate(format):
        for j, char in enumerate(line):
            if char == 'O':
                pygame.draw.rect(surface, piece.color, (SCREEN_WIDTH + 10 + j * 20, 50 + i * 20, 20, 20))

def draw_hold_piece(surface, piece):
    font = pygame.font.SysFont('Arial', 20)
    label = font.render("Hold:", True, (255, 255, 255))
    surface.blit(label, (SCREEN_WIDTH + 10, 270))
    if piece:
        format = piece.shape[piece.rotation % len(piece.shape)]
        for i, line in enumerate(format):
            for j, char in enumerate(line):
                if char == 'O':
                    pygame.draw.rect(surface, piece.color, (SCREEN_WIDTH + 10 + j * 20, 300 + i * 20, 20, 20))

def draw_window(surface, grid, level, score, lines, next_piece, hold_piece):
    surface.fill(BLACK)
    draw_grid(surface, grid)
    font = pygame.font.SysFont('Arial', 24)
    draw_next_piece(surface, next_piece)
    draw_hold_piece(surface, hold_piece)
    surface.blit(font.render(f'Level: {level}', True, WHITE), (SCREEN_WIDTH + 10, 160))
    surface.blit(font.render(f'Score: {score}', True, WHITE), (SCREEN_WIDTH + 10, 190))
    surface.blit(font.render(f'Lines: {lines}', True, WHITE), (SCREEN_WIDTH + 10, 220))
    pygame.display.update()
