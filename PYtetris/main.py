import pygame
from tetris import *
from effects import TetrisEffects

pygame.init()
screen = pygame.display.set_mode((SCREEN_WIDTH + 200, SCREEN_HEIGHT))
pygame.display.set_caption('Tetris')
clock = pygame.time.Clock()

def tetris_start():
    effects = TetrisEffects()
    effects.play_bgm()

    locked_positions = {}
    grid = create_grid(locked_positions)
    current_piece = get_shape()
    next_piece = get_shape()
    hold_piece = None
    hold_used = False
    change_piece = False
    fall_time = 0
    level, lines, score = 1, 0, 0
    fall_speed = 0.5

    def update_speed(level):
        return max(0.05, 0.5 - (level - 1) * 0.05)

    run = True
    while run:
        grid = create_grid(locked_positions)
        fall_time += clock.get_rawtime()
        clock.tick(60)
        if fall_time / 1000 >= fall_speed:
            fall_time = 0
            current_piece.y += 1
            if not valid_space(current_piece, grid):
                current_piece.y -= 1
                change_piece = True

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    run = False
                elif event.key == pygame.K_a:
                    current_piece.x -= 1
                    if not valid_space(current_piece, grid):
                        current_piece.x += 1
                elif event.key == pygame.K_d:
                    current_piece.x += 1
                    if not valid_space(current_piece, grid):
                        current_piece.x -= 1
                elif event.key == pygame.K_w:
                    current_piece.rotation = (current_piece.rotation + 1) % len(current_piece.shape)
                    if not valid_space(current_piece, grid):
                        current_piece.rotation = (current_piece.rotation - 1) % len(current_piece.shape)
                elif event.key == pygame.K_s:
                    current_piece.y += 1
                    if not valid_space(current_piece, grid):
                        current_piece.y -= 1
                elif event.key == pygame.K_SPACE:
                    while valid_space(current_piece, grid):
                        current_piece.y += 1
                    current_piece.y -= 1
                    change_piece = True
                elif event.key == pygame.K_c:
                    if not hold_used:
                        if hold_piece is None:
                            hold_piece = current_piece
                            current_piece = next_piece
                            next_piece = get_shape()
                        else:
                            hold_piece, current_piece = current_piece, hold_piece
                            current_piece.x, current_piece.y = 5, 0
                        hold_used = True

        for x, y in convert_shape_format(current_piece):
            if y >= 0:
                grid[y][x] = current_piece.color

        if change_piece:
            for pos in convert_shape_format(current_piece):
                locked_positions[(pos[0], pos[1])] = current_piece.color
            current_piece = next_piece
            next_piece = get_shape()
            change_piece = False
            hold_used = False

            cleared = clear_rows(grid, locked_positions)
            if cleared > 0:
                effects.play_clear_effect_and_flash(screen, draw_window, grid, level, score, lines, next_piece, hold_piece)
                lines += cleared
                score += SCORE_TABLE.get(cleared, cleared * 100)
                if lines >= level * 10:
                    level += 1
                    fall_speed = update_speed(level)

            if check_lost(locked_positions):
                effects.play_death_effect(screen)
                run = False

        draw_window(screen, grid, level, score, lines, next_piece, hold_piece)

    pygame.quit()

if __name__ == '__main__':
    tetris_start()