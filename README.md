# Timtris

A falling-blocks game whose rules follow Tetris Worlds, including the gravity,
cascade and junk-clearing modes. It runs on [DragonRuby](https://dragonruby.org)
and builds for the web.

- `lib/core`: the rules, in plain Ruby with no dependencies.
- `app/`: the DragonRuby frontend (screens, drawing, input, sound).
- `assets/`, `metadata/`: what DragonRuby packages with the game.

## Controls

| | Keyboard | Gamepad |
|---|---|---|
| Move | Left / Right | D-pad |
| Drop faster | Down | D-pad down |
| Rotate clockwise | Up or X | B (east) |
| Rotate counter-clockwise | Z | A (south) |
| Pause menu | Esc or P | Start |

Menus take arrows and Enter, the mouse, or the gamepad; Esc goes back. After picking a
mode you choose the starting speed (and, for Next, the stage); left and right change a
value. Options has the volume. These choices are saved between sessions (`settings.txt`
on desktop, browser storage on the web). The Controls
screen (main menu or pause menu) shows the same table in the game.

## Running

Download DragonRuby, then either set `DRAGONRUBY_HOME` to its folder or symlink it:

```sh
ln -s /path/to/dragonruby-macos dragonruby-engine
bin/dr              # play
bin/dr test         # replay the golden scenarios inside DragonRuby
bin/dr screenshots  # save screens to tmp/screenshots
bin/dr publish      # package the web build into DragonRuby's builds/ folder
```

The web build needs HTTPS (or localhost) to run.

## Releasing to itch.io

`bin/dr release` packages the web build and uploads it with butler to
[timgaleckas.itch.io/timtris](https://timgaleckas.itch.io/timtris) (set in
`metadata/game_metadata.txt`; bump `version` there for each release). The first
release downloads butler to `~/.dragonruby/itchio-butler`; log it in once with
`~/.dragonruby/itchio-butler/butler login`.

The project page is an HTML project with SharedArrayBuffer support turned on in its
embed options, which DragonRuby's web build needs.

## Tests

The rules' tests also run under MRI (Ruby 3.3), which is where the golden traces are recorded:

```sh
bundle install
bundle exec rake
```

`test/core/golden/*.trace` are frame-by-frame recordings of scripted games. They
pin the gameplay (timing, kicks, gravity, cascades, scoring, sounds), and
`bin/dr test` checks that DragonRuby plays the same games identically. When a
gameplay change is intended, regenerate them with `UPDATE_GOLDEN=1 bundle exec rake`
and review the diff.

Code in `lib/core` has to run on both MRI and DragonRuby's mruby: use `div` for
integer division (DragonRuby's `Integer#/` returns a Float), draw randomness from
the game's `Rng`, and require files by paths DragonRuby can resolve.
