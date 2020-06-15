# author: Ethosa
import
  ../thirdparty/opengl,
  ../core,
  ../nodes/node,
  control


type
  ColorRectObj* = object of ConrolObj
    color*: ColorRef
  ColorRectRef* = ref ColorRectObj


proc ColorRect*(name: string = "ColorRect"): ColorRectRef =
  ## Creates a new ColorRect object.
  nodepattern(ColorRectRef)
  controlpattern()
  result.rect_size = Vector2(40, 40)
  result.color = Color(1f, 1f, 1f, 1f)
  result.kind = COLOR_RECT_NODE


method draw*(self: ColorRectRef, w, h: float) =
  ## This method uses for redraw ColorRect object.
  procCall self.ControlRef.draw(w, h)
  if self.drawable.background_color == Color(0, 0, 0, 0):
    let
      x = -w/2 + self.rect_global_position.x
      y = h/2 - self.rect_global_position.y
    glColor(self.color.r, self.color.g, self.color.b, self.color.a)
    glBegin(GL_QUADS)
    glVertex2f(x, y)
    glVertex2f(x + self.rect_size.x, y)
    glVertex2f(x + self.rect_size.x, y - self.rect_size.y)
    glVertex2f(x, y - self.rect_size.y)
    glEnd()
