import math
import sys
import pygame as pg
import random

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
CAT_WIDTH = 200
CAT_HEIGHT = 212
CAT_POSITION = ((SCREEN_WIDTH - CAT_WIDTH) / 2, (SCREEN_HEIGHT - CAT_HEIGHT) / 2)
MOUSE_POSITION = CAT_POSITION
MOUSE_DIRECTION = 0 # 0 left; 1 right; 2 down; 3 up
LASER_RANGE = math.floor(CAT_WIDTH * 1.5)

def music():
    pg.mixer.init()
    pg.mixer.music.load("gaslampfunworks.ogg")
    pg.mixer.music.play(-1)

def loop():
    global CAT_POSITION
    global MOUSE_POSITION
    global MOUSE_DIRECTION

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

        if random.randint(0, 30) == 0:
            MOUSE_DIRECTION = random.randint(0, 3)
        MOUSE_POSITION = run_mouse_run()
        draw()
        clock.tick(15)

def draw():
    screen.fill((0, 0, 0))
    screen.blit(cat, CAT_POSITION)
    screen.blit(mouse, MOUSE_POSITION)
    cat_pos, mouse_pos, in_range = cat_laser_in_range(cat_center(), mouse_center())
    if in_range:
        pg.draw.line(screen, (255, 0, 0), cat_pos, mouse_pos, 5)
    pg.display.flip()

def set_cat_after_mouse():
    pos = pg.mouse.get_pos()
    pos = (pos[0] - CAT_WIDTH/2, pos[1] - CAT_HEIGHT/2)
    return pos

def run_mouse_run():
    padding = 60
    d = random.randint(1, 8)
    pos = MOUSE_POSITION
    if MOUSE_DIRECTION == 0:
        pos = (((pos[0] - d + padding) % SCREEN_WIDTH) - padding, pos[1])
    elif MOUSE_DIRECTION == 1:
        pos = (((pos[0] + d - padding) % SCREEN_WIDTH) + padding, pos[1])
    elif MOUSE_DIRECTION == 2:
        pos = (pos[0], ((pos[1] - d + padding) % SCREEN_HEIGHT) - padding)
    elif MOUSE_DIRECTION == 3:
        pos = (pos[0], ((pos[1] + d - padding) % SCREEN_HEIGHT) + padding)
    return pos

def cat_center():
    pos = CAT_POSITION
    pos = (pos[0] + CAT_WIDTH/2, pos[1] + CAT_HEIGHT/2)
    return pos

def mouse_center():
    pos = MOUSE_POSITION
    pos = (pos[0] + CAT_WIDTH/6, pos[1] +  CAT_HEIGHT/6) # mouse is 1/3 cat
    return pos

def cat_laser_in_range(cat_pos, mouse_pos):
    dist = (cat_pos[0] - mouse_pos[0])**2 + (cat_pos[1] - mouse_pos[1])**2
    result = dist < LASER_RANGE**2
    return cat_pos, mouse_pos, result

clock = pg.time.Clock()

screen = pg.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT), pg.DOUBLEBUF)
cat = pg.image.load('lasercat.png')
cat = pg.transform.smoothscale(cat, (CAT_WIDTH, CAT_HEIGHT))
mouse = pg.image.load('lasermouse.png')
mouse = pg.transform.smoothscale(mouse, (CAT_WIDTH/3, CAT_HEIGHT/3))

pg.mouse.set_visible(False)
pg.mouse.set_pos(set_cat_after_mouse())


if __name__ == '__main__':
    draw()
    music()
    loop()
