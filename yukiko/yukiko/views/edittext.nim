# author: Ethosa
from strutils import join, split
import asyncdispatch
import sdl2
import sdl2/ttf

import view
import textview
import ../text/spantext


type
  EditTextObj = object of TextViewObj
    ctrl_pressed*: bool
    hint_color*: uint32
    caret*: uint
    hint*: cstring
  EditTextRef* = ref EditTextObj


proc EditText*(width, height: cint, x: cint = 0, y: cint = 0,
               font: cstring = "sans-serif", font_size: cint = 12,
               parent: SurfacePtr = nil): EditTextRef {.inline.} =
  ## Creates a new EditTextRef object.
  ##
  ## Arguments:
  ## -   ``width`` -- view width.
  ## -   ``height`` -- view height.
  ## -   ``x`` -- X position in parent view.
  ## -   ``y`` -- Y position in parent view.
  ## -   ``parent`` -- parent view.
  viewInitializer(EditTextRef)
  result.font = openFont(font, font_size)
  result.font_name = font
  result.font_size = font_size
  result.style = TTF_STYLE_NORMAL
  result.hint = "Edit text ..."
  result.hint_color = 0x434343
  result.caret = 0
  result.ctrl_pressed = false

method setHint*(edittext: EditTextRef, hint: cstring) {.async, base.} =
  ## Changes EditText's hint.
  ##
  ## Arguments:
  ## -   ``hint`` -- new hint.
  edittext.hint = hint

method setHintColor*(edittext: EditTextRef, color: uint32) {.async, base.} =
  ## Changes EditText hint color.
  ##
  ## Arguments:
  ## -   ``color`` -- new hint color.
  edittext.hint_color = color

method setText*(edittext: EditTextRef, text: cstring) {.async.} =
  ## Redraws the EditText's text.
  ##
  ## If text is empty, then draws hint with hint color.
  ##
  ## Arguments:
  ## -   ``text`` -- new text.
  if text.len == 0:
    edittext.text = text
    edittext.background.fillRect(nil, 0x00000000)
    blitSurface(edittext.saved_background, nil, edittext.background, nil)
    var rendered = edittext.font.renderUtf8BlendedWrapped(
      edittext.hint, await parseColor(edittext.hint_color.int), 1024)
    var rect = rect(edittext.x, edittext.y, rendered.w, rendered.h)
    blitSurface(rendered, nil, edittext.background, rect.addr)
    discard
  else:
    await procCall edittext.TextViewRef.setText(text)

method setText*(edittext: EditTextRef, text: SpanTextObj) {.async.} =
  ## Redraws the EditText's text.
  ##
  ## Arguments:
  ## -   ``text`` -- new text.
  if text.len == 0:
    edittext.text = $text
    edittext.background.fillRect(nil, 0x00000000)
    blitSurface(edittext.saved_background, nil, edittext.background, nil)
    var rendered = edittext.font.renderUtf8BlendedWrapped(
      edittext.hint, await parseColor(edittext.hint_color.int), 1024)
    var rect = rect(edittext.x, edittext.y, rendered.w, rendered.h)
    blitSurface(rendered, nil, edittext.background, rect.addr)
    discard
  else:
    await procCall edittext.TextViewRef.setText(text)

method event*(edittext: EditTextRef, views: seq[ViewRef], event: Event) {.async.} =
  ## Handles user input.
  ##
  ## Now available:
  ## -  `text input`
  ## -  `arrows control`
  ## -  `chars delete via backspace`
  ## -  `chars delete via CTRL + backspace`
  await procCall edittext.ViewRef.event(views, event)
  if edittext.has_focus and event.kind == TextInput:
    # Here user input writes in EditText.
    let
      e = text event
      text = $(await edittext.getText())
    if text.len > 0:
      await edittext.setText(text[0..edittext.caret-1] & join(e.text[0..8]))
      let text1 = $(await edittext.getText())
      await edittext.setText(text1 & text[edittext.caret..^1])
    else:
      await edittext.setText(text & join(e.text[0..8]))
    edittext.caret += 1
  elif edittext.has_focus and event.kind == KeyDown:
    # Here keyboard handles.
    let key = event.key.keysym.sym
    case key
    of 13:  # Enter
      let text = $(await edittext.getText())
      if text.len > 0:
        await edittext.setText(text[0..edittext.caret-1] & "\n" & text[edittext.caret..^1])
      else:
        await edittext.setText(text & "\n")
      edittext.caret += 1
    of 8:  # Backspace
      let text = $(await edittext.getText())
      if text.len > 0:
        if not edittext.ctrl_pressed:  # When CTRL is not pressed.
          await edittext.setText(text[0..edittext.caret-2] & text[edittext.caret..^1])
          if edittext.caret.int > 0:
            edittext.caret -= 1
        else:  # When CTRL is pressed.
          let res = text[0..edittext.caret-1].split(" ")
          if res.len > 1:
            let
              t = join(res[0..^2], " ")
              word_length = res[^2].len.uint
            await edittext.setText(t & text[edittext.caret..^1])
            if edittext.caret > word_length:
              edittext.caret -= word_length + 1
    of 1073741904:  # Left arrow
      if edittext.caret.int > 1:
        edittext.caret -= 1
    of 1073741903:  # Right arrow
      if edittext.caret.int < edittext.text.len:
        edittext.caret += 1
    of 1073742048:  # CTRL
      edittext.ctrl_pressed = true
    of 1073741906:  # up arrow
      let
        text = $(await edittext.getText())
        res = text[0..edittext.caret-1].split("\n")
      if res.len > 1:
        let
          now = res[^1].len.uint  # current line length
          target = res[^2].len.uint  # target line length
        if target < now:
          edittext.caret -= now + 1
        else:
          edittext.caret -= now + (target - now) + 1
    of 1073741905:  # down arrow
      let
        text = $(await edittext.getText())
        res = text[edittext.caret..^1].split("\n")
      if res.len > 1:
        let
          now = res[0].len.uint  # current line length
          target = res[1].len.uint  # target line length
        if target < now:
          edittext.caret += now + 1
        else:
          edittext.caret += now*2 + target
    else:
      discard
  elif edittext.has_focus and event.kind == KeyUp:
    if event.key.keysym.sym == 1073742048:  # CTRL
      edittext.ctrl_pressed = false
