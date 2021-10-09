# Notes on Commands and Stuff


## Plugins;

* [Multiverse Core](https://github.com/Multiverse/Multiverse-Core/wiki)
* [Multiverse Portals - Command Reference](https://github.com/Multiverse/Multiverse-Core/wiki/Command-Reference-%28Portals%29)


## Permissions
multiverse.access.WORLDNAME




### Allow user to telport between worlds
lp user chrisatroom17 permission set multiverse.teleport.* true
lp user chrisatroom17 permission set multiverse.core.spawn.self true
lp user chrisatroom17 permission set multiverse.core.list.* true

### Deny even Ops the ability to mess around with craeting and destroying worlds
lp group default permission set multiverse.core.create  false
lp group default permission set multiverse.core.clone  false
lp group default permission set multiverse.core.import  false
lp group default permission set multiverse.core.delete false
lp group default permission set multiverse.core.purge false
lp group default permission set multiverse.core.regen false
lp group default permission set multiverse.core.remove false
lp group default permission set multiverse.core.unload  false

## Other Settings
gamerule keepInventory true
mvm set mode creative WORLD
