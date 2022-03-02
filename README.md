# cyc

`cyc` is a simple static site generator. `cyc` is orders of magnitudes faster and less bloated than its competitors.

As long as the documentation is lacking, I suggest the following: To learn how to use `cyc`, just clone this repository and run `make`. Use your browser to navigate to `public/index.html` and inspect the output pages generated as well as the source files in `content/` and `template/`. At some point, I will add more documentation.

## Known bugs

1. Files included from templates (such as the footer) cannot contain fields, but includes of ordinary pages can (as is evident with mtime in `content/index.html`).

## License

Unless otherwise noted, everything in this repository is released under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html), or (at your option) any later version. However, **all files in static/, content/ and template/** are released under [CC0](https://creativecommons.org/publicdomain/zero/1.0/). This is to allow you to use these files as utterly unencumbered building blocks for your own website. Note that the GNU GPLv3 does not consider the output files in `public/` a derived work of `cyc`. This means that the output files in `public/` are not covered by the GNU GPLv3. Since the output files derive from CC0-licensed input, you are free to license the output files in whatever way you find appropriate, or not to license them at all.
