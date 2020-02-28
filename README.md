<h1 align="center">Yukiko</h1>

<div align="center">The Nim GUI asynchronous framework based on SDL2.

[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)
[![Nim language-plastic](https://github.com/Ethosa/yukiko/blob/master/nim-lang.svg)](https://github.com/Ethosa/yukiko/blob/master/nim-lang.svg)
<h4>Latest version - 0.0.16</h4>
</div>

## Install
1. Install library
   -  via git: `nimble install https://github.com/Ehosa/yukiko`
   -  via nimble: `nimble install yukiko`
2. Download DLLs for your OS
   -  [SDL2](https://www.libsdl.org/download-2.0.php)
   -  [SDL2_image](https://www.libsdl.org/tmp/SDL_image)
   -  [SDL2_ttf](https://www.libsdl.org/projects/SDL_ttf)
   -  [SDL2_mixer](https://www.libsdl.org/tmp/SDL_mixer/)
   -  SDL2_gfx
      -  [dll for windows x64](https://github.com/Ethosa/yukiko/blob/master/sdl_bin/windows_x64/SDL2_gfx.dll)
      -  [manual assembly](http://www.ferzkopp.net/wordpress/2016/01/02/sdl_gfx-sdl2_gfx/)
3. Put DLLs in the `.nimble/bin/` folder


## Now available
-   View object (You can create your own views, which should inherits from this View).
-   LinearLayout (with vertical or horizontal orientation)
-   TextView (for text rendering).
-   Button.
-   EditText (work in progress).
    - [x] left and right arrows control.
    - [ ] up and down control.
    - [x] any font supported.
    - [x] delete text via backspace.
    - [ ] delete text via Ctrl + backspace.


## FAQ
*Q*: How I can help to develop this project?  
*A*: You can put a star on this repository :3

*Q*: Where I can see docs for this project?  
*A*: You can check github pages [here](https://ethosa.github.io/yukiko/docs/yukiko.html) :3
