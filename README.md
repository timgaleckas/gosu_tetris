# Timtris

A falling-blocks game whose rules follow Tetris Worlds, including the gravity,
cascade and junk-clearing modes.

The rules live in `lib/core` as plain Ruby and run unchanged on two frontends:

- **DragonRuby** (`app/`): the main version; builds for the web.
- **Gosu** (`lib/views`, `bin/tetris.rb`): the original desktop version.

## DragonRuby

Download DragonRuby, then either set `DRAGONRUBY_HOME` to its folder or symlink it:

```sh
ln -s /path/to/dragonruby-macos dragonruby-engine
bin/dr              # play
bin/dr test         # replay the golden scenarios inside DragonRuby
bin/dr screenshots  # save screens to tmp/screenshots
bin/dr publish      # package the web build into DragonRuby's builds/ folder
```

Set `devid` and `devtitle` in `metadata/game_metadata.txt` before uploading to itch.io.

## Gosu

Needs Ruby 3.3 and SDL2 (`brew install sdl2`).

```sh
bundle install
bundle exec ruby bin/tetris.rb
```

## Tests

```sh
bundle exec rake            # everything
bundle exec rake test:core  # just the rules, without Gosu
```

`test/core/golden/*.trace` are frame-by-frame recordings of scripted games. They
pin the gameplay (timing, kicks, gravity, cascades, scoring, sounds), and
`bin/dr test` checks that DragonRuby plays the same games identically. When a
gameplay change is intended, regenerate them with `UPDATE_GOLDEN=1 bundle exec rake`
and review the diff.

Code in `lib/core` has to run on both MRI and DragonRuby's mruby: use `div` for
integer division (DragonRuby's `Integer#/` returns a Float), draw randomness from
the game's `Rng`, and require files by paths DragonRuby can resolve.
