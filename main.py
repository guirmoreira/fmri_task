import kivy
kivy.require('1.10.0')

from kivy.config import Config

Config.set('graphics', 'resizable', False)
Config.set('graphics', 'width', '600')
Config.set('graphics', 'height', '400')

from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.button import Button
from kivy.utils import get_color_from_hex
from kivy.core.window import Window
from kivy.uix.label import Label
from kivy.graphics import Color, Rectangle


Window.clearcolor = get_color_from_hex("#adadad")


def set_background_color(widget, color):
    with widget.canvas.before:
        Color(color[0], color[1], color[2])
        widget.rect = Rectangle(pos=widget.pos, size=widget.size)
        widget.color = [1, 1, 1, 1]

    def update_rect(instance, values):
        instance.rect.pos = instance.pos
        instance.rect.size = instance.size

    widget.bind(pos=update_rect, size=update_rect)


class Treinamento(FloatLayout):

    def __init__(self, **kwargs):
        super(Treinamento, self).__init__(**kwargs)
        # leitura do teclado
        self._keyboard = Window.request_keyboard(self._keyboard_closed, self)
        self._keyboard.bind(on_key_down=self._on_keyboard_down)
        # on0 com fundo vermelho
        set_background_color(self.ids.on0, [1, 0, 0])

    def _keyboard_closed(self):
        self._keyboard.unbind(on_key_down=self._on_keyboard_down)
        self._keyboard = None

    def _on_keyboard_down(self, keyboard, keycode, text, modifiers):
        if keycode[1] == '1':
            set_background_color(self.ids.on1, [1, 0, 0])
        elif keycode[1] == '4':
            set_background_color(self.ids.on4, [1, 0, 0])
        elif keycode[1] == '2':
            set_background_color(self.ids.on2, [1, 0, 0])
        elif keycode[1] == '3':
            set_background_color(self.ids.on3, [1, 0, 0])
            # scape
            # spacebar
        return True


class FmriTask(App):
    def build(self):
        return Treinamento()

janela = FmriTask()
janela.run()
