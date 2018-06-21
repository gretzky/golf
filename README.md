# golf

> the faster way to init a project

## requirements

- bash 4+
- dialog
- jq

macOS users can install all with homebrew

```bash
$ brew install bash dialog jq
```

## installation

**homebrew**

```bash
$ brew tap gretzky/formulae
$ brew install golf
```

**manually**

```bash
$ git clone https://github.com/gretzky/golf
$ make install
```

by default, it installs to `/usr/local`. you can change the prefix if you want.

```bash
$ make PREFIX=$WHATEVER install
```

you can also uninstall with `make uninstall`

## usage

golf is a dialog program that walks you through all the steps you need to init a new dev project.

it will:

- create a new named project directory
- generate a basic README
- configure a .gitignore
- configure an .editorconfig
- generate a license file

all based on your inputs.

optional:

- generates a changelog
- generates github templates (bugs, pull request, etc.)

for help:

```bash
man golf.sh
```

# license

[MIT](./LICENSE)
