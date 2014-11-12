# -*- coding: utf-8 -*-
from __future__ import division

import math
import sys
import pygame as pg
import random

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
CAT_WIDTH = 200
CAT_HEIGHT = 212
CAT_POSITION = ((SCREEN_WIDTH - CAT_WIDTH) // 2, (SCREEN_HEIGHT - CAT_HEIGHT) // 2)
LASER_RANGE = math.floor(CAT_WIDTH * 1.5)

class Mouse(object):
    """A mouse!"""
    position = CAT_POSITION

    def __init__(self):
        self.image = pg.image.load('lasermouse.png')
        self.image = pg.transform.smoothscale(self.image,
            (CAT_WIDTH // 3, CAT_HEIGHT // 3)
        )

    @property
    def direction(self):
        # 0 left; 1 right; 2 down; 3 up
        return getattr(self, "_direction", 0)

    @direction.setter
    def direction(self, value):
        self._direction = value % 4

    @property
    def center(self):
        pos = self.position
        pos = (pos[0] + CAT_WIDTH//6, pos[1] +  CAT_HEIGHT//6) # mouse is 1/3 cat
        return pos

    def run_away(self):
        padding = 60
        d = random.randint(1, 10)
        pos = self.position
        if self.direction == 0:
            pos = (((pos[0] - d + padding) % SCREEN_WIDTH) - padding, pos[1])
        elif self.direction == 1:
            pos = (((pos[0] + d + padding) % SCREEN_WIDTH) - padding, pos[1])
        elif self.direction == 2:
            pos = (pos[0], ((pos[1] - d + padding) % SCREEN_HEIGHT) - padding)
        elif self.direction == 3:
            pos = (pos[0], ((pos[1] + d + padding) % SCREEN_HEIGHT) - padding)
        self.position = pos

MICE = [Mouse() for i in range(4)]

def music():
    pg.mixer.init()
    pg.mixer.music.load("gaslampfunworks.ogg")
    pg.mixer.music.play(-1)

def loop():
    global CAT_POSITION

    while True:
        for e in pg.event.get():
            if e.type == pg.QUIT:
                pg.quit()
                sys.exit()

        # keyboard logic
        key_pressed = pg.key.get_pressed()
        if key_pressed[pg.K_q] == 1 or key_pressed[pg.K_ESCAPE] == 1:
            pg.event.post(pg.event.Event(pg.QUIT))

        if pg.mouse.get_focused():
            CAT_POSITION = set_cat_after_mouse()

        for mouse in MICE:
            if random.randint(0, 30) == 0:
                mouse.direction = random.randint(0, 3)
            mouse.run_away()

        draw()
        clock.tick(24)

def draw():
    screen.fill((0, 0, 0))
    screen.blit(cat, CAT_POSITION)

    firing = False
    for mouse in MICE:
        rotation = 90 * mouse.direction
        r_mouse = pg.transform.rotate(mouse.image, rotation)
        r_mouse = pg.transform.rotate(r_mouse, random.randint(-5, 5))

        screen.blit(r_mouse, mouse.position)

        if True not in pg.mouse.get_pressed():
            if firing:
                firing = False
            continue
        elif firing:
            continue

        cat_pos, mouse_pos, in_range = cat_laser_in_range(cat_center(), mouse.center)
        if in_range:
            # magic numbers, manually guesstimated for eye centers
            pg.draw.line(screen, (255, 0, 0), (cat_pos[0]+42, cat_pos[1]), mouse_pos, 5)
            pg.draw.line(screen, (255, 0, 0), (cat_pos[0]-22, cat_pos[1]), mouse_pos, 5)
            firing = True

    pg.display.flip()

def set_cat_after_mouse():
    """Set cat to follow where the pointer would be"""
    pos = pg.mouse.get_pos()
    pos = (pos[0] - CAT_WIDTH//2, pos[1] - CAT_HEIGHT//2)
    return pos

def cat_center():
    pos = CAT_POSITION
    pos = (pos[0] + CAT_WIDTH//2, pos[1] + CAT_HEIGHT//2)
    return pos

def cat_laser_in_range(cat_pos, mouse_pos):
    dist = (cat_pos[0] - mouse_pos[0])**2 + (cat_pos[1] - mouse_pos[1])**2
    result = dist < LASER_RANGE**2
    return cat_pos, mouse_pos, result

clock = pg.time.Clock()

screen = pg.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT), pg.DOUBLEBUF)
pg.display.set_caption("L͏̷a̶͜z̸͘e҉̢ŕ͡G̴̶ư͡n͏͟!̨̕ H̶̶é͡ȩ̷h̶͏è̸e͡͝", "HE COMES!")

cat = pg.image.load('lasercat.png')
cat = pg.transform.smoothscale(cat, (CAT_WIDTH, CAT_HEIGHT))

pg.mouse.set_visible(False)
pg.mouse.set_pos(set_cat_after_mouse())


if __name__ == '__main__':
    draw()
    if "--mute" not in sys.argv and "-m" not in sys.argv:
        music()
    loop()
