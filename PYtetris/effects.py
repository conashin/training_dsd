import os
import pygame

class TetrisEffects:
    def __init__(self, bgm_path="assets/bgm.mp3", clear_path="assets/clear.wav",
                 flash_img_path="assets/clear_flash.jpg", death_path="assets/death.wav",
                 death_img_path="assets/death_sceen.jpg"):
        pygame.mixer.init()
        self.bgm_path = bgm_path
        self.clear_path = clear_path
        self.death_path = death_path

        self.clear_sound = pygame.mixer.Sound(clear_path)
        self.clear_sound.set_volume(1.0)

        self.death_sound = pygame.mixer.Sound(death_path)
        self.death_sound.set_volume(1.0)

        # 預載圖片，縮放至遊戲視窗大小（300x600）
        if os.path.exists(flash_img_path):
            self.flash_image = pygame.image.load(flash_img_path)
            self.flash_image = pygame.transform.scale(self.flash_image, (300, 600))
        else:
            self.flash_image = None

        if os.path.exists(death_img_path):
            self.death_image = pygame.image.load(death_img_path)
            self.death_image = pygame.transform.scale(self.death_image, (300, 600))
        else:
            self.death_image = None

    def play_bgm(self):
        pygame.mixer.music.load(self.bgm_path)
        pygame.mixer.music.set_volume(0.5)
        pygame.mixer.music.play(-1)

    def pause_bgm(self):
        pygame.mixer.music.pause()

    def resume_bgm(self):
        pygame.mixer.music.unpause()

    def play_clear_effect_and_flash(self, screen, draw_func, grid, level, score, lines, next_piece, hold_piece, times=3):
        self.pause_bgm()
        self.clear_sound.play()

        for _ in range(times):
            draw_func(screen, grid, level, score, lines, next_piece, hold_piece)
            pygame.time.delay(100)
            screen.fill((0, 0, 0))
            pygame.display.update()
            pygame.time.delay(100)

        if self.flash_image:
            screen.blit(self.flash_image, (0, 0))
            pygame.display.update()
            pygame.time.delay(400)

        self.resume_bgm()

    def play_death_effect(self, screen):
        self.pause_bgm()
        self.death_sound.play()
        sound_len = int(self.death_sound.get_length() * 1000)

        if self.death_image:
            screen.blit(self.death_image, (0, 0))
            pygame.display.update()

        pygame.time.delay(sound_len)
