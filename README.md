# Fake Drupal plugin for wtf

This plugin changes application patterns the way, that scanners will recognize Drupal application in it.
It supports release versions up to 8.4.4.

## Policy example

Mandatory options:
- version: version of Drupal to emulate
- path: path to data folder (usually installed in /usr/local/share/wtf/data/)

```
{
    "name": "fake-drupal",
    "version": "0.1",
  "storages": { },
    "plugins": {            
        "honeybot.fake.drupal": [{
			"version": "7.21",
			"path":"/usr/local/share/wtf/data/honeybot/fake/drupal/"
		}]
    },
    "actions": {},
    "solvers": {}
}
```