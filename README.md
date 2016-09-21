# Ember Bench

## Requirements

* Git
* Ruby 2.1+ (https://rvm.io/)
* Bundler (`gem install bundler`)
* Node 4+ (https://github.com/creationix/nvm)
* TypeScript 2.0+ (`npm install typescript@next`)
* NPM
* Bower
* R (http://apple.stackexchange.com/questions/121401/how-do-i-install-r-on-os-x)

## Configurations

### projects.json

Projects configurations. Start by copying `config/projects.json.example` to
`config/projects.json`.

* `app`: (required)
  * `path`: (required) absolute path to the local clone of your Ember app
  * `build`: (optional) command for building the app, defaults to `ember build -prod`
* `ember`: (required)
  * `path`: (required) absolute path to the local clone of Ember (https://github.com/emberjs/ember.js)
  * `build`: (optional) command for building Ember, defaults to `ember build -prod`
* `glimmer`: (required)
  * `path`: (required) absolute path to the local clone of Glimmer (https://github.com/tildeio/glimmer)
  * `build`: (optional) command for building Glimmer, defaults to `ember build -prod`

### experiments.json

Experiments configurations. Start by copying `config/projects.json.example` to
`config/projects.json`.

This file contains an array of experiments you would like to run.

Each experiment has the following keys:

* `name`: (required) a name for this experiment
* `app`: (required) a revision (SHA), tag, or branch name from your Ember app
* `ember`: (required) a revision (SHA), tag, or branch name from Ember
* `glimmer`: (required) a revision (SHA), tag or branch name from Glimmer
* `features`: (optional) Ember feature flag overrides

### puma.rb

Puma (web server) configurations. Start by copying `config/puma.rb.example` to
`config/puma.rb`.

You shouldn't have to change much in here.

### server.ru

A simple Rack server to serve the local assets. Start by copying `config/server.ru.example`
to `config/server.ru`.

You shouldn't have to change much in here.

### test.ts

The test script. Start by copying `test.ts.example` (in the root) to `test.ts`.

You shouldn't have to change much in here.
