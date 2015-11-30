---
layout: post
title: Adventures in Open Source: Compiling R on Mavericks
date: 2013-11-09 11:25
comments: true
---
These are the things that happen when I get bored.  For a time I've had a checkout of R's source code sitting around, simply because such a thing is nifty to have.  A lazy, slightly hungover Saturday morning though prompted me to try and compile it, just for shits-and-giggles.  Also, to see if I could.

Initially, I had checked out the code from the the mirror maintained by [wch](http://www.github.com/wch).  However, it transpired that part of the make script checks if R is being built from an svn checkout, and fails otherwise. So, it's best to start with and svn checkout, available at svn.r-project.com/R/.  Thus run:

```bash
$ svn checkout http://svn.r-project.org/R/trunk your_dir
```
To checkout the latest code to *your_dir*.  To get a specific version, e.g. R-3.0.2, run:

```bash
$ svn checkout http://svn.r-project.org/R/tags/R-3-0-2 your_dir
```

Move on gathering the dependencies.  Fortunately I had gcc and gfortan installed from previous projects.  Insure that gcc is up to date by installing the latest Xcode and updating the command line utilities.  Note that in the Mavericks version of Xcode, the command line tools don't appear to be in their usual place on the Preferences > Downloads tab. I forced the install with :

```bash
$ xcode-select --install
```

which started the update, and prompted an command line tools up to appear in the App Store.  I'm not sure precisely what happened.  Gfotran is available from the [tools](http://cran.r-project.org/bin/macosx/tools/) page on CRAN. Regardless once

```bash
$ gcc --version
$ gfortran --version
```

display versions >= 4.6.2 it's good to go.

R requires tcl/tk on all platforms; it should have come packaged with OSX 10.9.  If errors appear in the compilation steps, packaged Tcl/tk installs are available on the same [tools](http://cran.r-project.org/bin/macosx/tools/) page.

R also requires a functioning X11 window system; the one included with OSX isn't always friendly, so it is necessary to download a replacement.  The natural choice is [Xquartz](http://xquartz.macosforge.org/landing/).  The installer recommends restarting or logging out and back in - this step is necessary if Xquartz has not been installed before!

With the external dependencies installed, navigate to *your_dir/trunk* where we checked out the source code above.  From there, first run

```bash
$ ./tools/rsync-recommended
```
to pull in the source tarballs for the recommended packages.

Finally,

```bash
$ ./configure && make
```

should build and make R with the source directory.

```bash
$ make check
```

should check that everything has worked as expected.

Simple as that.

If you want to install system wide as a framework, run:

```haskell
# build the docs first
$ make info
$ make pdf

$ make install
$ make install-info
$ make install-pdf
```
though I wouldn't recommend installing at the system level unless you've built one of the stable versions.

Note: most of this comes from the INSTALL readme included with the source.  However I felt like documenting the experience so it's here now too.
