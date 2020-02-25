# author: Ethosa
import asyncdispatch
import sdl2

import yukikoEnums
import view


type
  LinearLayoutObj = object of ViewObj
    gravity: array[2, Gravity]
    orientation: Orientation
    padding: array[4, cint]
    views: seq[ViewRef]
  LinearLayoutRef* = ref LinearLayoutObj


proc LinearLayout*(width, height: cint, x: cint = 0, y: cint = 0,
           parent: SurfacePtr = nil): LinearLayoutRef {.inline.} =
  ## Creates a new LinearLayoutRef object.
  ##
  ## Arguments:
  ## -   ``width`` -- view width.
  ## -   ``height`` -- view height.
  ## -   ``x`` -- X position in parent view.
  ## -   ``y`` -- Y position in parent view.
  ## -   ``parent`` -- parent view.
  viewInitializer(LinearLayoutRef)

proc calcPosV(layout: LinearLayoutRef) {.async.} =
  if layout.gravity[0] == LEFT:
    for view in layout.views:
      await view.move(layout.x, view.y)
  elif layout.gravity[0] == CENTER:
    for view in layout.views:
      await view.move((layout.width div 2 - view.width div 2) + layout.x, view.y)
  elif layout.gravity[0] == RIGHT:
    for view in layout.views:
      await view.move(layout.width - view.width, view.y)

  var h: cint = 0
  if layout.gravity[1] == TOP:
    var y: cint = 0
    for view in layout.views:
      await view.move(view.x, layout.y + y)
      y += view.height
  elif layout.gravity[1] == CENTER:
    for view in layout.views:
      h += view.height
    var y: cint = layout.height div 2 - h div 2
    for view in layout.views:
      await view.move(view.x, layout.y + y)
      y += view.height
  elif layout.gravity[1] == BOTTOM:
    for view in layout.views:
      h += view.height
    var y: cint = layout.height - h
    for view in layout.views:
      await view.move(view.x, layout.y + y)
      y += view.height

proc calcPosH(layout: LinearLayoutRef) {.async.} =
  var w: cint = 0
  if layout.gravity[0] == LEFT:
    var x: cint = 0
    for view in layout.views:
      await view.move(layout.x + x, view.y)
      x += view.width
  elif layout.gravity[0] == CENTER:
    for view in layout.views:
      w += view.width
    var x: cint = layout.width div 2 - w div 2
    for view in layout.views:
      await view.move(layout.x + x, view.y)
      x += view.width
  elif layout.gravity[0] == RIGHT:
    for view in layout.views:
      w += view.width
    var x: cint = layout.width - w
    for view in layout.views:
      await view.move(layout.x + x, view.y)
      x += view.width

  if layout.gravity[1] == TOP:
    for view in layout.views:
      await view.move(view.x, layout.y)
  elif layout.gravity[1] == CENTER:
    for view in layout.views:
      await view.move(view.x, (layout.height div 2 - view.height div 2) + layout.y)
  elif layout.gravity[1] == BOTTOM:
    for view in layout.views:
      await view.move(view.x, layout.height - view.height)

proc recalc(layout: LinearLayoutRef) {.async, inline.} =
  if layout.orientation == VERTICAL:
    await layout.calcPosV()
  else:
    await layout.calcPosH()

proc setGravityX*(layout: LinearLayoutRef, g: Gravity) {.async.} =
  ## Changes layout gravity at X coord.
  layout.gravity[0] = g
  await layout.recalc()
proc setGravityY*(layout: LinearLayoutRef, g: Gravity) {.async.} =
  ## Changes layout gravity at Y coord.
  layout.gravity[1] = g
  await layout.recalc()

proc setOrientation*(layout: LinearLayoutRef, o: Orientation) {.async.} =
  ## Changes layout orientation.
  ## ``o`` can be `VERTICAL` or `HORIZONTAL`.
  layout.orientation = o
  await layout.recalc()

proc addView*(layout: LinearLayoutRef, view: ViewRef) {.async.} =
  ## Adds view in layout
  layout.views.add view
  await layout.recalc()

method draw*(layout: LinearLayoutRef) {.async.} =
  ## Draws layout in layout.parent.
  for view in layout.views:
    blitSurface(view.background, nil, layout.background, view.rect.addr)
  blitSurface(layout.background, nil, layout.parent, layout.rect.addr)

method draw*(layout: LinearLayoutRef, dst: SurfacePtr) {.async.} =
  ## Draws layout in layout.parent.
  for view in layout.views:
    blitSurface(view.background, nil, layout.background, view.rect.addr)
  blitSurface(layout.background, nil, dst, layout.rect.addr)