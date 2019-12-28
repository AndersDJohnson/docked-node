# docked-node
> Easily run your node app in a docker image (with npm installs).

Runs your node app inside an automatically-built Docker image that installs your npm dependencies.
No need for a custom `Dockerfile` in your project - one will be generated for you at runtime.

Due to Docker's caching, `npm install` will only happen when your `package.json` file changes,
and `npm run build` will only happen when project files change.

You can still use a custom `.dockerignore`
to control which file changes should cause a re-run of `npm run build`.

To run the `main` script in your `package.json`:

```console
$ docked-node
Building docker image...
Sending build context to Docker daemon  8.704kB
Step 1/6 : FROM node
 ---> f9cd651d1eb3
Step 2/6 : WORKDIR /app
 ---> Using cache
 ---> 3a73e7f353f3
Step 3/6 : COPY . .
 ---> 08b5fb086f42
Step 4/6 : RUN npm install
 ---> Running in a39e6485e678
npm WARN docking-npm@1.0.0 No description
npm WARN docking-npm@1.0.0 No repository field.

added 50 packages from 62 contributors and audited 65 packages in 3.566s
found 0 vulnerabilities

Removing intermediate container a39e6485e678
 ---> 8364057ca695
Step 5/6 : COPY . .
 ---> 6e3caf16d10d
Step 6/6 : CMD node .
 ---> Running in e8f7cc115bb3
Removing intermediate container e8f7cc115bb3
 ---> 34c6f9f39dfc
Successfully built 34c6f9f39dfc
Running node inside docker container sha256:34c6f9f39dfcfc8543f80426fc88ed16220e59102d3e7b27e839fbffbb899908...

hello from your node script
```

To run a script other than `main`, specify the path:

```console
$ docked-node other.js
Building docker image...
Sending build context to Docker daemon  8.704kB
Step 1/8 : FROM node
 ---> f9cd651d1eb3
Step 2/8 : WORKDIR /app
 ---> Using cache
 ---> 3a73e7f353f3
Step 3/8 : COPY package.json .
 ---> Using cache
 ---> 16629c2e9d13
Step 4/8 : RUN npm install
 ---> Using cache
 ---> ee840247f109
Step 5/8 : RUN mv node_modules /
 ---> Using cache
 ---> 4ff93bf5f7db
Step 6/8 : COPY . .
 ---> Using cache
 ---> 65fe2fc3f87d
Step 7/8 : RUN npm run build || true
 ---> Using cache
 ---> d0cea558683e
Step 8/8 : CMD node .
 ---> Using cache
 ---> 9da0b876ca10
Successfully built 9da0b876ca10
Running node inside docker container sha256:9da0b876ca10beb921db58781b4af8ef6b7c4d44a38d69d184bb393bb409bbed...

hey there from another node script
```

## Install

For `zsh`, in your `.zshrc`:

```sh
export FPATH="path/to/docked-node/zfuncs:$FPATH"
autoload docked-node
```

For `bash`, in your `.bashrc`:

```sh
source "path/to/docked-node/bash.sh"
```
