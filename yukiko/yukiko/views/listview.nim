# author: Ethosa
import asyncdispatch
import sdl2
import sdl2/gfx

import linearlayout
import scrollview
import view


type
  ListViewObj* = object of ScrollViewObj
  ListViewRef* = ref ListViewObj


proc ListView*(width, height: cint, x: cint = 0, y: cint = 0,
               parent: SurfacePtr = nil, swidth: cint = 256, sheight: cint = 256): ListViewRef =
  ## Creates a new ListView object
  viewInitializer(ListViewRef)
  scrollbar_init(result)
  scrollbar_recalc(result, sheight)
  var l = LinearLayout(width, height)
  waitFor procCall result.ScrollViewRef.addView l

method addView*(listview: ListViewRef, view: ViewRef) {.async, base.} =
  ## Adds a new view in the list.
  await procCall listview.views[0].LinearLayoutRef.addView view
  var height: cint = 0
  for v in listview.views[0].LinearLayoutRef.views:
    height += v.margin[1] + v.margin[3] + v.height
  await listview.resize(listview.width, height)
  await listview.views[0].resize(listview.width, height)
  rescrollbar(listview, listview.scroll_width, listview.sheight)
