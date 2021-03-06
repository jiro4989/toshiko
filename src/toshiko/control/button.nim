# author: Ethosa
import
  ../core,
  ../nodes/node,
  ../graphics,
  control,
  label,
  strutils


type
  ButtonTouchHandler* = proc(self: ButtonRef, x, y: float): void
  ButtonObj* = object of LabelObj
    uppercase*: bool
    action_mask*: cint
    button_mask*: cint
    on_touch*: ButtonTouchHandler

    hover_background*: DrawableRef
    press_background*: DrawableRef
  ButtonRef* = ref ButtonObj


var standard_button_handler = proc(self: ButtonRef, x, y: float) = discard


proc Button*(name: string = "Button", text: string = "Button"): ButtonRef =
  ## Creates a new Button object.
  ##
  nodepattern(ButtonRef)
  controlpattern()
  result.text = stext(text)
  result.text_align = Anchor(0.5, 0.5, 0.5, 0.5)
  result.rect_size = Vector2(80, 40)
  result.hover_background = Drawable()
  result.hover_background.setColor(Color(1f, 1f, 1f, 0.05))
  result.press_background = Drawable()
  result.press_background.setColor(Color(1f, 1f, 1f, 0.1))
  result.on_touch = standard_button_handler
  result.uppercase = true
  result.action_mask = INPUT_BUTTON_RELEASE
  result.button_mask = INPUT_BUTTON_LEFT
  result.kind = BUTTON_NODE


method draw*(self: ButtonRef, w, h: float) =
  ## This method uses for redraw Button object.
  {.warning[LockLevel]: off.}
  self.calcRectGlobalPosition()
  let
    x = -w/2 + self.rect_global_position.x
    y = h/2 - self.rect_global_position.y

  if self.pressed:
    self.press_background.draw(x, y, self.rect_size.x, self.rect_size.y)
  elif self.hovered:
    self.hover_background.draw(x, y, self.rect_size.x, self.rect_size.y)
  else:
    self.background.draw(x, y, self.rect_size.x, self.rect_size.y)

  if self.uppercase:
    self.text.toUpper().render(Vector2(x, y), self.rect_size, self.text_align)
  else:
    self.text.render(Vector2(x, y), self.rect_size, self.text_align)

  if self.pressed:
    self.on_press(self, last_event.x, last_event.y)

method handle*(self: ButtonRef, event: InputEvent, mouse_on: var NodeRef) =
  ## This method uses for handle user input.
  if self.mousemode == MOUSEMODE_IGNORE:
    return
  let
    hasmouse = Rect2(self.rect_global_position, self.rect_size).contains(event.x, event.y)
    click = mouse_pressed and event.kind == MOUSE
  if mouse_on.isNil() and hasmouse:
    mouse_on = self
    # Hover
    if not self.hovered:
      self.on_hover(self, event.x, event.y)
      self.hovered = true
    # Focus
    if not self.focused and click:
      self.focused = true
      self.on_focus(self, event.x, event.y)
    # Click
    if mouse_pressed and not self.pressed:
      self.pressed = true
      self.on_click(self, event.x, event.y)
  elif not hasmouse or mouse_on != self:
    if not mouse_pressed and self.hovered:
      self.on_out(self, event.x, event.y)
      self.hovered = false
    # Unfocus
    if self.focused and click:
      self.on_unfocus(self, event.x, event.y)
      self.focused = false
  if not mouse_pressed and self.pressed:
    self.pressed = false
    self.on_release(self, event.x, event.y)

  if self.hovered and self.focused:
    if event.kind == MOUSE and self.action_mask == 1 and event.pressed and self.button_mask == event.button_index:
      self.on_touch(self, event.x, event.y)
    elif event.kind == MOUSE and self.action_mask == 0 and not event.pressed and self.button_mask == event.button_index:
      self.on_touch(self, event.x, event.y)

method getHoverBackground*(self: ButtonRef): DrawableRef {.base.} =
  self.hover_background

method getPressBackground*(self: ButtonRef): DrawableRef {.base.} =
  self.press_background

method setStyle*(self: ButtonRef, s: StyleSheetRef) =
  procCall self.ControlRef.setStyle(s)

  for i in s.dict:
    case i.key
    # uppercase: true
    # uppercase: yes
    of "uppercase":
      self.uppercase = parseBool(i.value)
    else:
      discard
