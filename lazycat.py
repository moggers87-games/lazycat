import sys
import pygame as pg

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600

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
    screen.blit(cat, (0, 0))
    pg.display.flip()

if __name__ == '__main__':
    draw()
    loop()
