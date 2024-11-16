# F4PGA environment in nix
This is a **WIP** implementation of F4PGA environment for nix

## how to use

```shell
$ nix develop
$ cd {f4pga-example dir}
$ {f4pga build commands}
```

## TODO
- [x] environemnt building
- [x] each command needed for building almost working
- [ ] symbiflow working (the vtr packaged in this build (v9.0.0-candidate1) is not compatible with the older version)
