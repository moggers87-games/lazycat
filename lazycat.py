import sys
import pygame as pg

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
CAT_WIDTH = 200
CAT_HEIGHT = 212
CAT_POSITION = ((SCREEN_WIDTH - CAT_WIDTH) / 2, (SCREEN_HEIGHT - CAT_HEIGHT) / 2)

clock = pg.time.Clock()

def loop():
    while True:
        for e in pg.event.get():
            if e.type == pg.QUIT:
                pg.quit()
                sys.exit()
        clock.tick(15)

def draw():
    screen = pg.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT), pg.DOUBLEBUF)
    cat = pg.image.load('lasercat.png')
    cat = pg.transform.smoothscale(cat, (CAT_WIDTH, CAT_HEIGHT))
    screen.blit(cat, CAT_POSITION)
    pg.display.flip()

if __name__ == '__main__':
    draw()
    loop()
