import sys
import pygame as pg

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
CAT_WIDTH = 200
CAT_HEIGHT = 212
CAT_POSITION = ((SCREEN_WIDTH - CAT_WIDTH) / 2, (SCREEN_HEIGHT - CAT_HEIGHT) / 2)

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
        if pg.mouse.get_focused():
            CAT_POSITION = set_cat_after_mouse()
        draw()
        clock.tick(15)

def draw():
    screen.fill((0, 0, 0))
    screen.blit(cat, CAT_POSITION)
    pg.display.flip()

def set_cat_after_mouse():
    pos = pg.mouse.get_pos()
    pos = (pos[0] - CAT_WIDTH/2, pos[1] -  CAT_HEIGHT/2)
    return pos

clock = pg.time.Clock()

screen = pg.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT), pg.DOUBLEBUF)
cat = pg.image.load('lasercat.png')
cat = pg.transform.smoothscale(cat, (CAT_WIDTH, CAT_HEIGHT))

pg.mouse.set_visible(False)
pg.mouse.set_pos(set_cat_after_mouse())


if __name__ == '__main__':
    draw()
    music()
    loop()
