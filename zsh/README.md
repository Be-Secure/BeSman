# Completions plugin for zsh

## Install

Create a new folder for completions:

```sh
mkdir -p ~/.zsh/completions
```

Copy the file `/bes/_bes` from the location where `bes` is installed to the folder `~/.zsh/completions/`:

```sh
cp /path/to/zsh/_bes ~/.zsh/completions/
```

Then add the following lines to your `.zshrc` file:

```sh
fpath=(~/.zsh/completions $fpath)
autoload -U compinit && compinit
```

### Install using antigen

```sh
antigen bundle besman/besman-cli zsh
```
