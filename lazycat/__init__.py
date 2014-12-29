# -*- coding: utf-8 -*-
from __future__ import division

import math
import sys
import pygame as pg
import random
from pkg_resources import resource_stream

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
CAT_WIDTH = 200
CAT_HEIGHT = 212
CAT_POSITION = ((SCREEN_WIDTH - CAT_WIDTH) // 2, (SCREEN_HEIGHT - CAT_HEIGHT) // 2)
LASER_RANGE = math.floor(CAT_WIDTH * 1.5)


class Mouse(object):
    """A mouse!"""
    health = 100.0  # 100%
    position = CAT_POSITION

    def __init__(self):
        self.image = pg.image.load(resource_stream("lazycat", "assets/lasermouse.png"))
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

    def hit(self):
        """Hit the mouse"""
        self.health = self.health - 2.5

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
    pg.mixer.music.load(resource_stream("lazycat", "assets/gaslampfunworks.ogg"))
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

        if len(MICE) > 0 and len(MICE) <= 23 and random.randint(0, 50) == 0:
            new_mouse = Mouse()
            new_mouse.position = MICE[-1].position
            MICE.append(new_mouse)

        draw()
        clock.tick(24)

def draw():
    screen.fill((0, 0, 0))
    screen.blit(cat, CAT_POSITION)

    firing = True in pg.mouse.get_pressed()
    cat_pos = cat_center()
    nearest_mouse = None
    for mouse in MICE[:]:
        if mouse.health <= 0:
            MICE.remove(mouse)
        rotation = 90 * mouse.direction
        r_mouse = pg.transform.rotate(mouse.image, rotation)
        r_mouse = pg.transform.rotate(r_mouse, random.randint(-5, 5))

        screen.blit(r_mouse, mouse.position)

        mouse_dist = cat_laser_in_range(cat_pos, mouse.center)
        if mouse_dist is None or not firing:
            continue
        elif nearest_mouse is None:
            nearest_mouse = (mouse, mouse_dist)
        elif nearest_mouse is not None and mouse_dist < nearest_mouse[1]:
            nearest_mouse = (mouse, mouse_dist)

    if nearest_mouse is not None and firing:
        pg.draw.line(screen, (255, 0, 0), (cat_pos[0]+42, cat_pos[1]), nearest_mouse[0].center, 5)
        pg.draw.line(screen, (255, 0, 0), (cat_pos[0]-22, cat_pos[1]), nearest_mouse[0].center, 5)
        nearest_mouse[0].hit()

    if len(MICE) == 0:
        win_surf = winner.render("Winner!", True, (250, 50, 250))
        win_size = win_surf.get_size()
        win_pos = ((SCREEN_WIDTH - win_size[0]) // 2, (SCREEN_HEIGHT - win_size[1]) // 2)
        screen.blit(win_surf, win_pos)

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
    result = dist if dist < LASER_RANGE**2 else None
    return result

clock = pg.time.Clock()

screen = pg.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT), pg.DOUBLEBUF)
pg.display.set_caption("L͏̷a̶͜z̸͘e҉̢ŕ͡G̴̶ư͡n͏͟!̨̕ H̶̶é͡ȩ̷h̶͏è̸e͡͝", "HE COMES!")

cat = pg.image.load(resource_stream("lazycat", "assets/lasercat.png"))
cat = pg.transform.smoothscale(cat, (CAT_WIDTH, CAT_HEIGHT))

pg.font.init()
winner = pg.font.SysFont("mono", 150, bold=True)

pg.mouse.set_visible(False)
pg.mouse.set_pos(set_cat_after_mouse())

def main():
    draw()
    if "--mute" not in sys.argv and "-m" not in sys.argv:
        music()
    loop()
