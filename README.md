# Rails starter template

Opiniated webpacker-less Rails setup with the latest Rails, using PostgreSQL, TailwindCSS, Stimulus, Hotwire and RSpec.

Using jsbundling-rails for javacript, and TailwindCSS through PostCSS with cssbundling-rails. For easy loading of all stimulus controllers
we use esbuild-rails.

This comes with a full docker setup for local development including a full RSpec suite that can run on M1 Apple Docker instances (and also without docker).

## TL;DR

[with dip–CLI](https://github.com/bibendi/dip):

```sh
$ gem install dip
$ dip provision
$ foreman start -f Procfile.dip.dev
```

## Provisioning and Interacting with Docker and dip

You need `docker` and `docker-compose` installed (for MacOS just use [official app](https://docs.docker.com/engine/installation/mac/)).

This app uses the [dip–CLI](https://github.com/bibendi/dip), a utility CLI tool for straightforward provisioning and interactions with applications configured by docker-compose.

## Code Guidelines

It uses [StandardRB](https://github.com/testdouble/standard) for Ruby to automatically fix code style offenses.

```sh
dip standard
```

to automatically format Ruby with StandardRB you can run:

```sh
dip standard --fix
```

For Javascript we use [StandardJS](https://standardjs.com/).

```sh
dip yarn standard
```

to automatically format the javascript with StandardJS you can run:

```sh
dip yarn standard --fix
```

## Running the specs

Inside the docker container we have 2 different commands. To just run the unit tests:

```sh
$ dip rspec
```

and to just run the system specs:

```sh
$ dip rspec system
```