import sys
import pygame as pg

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
CAT_WIDTH = 200
CAT_HEIGHT = 212
CAT_POSITION = ((SCREEN_WIDTH - CAT_WIDTH) / 2, (SCREEN_HEIGHT - CAT_HEIGHT) / 2)
MOUSE_POSITION = CAT_POSITION

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
        draw()
        clock.tick(15)

def draw():
    screen.fill((0, 0, 0))
    screen.blit(cat, CAT_POSITION)
    screen.blit(mouse, MOUSE_POSITION)
    pg.draw.line(screen, (255, 0, 0), cat_center(), mouse_center(), 5)
    pg.display.flip()

def set_cat_after_mouse():
    pos = pg.mouse.get_pos()
    pos = (pos[0] - CAT_WIDTH/2, pos[1] - CAT_HEIGHT/2)
    return pos

def cat_center():
    pos = CAT_POSITION
    pos = (pos[0] + CAT_WIDTH/2, pos[1] + CAT_HEIGHT/2)
    return pos

def mouse_center():
    pos = MOUSE_POSITION
    pos = (pos[0] + CAT_WIDTH/6, pos[1] +  CAT_HEIGHT/6) # mouse is 1/3 cat
    return pos

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
