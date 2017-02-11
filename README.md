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
* `ember`: (optional)
  * `path`: (required) absolute path to the local clone of Ember (https://github.com/emberjs/ember.js)
  * `build`: (optional) command for building Ember, defaults to `ember build -prod`
* `glimmer`: (optional)
  * `path`: (required) absolute path to the local clone of Glimmer (https://github.com/tildeio/glimmer)
  * `build`: (optional) command for building Glimmer, defaults to `ember build -prod`

### experiments.json

Experiments configurations. Start by copying `config/projects.json.example` to
`config/projects.json`.

This file contains an array of experiments you would like to run.

Each experiment has the following keys:

* `name`: (required) a name for this experiment
* `app`: (required) a revision (SHA), tag, or branch name from your Ember app
* `ember`: (optional) a revision (SHA), tag, or branch name from Ember
* `glimmer`: (optional) a revision (SHA), tag or branch name from Glimmer. Only used if ember version is also provided.
* `features`: (optional) Ember feature flag overrides
* `url`: (optional) path to visit, defaults to `/`

### preload.html

Preloads data for your app. Start by copying `config/preload.html.example` to `config/projects.html`.

See the comments in the file for details.

### test.ts

The test script. Start by copying `test.ts.example` (in the root) to `test.ts`.

You shouldn't have to change much in here.
