# Exploring zig build to build an R package

## addCopyDirectory and .zig-cache

Seems that when `addCopyDirectory` is used, changing the contents of a
file in that directory does NOT invalidate the cache. See below:

This was observed in zig version 0.13.0.

### Update

Possibly this has been fixed after 0.13.0... See [ziggit thread](https://ziggit.dev/t/addcopydirectory-vs-addcopyfile-and-zig-cache/5365/9?u=anticrisis).


```sh
[nix-shell:~/dev/github/hello-r-zig]$ rm -r .zig-cache/ zig-out/

[nix-shell:~/dev/github/hello-r-zig]$ zig build --summary all
* installing *source* package ‘hello’ ...
** using staged installation
** R
** byte-compile and prepare package for lazy loading
** help
No man pages found in package  ‘hello’
*** installing help indices
** building package indices
** testing if installed package can be loaded from temporary location
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (hello)
Build Summary: 5/5 steps succeeded
install success
└─ install generated/ success
   ├─ WriteFile success
   └─ run R success 733ms MaxRSS:72M
      ├─ WriteFile (reused)
      └─ WriteFile  success

[nix-shell:~/dev/github/hello-r-zig]$ R_LIBS_USER=zig-out/lib R

R version 4.3.3 (2024-02-29) -- "Angel Food Cake"
Copyright (C) 2024 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

  Natural language support but running in an English locale

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

> library(hello)
> hello()
hello, world
> q()

[nix-shell:~/dev/github/hello-r-zig]$

```

Now let's introduce a syntax error:

```sh
[nix-shell:~/dev/github/hello-r-zig]$ echo "XXXXX" >> src/hello/R/hello.R

[nix-shell:~/dev/github/hello-r-zig]$ zig build --summary all
* installing *source* package ‘hello’ ...
** using staged installation
** R
** byte-compile and prepare package for lazy loading
** help
No man pages found in package  ‘hello’
*** installing help indices
** building package indices
** testing if installed package can be loaded from temporary location
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (hello)
Build Summary: 5/5 steps succeeded
install success
└─ install generated/ success
   ├─ WriteFile cached
   └─ run R success 841ms MaxRSS:72M
      ├─ WriteFile (reused)
      └─ WriteFile  cached

[nix-shell:~/dev/github/hello-r-zig]$ echo "EXPECTED ERROR DURING BUILD"
EXPECTED ERROR DURING BUILD
```

Now let's erase the cache, and we'll see the expected syntax error:

```sh
[nix-shell:~/dev/github/hello-r-zig]$ rm -r .zig-cache/ zig-out/

[nix-shell:~/dev/github/hello-r-zig]$ zig build --summary all
* installing *source* package ‘hello’ ...
** using staged installation
** R
** byte-compile and prepare package for lazy loading
Error in eval(exprs[i], envir) : object 'XXXXX' not found
Error: unable to load R code in package ‘hello’
Execution halted
ERROR: lazy loading failed for package ‘hello’
* removing ‘/home/pierre/dev/github/hello-r-zig/.zig-cache/o/544790c738d38eb183fa637997b2e9c3/hello’
install
└─ install generated/
   └─ run R failure
error: the following command exited with error code 1:
R CMD INSTALL -l /home/pierre/dev/github/hello-r-zig/.zig-cache/o/544790c738d38eb183fa637997b2e9c3 /home/pierre/dev/github/hello-r-zig/.zig-cache/o/56389b16434a7d0e9d7ccdfd3e7dbccc
Build Summary: 2/5 steps succeeded; 1 failed
install transitive failure
└─ install generated/ transitive failure
   ├─ WriteFile success
   └─ run R failure
      ├─ WriteFile (reused)
      └─ WriteFile  success
error: the following build command failed with exit code 1:
/home/pierre/dev/github/hello-r-zig/.zig-cache/o/2e55f6e0c1a67796ceb7334ff9ec28c5/build /nix/store/a1iiismj2iw26m91l13kc3arr584ix44-zig-0.13.0/bin/zig /home/pierre/dev/github/hello-r-zig /home/pierre/dev/github/hello-r-zig/.zig-cache /home/pierre/.cache/zig --seed 0xf9db1dd8 -Zb26fe9cf8bd8528c --summary all

[nix-shell:~/dev/github/hello-r-zig]$ echo "Clearing cache forced a copy of the source directory again, which failed as expected."
Clearing cache forced a copy of the source directory again, which failed as expected.

[nix-shell:~/dev/github/hello-r-zig]$
```
